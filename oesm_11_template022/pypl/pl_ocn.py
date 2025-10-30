import netCDF4 as nc
import matplotlib.pyplot as plt
fin = nc.Dataset("uvic/tsi.nc", 'r')
varkeys = fin.variables.keys()
allvars = {}
for var in varkeys:
    allvars[var] = fin.variables[var][:]

#fig = plt.figure(figsize=(12,8))
ax1 = plt.subplot(111)
plt.plot(allvars["time"], allvars["O_sal"])
plt.grid(color="lightgray", alpha=0.65, linestyle="dashed", zorder=0)
#plt.legend(framealpha=1)
ax1.set_ylabel("Mean Ocean Salinity (1)", labelpad=5)
ax1.set_xlabel("Time (yr)")
plt.show()

