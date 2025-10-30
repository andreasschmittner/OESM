import numpy as np
from netCDF4 import Dataset
ncfile = Dataset('pim/ais/output/fort.22.nc',mode='w',format='NETCDF4_CLASSIC') 
time_dim = ncfile.createDimension('time', None)
ncfile.title='Ice Sheet Model Data'
ncfile.subtitle='Timeseries Ice Volume etc'
time0 = 1001. # start of run
time = []
vol = []
volgr = []
volfl = []
area = []
agr = []
afl = []
h = []
fnm = "pim/ais/output/fort.22"
#nts = 1720

# get number of lines in file
with open(fnm, 'r') as f:
    lines = f.readlines()

f.close()
nts = int(len(lines)/6) # number of timeseries
print("# years = ",nts)

f = open(fnm, 'r')
for y in range(nts):
	header1 = f.readline()
	header2 = f.readline()
	header3 = f.readline()
	line = f.readline()
	columns = line.split()
#	print(y,columns)
	time.append(float(columns[0])+time0+float(y))
	vol.append(float(columns[15]))
	volgr.append(float(columns[16]))
	volfl.append(float(columns[17]))
	area.append(float(columns[18]))
	agr.append(float(columns[19]))
	afl.append(float(columns[20]))
	h.append(float(columns[21]))
	line = f.readline()
	columns = line.split()
#	print(y,columns)
	time.append(float(columns[0])+time0+0.5+float(y))
	vol.append(float(columns[15]))
	volgr.append(float(columns[16]))
	volfl.append(float(columns[17]))
	area.append(float(columns[18]))
	agr.append(float(columns[19]))
	afl.append(float(columns[20]))
	h.append(float(columns[21]))
	header4 = f.readline()
f.close()
fl_time=np.array(time)
fl_vol=np.array(vol)
fl_volgr=np.array(volgr)
fl_volfl=np.array(volfl)
fl_area=np.array(area)
fl_agr=np.array(agr)
fl_afl=np.array(afl)
fl_h=np.array(h)
#print('time = ',fl_time)
#print('ice vol = ', fl_vol)
#print('floating ice area = ', fl_afl)
time = ncfile.createVariable('time', np.float64, ('time',))
time.units = 'years since 0000-01-01'
time.long_name = 'time'
# Define a 3D variable to hold the data
ivol = ncfile.createVariable('vol',np.float64,('time'))
ivol.units = 'km^3' 
ivol.long_name = 'Ice Volume'
ivolg = ncfile.createVariable('volgr',np.float64,('time'))
ivolg.units = 'km^3' 
ivolg.long_name = 'Grounded Ice Volume'
ivolf = ncfile.createVariable('volfl',np.float64,('time'))
ivolf.units = 'km^3' 
ivolf.long_name = 'Floating Ice Volume'
iarea = ncfile.createVariable('area',np.float64,('time'))
iarea.units = 'km^2'
iarea.long_name = 'Ice Area'
iareag = ncfile.createVariable('areagr',np.float64,('time'))
iareag.units = 'km^2'
iareag.long_name = 'Grounded Ice Area'
iareaf = ncfile.createVariable('areafl',np.float64,('time'))
iareaf.units = 'km^2'
iareaf.long_name = 'Floating Ice Area'
iheight = ncfile.createVariable('height',np.float64,('time'))
iheight.units = 'm'
iheight.long_name = 'Land Ice Height'
ivol[:] = fl_vol[:]
ivolg[:] = fl_volgr[:]
ivolf[:] = fl_volfl[:]
iarea[:] = fl_area[:]
iareag[:] = fl_agr[:]
iareaf[:] = fl_afl[:]
iheight[:] = fl_h[:]
time[:] = fl_time[:]

#print(ncfile)
# close the Dataset.
ncfile.close(); print('Dataset is closed!')

