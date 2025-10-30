import numpy as np
from netCDF4 import Dataset
ncfile = Dataset('pim/ais/output/fort.28.nc',mode='w',format='NETCDF4_CLASSIC') 
time_dim = ncfile.createDimension('time', None)
ncfile.title='Ice Sheet Model Data'
ncfile.subtitle='Timeseries Ice Volume etc'
time0 = 1001. # start time
time = []
toti = []
tota = []
dtoti = []
acc = []
abl = []
neg = []
flow = []
err = []
rain = []
melt = []
basp = []
basf = []
refr = []
fric = []
ocme = []
calv = []
face = []
clif = []
fnm = "pim/ais/output/fort.28"
with open(fnm, 'r') as f:
    lines = f.readlines()

f.close()
nts = int(len(lines)/5)
print("# years = ",nts)

f = open(fnm, 'r')
for y in range(nts):
	header1 = f.readline()
	header2 = f.readline()
	line = f.readline()
	columns = line.split()
#	print(y,columns)
#	time.append(float(columns[0])+3501.0+float(y))
	time.append(float(columns[0])+time0+float(y))
	toti.append(float(columns[2]))
	tota.append(float(columns[3]))
	dtoti.append(float(columns[5]))
	acc.append(float(columns[6]))
	abl.append(float(columns[8]))
	neg.append(float(columns[13]))
	flow.append(float(columns[14]))
	err.append(float(columns[15]))
	rain.append(float(columns[16]))
	melt.append(float(columns[17]))
	basp.append(float(columns[18]))
	basf.append(float(columns[19]))
	refr.append(float(columns[20]))
	fric.append(float(columns[21]))
	ocme.append(float(columns[22]))
	calv.append(float(columns[23]))
	face.append(float(columns[24]))
	clif.append(float(columns[25]))
	line = f.readline()
	columns = line.split()
#	print(y,columns)
	time.append(float(columns[0])+time0+0.5+float(y))
	toti.append(float(columns[2]))
	tota.append(float(columns[3]))
	dtoti.append(float(columns[5]))
	acc.append(float(columns[6]))
	abl.append(float(columns[8]))
	neg.append(float(columns[13]))
	flow.append(float(columns[14]))
	err.append(float(columns[15]))
	rain.append(float(columns[16]))
	melt.append(float(columns[17]))
	basp.append(float(columns[18]))
	basf.append(float(columns[19]))
	refr.append(float(columns[20]))
	fric.append(float(columns[21]))
	ocme.append(float(columns[22]))
	calv.append(float(columns[23]))
	face.append(float(columns[24]))
	clif.append(float(columns[25]))
	header4 = f.readline()
f.close()

fl_time=np.array(time)
fl_toti=np.array(toti)
fl_tota=np.array(tota)
fl_dtoti=np.array(dtoti)
fl_acc=np.array(acc)
fl_abl=np.array(abl)
fl_neg=np.array(neg)
fl_basp=np.array(basp)
fl_basf=np.array(basf)
fl_refr=np.array(refr)
fl_fric=np.array(fric)
fl_ocme=np.array(ocme)
fl_calv=np.array(calv)
fl_face=np.array(face)
fl_clif=np.array(clif)
time = ncfile.createVariable('time', np.float64, ('time',))
time.units = 'years since 0000-01-01'
time.long_name = 'time'
time[:] = fl_time[:]
ivol = ncfile.createVariable('vol',np.float64,('time'))
ivol.units = 'km^3' 
ivol.long_name = 'Ice Volume'
ivol[:] = fl_toti[:]
iarea = ncfile.createVariable('area',np.float64,('time'))
iarea.units = 'km^2'
iarea.long_name = 'Ice Area'
iarea[:] = fl_tota[:]
idhdt = ncfile.createVariable('dhdt',np.float64,('time'))
idhdt.units = 'm/yr'
idhdt.long_name = 'Height Change'
idhdt[:] = fl_dtoti[:]
iacc = ncfile.createVariable('acc',np.float64,('time'))
iacc.units = 'm/yr'
iacc.long_name = 'Accumulation Rate'
iacc[:] = fl_acc[:]
iabl = ncfile.createVariable('abl',np.float64,('time'))
iabl.units = 'm/yr'
iabl.long_name = 'Albation Rate'
iabl[:] = fl_abl[:]
ineg = ncfile.createVariable('neg',np.float64,('time'))
ineg.units = 'm/yr'
ineg.long_name = 'Negative Ice Correction Rate'
ineg[:] = fl_neg[:]
ibasp = ncfile.createVariable('basp',np.float64,('time'))
ibasp.units = 'm/yr'
ibasp.long_name = 'Basal Percolation Rate'
ibasp[:] = fl_basp[:]
ibasf = ncfile.createVariable('basf',np.float64,('time'))
ibasf.units = 'm/yr'
ibasf.long_name = 'Basal Freezing Rate'
ibasf[:] = fl_basf[:]
irefr = ncfile.createVariable('refr',np.float64,('time'))
irefr.units = 'm/yr'
irefr.long_name = 'Refreezing Rate'
irefr[:] = fl_refr[:]
ifric = ncfile.createVariable('fric',np.float64,('time'))
ifric.units = 'm/yr'
ifric.long_name = 'Friction Rate'
ifric[:] = fl_fric[:]
iocme = ncfile.createVariable('ocme',np.float64,('time'))
iocme.units = 'm/yr'
iocme.long_name = 'Basal Ocean Melt Rate'
iocme[:] = fl_ocme[:]
icalv = ncfile.createVariable('calv',np.float64,('time'))
icalv.units = 'm/yr'
icalv.long_name = 'Calving Rate'
icalv[:] = fl_calv[:]
iface = ncfile.createVariable('face',np.float64,('time'))
iface.units = 'm/yr'
iface.long_name = 'Ice Face Melt Rate'
iface[:] = fl_face[:]
iclif = ncfile.createVariable('clif',np.float64,('time'))
iclif.units = 'm/yr'
iclif.long_name = 'Ice Cliff Melt Rate'
iclif[:] = fl_clif[:]

