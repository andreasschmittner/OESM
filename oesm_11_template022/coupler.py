import glob
import os
import sys
import time
import numpy as np
import netCDF4 as nc
from scipy.interpolate import griddata

# print2file instead of print2screen
#sys.stdout = open('output_py.txt','wt')

# archive 2D output and restart files every OSKIP steps
OSKIP = 100

# ---------------------------------------------------------
# coupled model switches

CONFIG = sys.argv[1]   

IST = bool(int(CONFIG[0]))   # ice sheet topography change in UVic-ESCM, 0/1
FWA = int(CONFIG[1])         # freshwater flux from the AIS, 0/1/2
# ericmod- removing GIS
#FWG = int(CONFIG[2])         # freshwater flux from the GIS, 0/1/2

# specify CO2 forcing
SCENARIO = sys.argv[2]             # e.g. '280ppm', ssp585_ecs5.6'

year0 = int(sys.argv[3])           # year to start the run for ice sheet model, e.g. 1850
year1 = int(sys.argv[4])           # year to end the run, e.g. 2500
RESTART  = bool(int(sys.argv[5]))  # restart run or not

if not (year0 % OSKIP == 0):
    raise ValueError('year0 must be divisible by OSKIP!')

print(CONFIG, SCENARIO, year0, year1, RESTART)

RUN_NAME = 'oesm_{}_{}'.format(CONFIG, SCENARIO)
print(RUN_NAME)

# specify the stem run, from which this run branches
# RUN0 = 'uvic_{}_{}'.format(CONFIG, SCENARIO)
# ericmod, replacing 2 lines below:
#RUN0 = 'uvic_111_280ppm'
#year00 = 2000   # this run restarts from year00 of the stem run
# ericmod, with this:
RUN0 = 'uvic-pim_template'
#ericmod sep7, changed year00 from 0000 to 1500 to fix k1/k2 problem:
year00 = 3400   # this run restarts from year00 of the stem run
print('branches from year {} of run {} '.format(year00, RUN0))

# root directory of the coupled run
drt = '/data2/aschmitt/models/OESM/0.1/' + RUN_NAME

print('got through init before def''s')

# ---------------------------------------------------------
# UVic related functions


def interp_2d(lon0, lat0, var0, lon1, lat1):
    # lon0, lat0 can be 2D or 1D
    # Use both linear (in range) and nearest (out of range) methods
    # var0 is 3D (time, lat, lon), although len(time) could be just 1
    # -----------
    # omit masked data (for sub-surface ocean temp) so that adding changes in 
    # climate variables will not change the forcing data's original mask
    # "linear" interpolation method would give NaN to points out of the convex hull,
    # these points are then filled with values from the "nearest" method
    if lon0.ndim == 1:
        lons0, lats0 = np.meshgrid(lon0 % 360, lat0)
    else:
        lons0 = lon0 % 360
        lats0 = lat0
    #
    lons1, lats1 = np.meshgrid(lon1 % 360, lat1)
    # if var0 is masked or not
    masked = np.ma.is_masked(var0)
    if masked:
        # use only the unmasked points
        omask = (var0.mask == False)
        points = (lons0[omask].flatten(), lats0[omask].flatten())
        tmp0 = var0[omask].flatten()
    else:
        points = (lons0.flatten(), lats0.flatten())
        tmp0 = var0.flatten()
    tmp1 = griddata(points, tmp0, (lons1, lats1), method='nearest')
    tmp2 = griddata(points, tmp0, (lons1, lats1), method='linear')
    ii = np.isnan(tmp2)
    if np.sum(ii) > 0:
        tmp2[ii] = tmp1[ii]
    var1 = tmp2
    return var1


# if ice sheet topography is allowed to change in UVic-ESCM, update its icedata.nc

def update_icedata(year):

    if year == year0:
        # time = -19000, -18000, ..., 0, 1000, 2000
# ericmod: changed nc filename and moved L_ice(=icedata) to this directory
#        fnc = nc.Dataset(drt + '/uvic/data/icedata.nc', 'r+', format='NETCDF3_CLASSIC')
        fnc = nc.Dataset(drt + '/uvic/data/L_ice.nc', 'r+', format='NETCDF3_CLASSIC')
        fnc.variables['time'][-1] = year0
# ericmod
#        fnc.variables['hicel'].valid_range = [-1e4, 1e4]
        fnc.variables['L_icethk'].valid_range = [-1e4, 1e4]
        nt = len(fnc.variables['time'][:])
        fnc.variables['time'][nt] = year0 + 1
# ericmod (4 lines below, changing var names to vs 2.9)
#        fnc.variables['hicel'][nt, :, :] = fnc.variables['hicel'][nt-1, :, :]
#        fnc.variables['aicel'][nt, :, :] = fnc.variables['aicel'][nt-1, :, :]
# Andreas doesn't make sense it just copies the last timestep!!! 
        fnc.variables['L_icethk'][nt, :, :] = fnc.variables['L_icethk'][nt-1, :, :]
        fnc.variables['L_icefra'][nt, :, :] = fnc.variables['L_icefra'][nt-1, :, :]
        fnc.close()
    else:
        # initial AIS thickness
# ericmod, redirecting to my location
# ericnote, I will need to have this in the analogous dir as Dawei's
# ericmod, sep13, reverting to original from my mod (2 lines down):
        fnc = nc.Dataset(drt + '/template/pim/ais/fort.92.nc', 'r')
#        fnc = nc.Dataset('/home/mortense/models/ism_1stcoupled/Runantmod/exp0/fort.92.nc', 'r')
        hsa0 = fnc.variables['hs'][-1, :, :]
        fnc.close()
# ericmod, removing GIS stuff below (7 lines)
        # initial GIS thickness
#        fnc = nc.Dataset(drt + '/template/pim/gis/fort.92.nc', 'r')
#        hsg0 = fnc.variables['hs'][-1, :, :]
        # let hg along the west boundary be 0,
        # otherwise interpolation would give an artificial zone of ice
#        hsg0[:, 0] = 0
#        fnc.close()

        # ---- read ice thickness from ice sheet model ----
        # AIS
# ericnote: need to move a fort.92.nc file into here
# ericnote2: no, this will just be created by ism in this script
        fnc = nc.Dataset(drt + '/pim/ais/fort.92.nc', 'r')
        lat1a = fnc.variables['alatd'][:]
        lon1a = fnc.variables['alond'][:] % 360
        hsa = fnc.variables['hs'][-1, :, :]
        ha = fnc.variables['h'][-1, :, :]
        fedgea0 = fnc.variables['fedge'][-1,:,:]
        fnc.close()
        icemask = np.where(ha[:,:] > 0, 1, 0)
        fedgea = fedgea0*icemask
# ericmod, removing GIS stuff below (8 commented lines)
        # GIS
#        fnc = nc.Dataset(drt + '/pim/gis/fort.92.nc', 'r')
#        lat1g = fnc.variables['alatd'][:]
#        lon1g = fnc.variables['alond'][:] % 360
#        hsg = fnc.variables['hs'][-1, :, :]
#        hg = fnc.variables['h'][-1, :, :]

        # let hg along the west boundary be 0,
        # otherwise interpolation would give an artificial zone of ice
#        hg[:, 0] = 0
#        hsg[:, 0] = 0
#        fnc.close()

        # ---- update icedata ----
#ericmod (2 lines) - also need to move nc file to correct directory
#        fnc = nc.Dataset(drt + '/uvic/data/icedata.nc', 'a', format='NETCDF3_CLASSIC')
        fnc = nc.Dataset(drt + '/uvic/data/L_ice.nc', 'a', format='NETCDF3_CLASSIC')
        nt = len(fnc.variables['time'][:])
# ericmod sep13, changing xt/yt to longitude/latitude:
#        lat2 = fnc.variables['yt'][:]
#        lon2 = fnc.variables['xt'][:] % 360
        lat2 = fnc.variables['latitude'][:]
        lon2 = fnc.variables['longitude'][:] % 360

        # interpolate to UVic grid
        hicela = interp_2d(lon1a, lat1a, (hsa - hsa0), lon2, lat2)
#        hicelg = interp_2d(lon1g, lat1g, (hsg - hsg0), lon2, lat2)
# ericmod20240306, changinge the aicela interp from ha>2 to fedge
#        aicela = interp_2d(lon1a, lat1a, (ha > 2), lon2, lat2)
        print('just before aicela interp')
        aicela = interp_2d(lon1a, lat1a, fedgea, lon2, lat2)
        print('just after aicela interp')
#        aicelg = interp_2d(lon1g, lat1g, (hg > 2), lon2, lat2)
        # append new icedata to existiing one
        # It is actually not necessary to modify icedata,
        # as when UVic restarts, it first trys to read hicel from restart.nc

#ericmod (3 lines) commented out because not necessary (?, see above comments)
#        fnc.variables['time'][nt] = year + 1
#        fnc.variables['hicel'][nt, :, :] = hicela + hicelg
#        fnc.variables['aicel'][nt, :, :] = np.clip(aicela + aicelg, 0, 1)
        fnc.close()
        # ---- update data/restart.nc ----
#ericmod (2 lines) - also need to move nc file to correct directory
        fnc = nc.Dataset(drt + '/uvic/data/restart.nc', 'r+', format='NETCDF3_CLASSIC')
        # hicel (cm !!)
        # use [0, :, :] but not [:] here, or dim 'time' will be extended to a length of 102! 
        # (resulting in a restart.nc ~2.37G!)
# ericmod, remove greenland from below (4 lines)
#        fnc.variables['hicel'][0, :, :] = (hicela + hicelg) * 100
#        fnc.variables['aicel'][0, :, :] = np.clip(aicela + aicelg, 0, 1)
#ericmod sep 13, now changing var names on LHS from ^:
#        print('shapes hicel, hicela', fnc.variables['hicel'][0, 1:-1, 1:-1].shape, hicela.shape)
        fnc.variables['hicel'][0, 1:-1, 1:-1] = (hicela) * 100
        fnc.variables['aicel'][0, 1:-1, 1:-1] = np.clip(aicela, 0, 1)
# to this (not anymore):
        #print('shapes(L_icethk and hicela)', fnc.variables['L_icethk'][0,:,:].shape, hicela.shape)
#        fnc.variables['L_icethk'][0, :, :] = (hicela) * 100
#        fnc.variables['L_icefra'][0, :, :] = np.clip(aicela, 0, 1)
# end ericmod sep13
        fnc.close()


# Ice sheet freshwater flux is added to UVic-ESCM in its river module
# needs flags FWA and FWG, can be 0/1/2:
# - 0: no FWF from the specific ice sheet
# - 1: updates ice sheet FWF using the latest ice model output
# - 2: keep FWF fixed at the ice model control run

# ericmod, remove greenland from below (2 lines)
#def update_rivers(year, FWA, FWG):
def update_rivers(year, FWA):

    # ----  switches ----
    # 
    # Ice sheets FW correction (1: True, 0: False)
    # This adds a correction term, which spreads -(runliq + runfrz) from ice sheets to the global ocean
    FWC = 0

    # ---- get coastline mask from tmsk.nc ----
    # tmsk is ocean mask, 1: ocean, 0: land
#ericmod (2 lines) - also need to move nc file to correct directory
#    fnc = nc.Dataset(drt + '/uvic/data/tmsk.nc', 'r')
    fnc = nc.Dataset(drt + '/uvic/data/G_mskt.nc', 'r')
#ericmod, changing tmsk to newer var name (as well as lon/lat below; 6 lines):
#    tmsk = fnc.variables['tmsk'][:]
#    lat2 = fnc.variables['yt'][:]
#    lon2 = fnc.variables['xt'][:] % 360
    tmsk = fnc.variables['G_mskt'][:]
    lat2 = fnc.variables['latitude'][:]
    lon2 = fnc.variables['longitude'][:] % 360
    lons2, lats2 = np.meshgrid(lon2, lat2)
    fnc.close()
    # ocean area
    areao = np.sum(3.6 * 1.8 * np.cos(lats2 * np.pi / 180) * (6.371e6 * np.pi / 180)**2 * (tmsk == 1))

    # --- calculate masks ----
    # cij: UVic indices the locations of ice sheet FW discharge
    # cjj: ice model indices from which runoff converges to [i, j]
    d_cij = {}
    d_cjj = {}
    # ---- Antarctic coastlines ----
#ericnote, need to move nc file to correct directory
#ericnote2, added, cp'ed from /home/mortense/models/ism/Runantmod/fort.92.nc
    fnc = nc.Dataset(drt + '/template/pim/ais/fort.92.nc', 'r')
    lat1 = fnc.variables['alatd'][:]
    lon1 = fnc.variables['alond'][:] % 360
    fnc.close()
    cmask = (tmsk == 1) & (np.roll(tmsk, 1, 0) < 1) & (lats2 < -60)
    # indices for coastal grid points,
    # for the same meridional line, select the northest point
    cij0 = np.argwhere(cmask == True)
    cij =[]
    cjj = []
#ericmod, changing range from 102 to 100:
#    for j in range(102):
    for j in range(100):
        ii = (cij0[:, 1] == j)
        i = np.max(cij0[ii, 0])
        cij.append([i, j])
        jj = (lon1 >= lon2[j] - 1.8) & (lon1 < lon2[j] + 1.8)
        cjj.append(jj)
    d_cij['ais'] = cij
    d_cjj['ais'] = cjj
#'ericmod, removing GIS (~10 lines)
    # ---- cell indices for Greenland ----
#    fnc = nc.Dataset(drt + '/template/pim/gis/fort.92.nc', 'r')
#    lat1 = fnc.variables['alatd'][:]
#    lon1 = fnc.variables['alond'][:] % 360
#    fnc.close()
    # Greenalnd west coast
#    cmask = (tmsk == 1) & (lats2 > 55) & (lats2 < 85) & (lons2 > 297.5) & (lons2 <= 350)
#    cmask1 = cmask & (lons2 <= 315) & ((np.roll(tmsk, -1, 1) < 1) | (np.roll(tmsk, -1, 0) < 1)) 
    # Greenland east coast
#    cmask2 = cmask & (lons2 > 315)  & ((np.roll(tmsk, 1, 1) < 1)  | (np.roll(tmsk, -1, 0) < 1))
#    d_cij['gis'] = [cmask1, cmask2]
#    d_cjj['gis'] = [lon1 <= 315, lon1 > 315]
    

    # =============================
    runliq = np.zeros(lons2.shape)
    runfrz = np.zeros(lons2.shape)

#'ericmod, removing GIS (2 lines)
#    for ice_sheet, FWI in zip(['ais', 'gis'], [FWA, FWG]):
    for ice_sheet, FWI in zip(['ais'], [FWA]):

        # ---- read control run ice sheet FW flux ----
        fnc = nc.Dataset(drt + '/template/pim/{}/fort.92.nc'.format(ice_sheet), 'r')
        area1 = fnc.variables['darea'][:]    # cell area in m**2
        # [m/yr] -> [g / cm**2 / s] (frz) or [cm/s] (liq)
        # AAA added 0.91 for runliq to convert from ice to water density
        runliq0 = fnc.variables['runliqav'][-1, :, :] / 31556926. * 100 * area1 * 0.91
        runfrz0 = fnc.variables['runfrozav'][-1, :, :] / 31556926. * 100 * area1
        fnc.close()

        if FWI == 0:
            # no freshwater flux from this ice sheet
            runliq1 = runliq0 * 0
            runfrz1 = runfrz0 * 0
        elif FWI == 1:
            # update ice sheet FWF using the latest ice model output
            fnc = nc.Dataset(drt + '/pim/{}/fort.92.nc'.format(ice_sheet), 'r')
            runliq1 = fnc.variables['runliqav'][-1, :, :] / 31556926. * 100 * area1 * 0.91
            runfrz1 = fnc.variables['runfrozav'][-1, :, :] / 31556926. * 100 * area1
            fnc.close()
        elif FWI == 2:
            # use ice sheet FWF from ice model control run
            runliq1 = runliq0 
            runfrz1 = runfrz0
        else:
            raise Exception('Error: ice sheet FW switch must be one of these numbers: 0, 1, 2')
    
        # aggregate freshwater flux from ice model grid to UVic grid
        runliq2 = np.zeros(lons2.shape)
        runfrz2 = np.zeros(lons2.shape)
        if ice_sheet == 'ais':
            for [i, j], jj in zip(d_cij[ice_sheet], d_cjj[ice_sheet]):
                area = 3.6 * 1.8 * np.cos(lats2[i, j] * np.pi / 180) * (6.371e6 * np.pi / 180)**2
                runliq2[i, j] = runliq1[jj].sum() / area
                runfrz2[i, j] = runfrz1[jj].sum() / area
#'ericmod, removing GIS (5 lines)
#        elif ice_sheet == 'gis':
#            for ij, jj in zip(d_cij[ice_sheet], d_cjj[ice_sheet]):
#                area = (3.6 * 1.8 * np.cos(lats2[ij == True] * np.pi / 180) * (6.371e6 * np.pi / 180)**2).sum()
#                runliq2[ij == True] = runliq1[jj].sum() / area
#                runfrz2[ij == True] = runfrz1[jj].sum() / area

        # ice sheet freshwater flux correction
        runliq2 = runliq2 - (runliq0 + runfrz0).sum() / areao * FWC

        # add FWF of this ice sheet to the global FWF data
        runliq = runliq + runliq2 
        runfrz = runfrz + runfrz2 

    # archive rivers.nc 

    os.system('cp {}/uvic/data/rivers.nc {}/uvic/rivers/rivers.{:05d}.nc'.format(drt, drt, year))
    fnc = nc.Dataset(drt + '/uvic/data/rivers.nc', 'r+', format='NETCDF3_CLASSIC')
    _runliq = fnc.variables['runliq']
    _runliq[:] = runliq
    _runfrz = fnc.variables['runfrz']
    _runfrz[:] = runfrz
    fnc.close()

# ---------------------------------------------------------
# Ice Sheet Model related functions

def update_climfile(year, trans_icedata=True):
    # Flags:
    # tsa: update surface air temperature
    # tss: update subsurface ocean temperature (at 400m)
    # trans_icedata: update ice sheet topography

    # working in the ice sheet model directory
    # ---- update surfelev if needed ----
    if trans_icedata:
        # initial AIS thickness
        fnc = nc.Dataset(drt + '/template/pim/ais/fort.92.nc', 'r')
        ha0 = fnc.variables['hs'][-1, :, :]
        fnc.close()
#'ericmod, removing GIS (5 lines)
        # initial GIS thickness
#        fnc = nc.Dataset(drt + '/template/pim/gis/fort.92.nc', 'r')
#        hg0 = fnc.variables['hs'][-1, :, :]
        # let hg along the west boundary be 0,
        # otherwise interpolation would give an artificial zone of ice
#        hg0[:, 0] = 0
#        fnc.close()
        # ---- read ice thickness from ice sheet model ----
        # AIS
        fnc = nc.Dataset(drt + '/pim/ais/fort.92.nc', 'r')
        lat1a = fnc.variables['alatd'][:]
        lon1a = fnc.variables['alond'][:] % 360
        ha = fnc.variables['hs'][-1, :, :]
        fnc.close()
#'ericmod, removing GIS (5 lines)
        # GIS
#        fnc = nc.Dataset(drt + '/pim/gis/fort.92.nc', 'r')
#        lat1g = fnc.variables['alatd'][:]
#        lon1g = fnc.variables['alond'][:] % 360
#        hg = fnc.variables['hs'][-1, :, :]
        # let hg along the west boundary be 0,
        # otherwise interpolation would give an artificial zone of ice
#        hg[:, 0] = 0
#        fnc.close()
    # ----------- read uvic output ------------
    fnc = nc.Dataset(drt + '/uvic/tavg.{:05d}.01.01.nc'.format(year), 'r')
    lat1 = fnc.variables['latitude'][:]
    lon1 = fnc.variables['longitude'][:]
    sat = fnc.variables['A_sat'][0, :, :]
    pre = fnc.variables['F_precip'][0, :, :]
# SBT May 17, 2024: Add in variable for UVic precip to pass to climfile
    eva = fnc.variables['F_evap'][0, :, :]
#    t302p5 = fnc.variables['temperature'][0, 3, :, :]
#    t457p5 = fnc.variables['temperature'][0, 4, :, :]
    t302p5 = fnc.variables['O_temp'][0, 3, :, :]
    t457p5 = fnc.variables['O_temp'][0, 4, :, :]
    t400 = t302p5 * (57.5 / 155) + t457p5 * (97.5 / 155)
    fnc.close()
    # ------------ modify climfile -------------------
    os.system('cp {}/template/pim/climfilein.nc {}/pim/climfiles/{:04d}.nc'.format(drt,drt,year))
    # replace forcing fields ('r+' mode = append)
    fnc = nc.Dataset(drt + '/pim/climfiles/{:04d}.nc'.format(year), 'r+', format='NETCDF3_CLASSIC')
    fnc.variables['lat']=lat1
    fnc.variables['lato']=lat1
    fnc.variables['lon']=lon1
    fnc.variables['lono']=lon1
# AS if tavg file is annual all 12 months in the following will have the same annual values
# AS specifying 0:12 avoids the creation of large climefiles with 100 unneeded snapshots
    fnc.variables['tair2m'][0:12,:,:]=sat
# AS tocean has only one annual value
    fnc.variables['tocean'][:,:]=t400
    fnc.variables['precip'][0:12,:,:]=pre*31536.0
    #ericnote 20240229: evap and solarflux are currently NOT used by ISM, so just filling w precip
    #SBT May 17, 2024: passing UVic evaporation into the climfile, same unit conversion as precip (kg/m2s to m/yr)
    fnc.variables['evap'][0:12,:,:]=eva*31536.0
    fnc.variables['solarflux'][0:12,:,:]=pre*31536.0
    # ---- update surfelev if UVic is using transient icedata ----
    if trans_icedata:
        dha = interp_2d(lon1a, lat1a, (ha - ha0), lon1, lat1)
    #dha = ha-ha0
#ericmod, commenting out GIS line:
#        dhg = interp_2d(lon1g, lat1g, (hg - hg0), lon, lat)
# ericmod20240229 WHY WAS THIS COMMMENTED OUT??? adding back in (but removing dhg)
#        fnc.variables['surfelev'][:] = fnc.variables['surfelev'][:] + dha + dhg
        fnc.variables['surfelev'][:] = fnc.variables['surfelev'][:] + dha
    fnc.close()


#ericmote, are all of these writes necessary (check w dp notes)!!!
def update_namelist(year):
    # working from run directory
    with open('namelist.in', 'w') as f:
        f.write('$runparams\n')
#ericmod, added one space to each of the below 3 lines
# also, fizing the quotes to match namelist read in ism (2 methods)
        f.write("  climfilein  = '../climfiles/{:04d}.nc'\n".format(year))
        f.write('  climfileout = \'climfileout.nc\'\n')
        f.write("  climfilectl = '/data2/aschmitt/models/OESM/0.1/oesm_11_t015/pim/climfiles/all_ave_ncea.nc'\n")
#AAA climfilectl = climfilein 
#        f.write("  climfilectl = '../climfiles/{:04d}.nc'\n".format(year))
#        f.write('  climfilectl = \'fake\'\n')
        f.write('$END')

# ---------------------------------------------------------

print('after defs before if restart')

if not os.path.exists(drt):
    os.system('mkdir -p ' + drt)

os.chdir(drt)

if not RESTART:
    # Initialize the coupled UVic-ice run
    # Purge the run directory,
    # will not run this part if restart from a previous run

    # clear the run directory
    os.system('rm -rf template')
    os.system('rm -rf uvic')
    os.system('rm -rf pim')
# ERICNOTE need to make sure all files in below are there
    os.system('cp -r ../uvic-pim_template template')
    # ---- UVic ----
# ERICNOTE need to make sure all files in below are there
    os.system('cp -r ../uvic-pim_template/uvic uvic')
    # prepare restart file
    # time step = 108000 s, 108000 * 292 = 86400 * 365
    nday = 365 * year0
    nstep = 292 * year0
# ERICMOD- fix this: ../uvic_11_test/rest.01850.01.01.nc
#    cmd = 'ncap2 -s "year = {:d}; irstdy = {:d}; itt = {:d}" ../{}/rest.{:05d}.01.01.nc uvic/restart.{:04d}.nc'.format(year0, nday, nstep, RUN0, year00, year0)
    cmd = 'ncap2 -s "year = {:d}; irstdy = {:d}; itt = {:d}" ../{}/restart.{:04d}.nc uvic/restart.{:04d}.nc'.format(year0, nday, nstep, RUN0, year00, year0)
    print(cmd)
    os.system(cmd)
#ericmod print2scrn (3line)
# ERICNOTE need to create a directory inside pwd (uvic-pim-00...)
    os.system('cp uvic/restart.{:04d}.nc uvic/data/restart.nc'.format(year0))
    # initialize rivers.nc
    # just a placeholder, will be updated at the first time step
# ericmod: changed "placeholder river copy below, with following line:
#    os.system('cp ~/code/uvic-pim/data/rivers.00000.nc uvic/data/rivers.nc')
# ericmod 21sep2023, changed AGAIN to following
#    os.system('cp /home/mortense/models/coupled_uvic-pim/run/uvic-pim_template/uvic/rivers.nc uvic/data/rivers.nc')
# ericmod oct18 2023, changed AGAIN to following
    os.system('cp /home/mortense/models/coupled_uvic-pim/run/uvic-pim_template/uvic/rivers100.nc uvic/data/rivers.nc')
#    os.system('cp /home/mortense/models/coup_mod_dawei/run/uvic/2.9/template/pim/rivers.nc uvic/data/rivers.nc')
    # ---- PIM ----
    os.system('cp -r ../uvic-pim_template/pim pim')
    if not (year0 == 0):
        os.system('cp pim/ais/restart_1p pim/ais/restart_{:d}p'.format(year0 + 1))
# ericmod: removing the cp of gis belwo (1 line)
#        os.system('cp pim/gis/restart_1p pim/gis/restart_{:d}p'.format(year0 + 1))


# Start the coupled UVic-ice run

t0 = time.time()

#ericmod, making my own t00 for init time (to compare w okend's)
t00 = time.time()

os.chdir(drt)
# --------------------------------

print('year0, year1: ',year0, year1)
year = year0

while year < year1:
    print('year before esm run = ', year)
    # ----------- run uvic --------------
    print('pwd = ',os.getcwd())
    print('>' * 80)
    print(' ' * 38 + 'UVic-ESCM')
    print('<' * 80)
    os.chdir(drt + '/uvic')
#    update_rivers(year, FWA, FWG)
    update_rivers(year, FWA)
    print(' -- year = {:04d}, restart UVic \n'.format(year))
    # update ice sheet topography in UVic
    if IST:
        print(' -- update icedata.nc for changes in ice sheet topography')
        update_icedata(year)
        #
    print('pwd before esm run',os.getcwd())
    os.system('./UVic_ESCM > ../output_uvic.txt')
    if (len(glob.glob('okend')) > 0):
       print('UVic model finished')
       os.system('rm okend')
    else:
       print('exit: ice sheet model didn\'t run')
       exit()

    os.chdir(drt)
    print('pwd after esm run and os.chdir(drt)',os.getcwd())

    f_tavg = 'uvic/tavg.{:05d}.01.01.nc'.format(year+1)

    if len(glob.glob(f_tavg)) > 0:
        #
        year += 1
        #
        print(' -- update climate forcing \n')
        update_climfile(year, trans_icedata=IST)
        #
        print(' -- archive UVic restart.nc')
        if (year % OSKIP == 0):
            os.system('cp uvic/data/restart.nc uvic/restart.{:04d}.nc'.format(year))
            os.system('cp uvic/tavg.{:05d}.01.01.nc uvic/tavg.{:04d}.nc'.format(year, year))
        #
        print('\n rm tavg file')
        os.system('rm -f uvic/tavg.{:05d}.01.01.nc'.format(year))
        print('\n -- UVic-ESCM run finished')
        print(' -- time used: {:.0f}s \n'.format(time.time() - t0))
        t0 = time.time()
        print('>' * 80)
        print(' ' * 32 + 'Run Ice Sheet Model')
        print('<' * 80)

#        for ice_sheet in ['ais', 'gis']:
        for ice_sheet in ['ais']:
            os.chdir(drt + '/pim/{}'.format(ice_sheet))
            print('(before restart cp),year = ',year,' okend = ',len(glob.glob('okend')))
            if ((year - 1) % OSKIP == 0):
                print('ericnote: at restart_ error for cp (yr%oskip == 0)')
                os.system('cp restart_{:d}p restartin'.format(year))
            else:
                print('ericnote: at restart_ error for mv (NOT yr%oskip == 0)')
                os.system('mv restart_{:d}p restartin'.format(year))
            print(' -- update namelist for {}'.format(ice_sheet.upper()))
            update_namelist(year)
            print(' -- year = {:04d}, restart ice sheet model for {}\n'.format(year, ice_sheet.upper()))
            os.system('./ais.exe > ../../output_{}.txt'.format(ice_sheet))
#           okend is produced by ais.exe 
            if (len(glob.glob('okend')) > 0):
               print('ice sheet model finished')
               os.system('rm okend')
            else:
               print('exit: ice sheet model crashed')
               exit()
            os.system('mv restart restart_{:d}p'.format(year+1))
            # archive txt output
#            os.system('mv fort.22 output/fort.22.{:04d}'.format(year)) 
            os.system('cat fort.22 >> output/fort.22')
            os.system('cat fort.28 >> output/fort.28')
            # archive netcdf output
            if (year % OSKIP == 0):
# ericnote: ncks "-O" = overwrite, and  "-d time,1"=pick only the 1st element of array time
#                os.system('~/miniconda3/envs/basic/bin/ncks -O -d time,1 fort.92.nc output/fort.92.{:04d}.nc'.format(year))
# ericmod27sep23, changing "time,1" to "time,0" (after i undid the change, but i checked on the head node and got an error w "time,1")
#                os.system('/usr/bin/ncks -O -d time,1 fort.92.nc output/fort.92.{:04d}.nc'.format(year))
# ericmodl28sep23, copied over the ncks to my home dir, and changed the location in the call below
#                os.system('/usr/bin/ncks -O -d time,0 fort.92.nc output/fort.92.{:04d}.nc'.format(year))
#                os.system('/home/mortense/ncks -O -d time,0 fort.92.nc output/fort.92.{:04d}.nc'.format(year))
                os.system('cp fort.92.nc output/fort.92.{:05d}.nc'.format(year))
                os.system('cp climfileout.nc output/climfileout.{:05d}.nc'.format(year))
        print('\n -- Ice sheet runs finished')
        print(' -- time used: {:.0f}s \n'.format(time.time() - t0))
        t0 = time.time()
        os.chdir(drt)
    time.sleep(2)



