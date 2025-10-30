import numpy as np
import matplotlib.pyplot as plt
import matplotlib.path as mpath
import matplotlib.ticker as mticker

from pylab import * #this is where cm.get_cmap('jet',21) command comes from

from netCDF4 import *
import datetime

#fname = "/home/mortense/models/UVic2.9_emvs/run1/MOBI2.1_local/esm/tsi.03401.01.01.nc"
fname = "../uvic-pim_11_test3/uvic/tsi.all.nc"
tot_sal_1=np.squeeze(Dataset(fname,'r').variables['O_sal'])
fname = "uvic/tsi.all.nc"
tot_sal_2=np.squeeze(Dataset(fname,'r').variables['O_sal'])

fig=plt.figure(figsize=[15,6]) #w,h?
#figure()
plt.title('Sal$_{global}$')
plot(tot_sal_1,'b',label='P(P13,BC)')
plot(tot_sal_2,'r',label='P(UVic,NBC)')
#plot(time_sal_exp1,tot_sal_exp1,'b',label='p1u1')
grid()
ylabel('psu')
xlabel('time (year)')
legend(loc=2)

plt.savefig('figs/sal.png')

plt.show()


