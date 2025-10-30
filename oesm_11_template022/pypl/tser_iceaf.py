print('here0')
# from pylab import * #this is where cm.get_cmap('jet',21) command comes from
#import numpy.ma as ma
#from mpl_toolkits.basemap import Basemap
import pandas as pd



from numpy import *
from netCDF4 import *

import matplotlib.pyplot as plt
import matplotlib.path as mpath

import matplotlib.ticker as mticker

from pylab import * #this is where cm.get_cmap('jet',21) command comes from

from netCDF4 import *
import datetime

#import proplot as plot
#import matplotlib.pyplot as plt

print('here1')


time = []
toti = []
fnm = "pim/ais/output/fort.22"
f = open(fnm, 'r')
for y in range(463):
	header1 = f.readline()
	header2 = f.readline()
	header3 = f.readline()
	line = f.readline()
	columns = line.split()
	line = f.readline()
	columns = line.split()
	print(y)
	header4 = f.readline()

for y in range(86):
	header1 = f.readline()
	header2 = f.readline()
	header3 = f.readline()
	line = f.readline()
	columns = line.split()
	print(y,columns)
	time.append(float(columns[0])+3501.0+float(y))
	toti.append(float(columns[20]))
	line = f.readline()
	columns = line.split()
	print(y,columns)
	time.append(float(columns[0])+3501.5+float(y))
	toti.append(float(columns[20]))
	header4 = f.readline()
f.close()

fl_time=array(time)
fl_toti=array(toti)*1e-6
print('time = ',fl_time)
print('ice vol = ', fl_toti)

figure(figsize=(9,6)) # w,h
#plot(fl_time3,fl_toti3,'r',label='control')
plot(fl_time,fl_toti,'r',label='test6')
#plot(fl_time,fl_toti,'k',label='no $\Delta$ice elev.')
#plot(fl_time2,fl_toti2,'k',label='test5')

legend(loc=2)

title('Floating Ice Area', fontsize=25)
xlabel('year', fontsize=20)
ylabel('10$^6$ km$^2$', fontsize=20)
#ylim([26.294, 26.296])
xlim([3500, 3600])
grid()
savefig('figs/icef_area_ais.png')
show()





