setmom.f
size.h
param.h
pconst.h
stdunits.h
accel.h
calendar.h
coord.h
cpolar.h
cprnts.h
cregin.h
csbc.h
ctmb.h
diag.h
docnam.h
emode.h
grdvar.h
hmixc.h
index.h
iounit.h
isleperim.h
isopyc.h
levind.h
mw.h
scalar.h
stab.h
state.h
switch.h
tmngr.h
vmixc.h
tidal_kv.h
mobi.h
dens.h
#if defined O_mom
#include "size.h"
#include "param.h"
#include "pconst.h"
#include "stdunits.h"
#include "accel.h"
#include "calendar.h"
# if defined O_neptune
#include "cnep.h"
# endif
#include "coord.h"
# if defined O_fourfil || defined O_firfil
#include "cpolar.h"
# endif
#include "cprnts.h"
#include "cregin.h"
#include "csbc.h"
# if defined O_shortwave
#include "cshort.h"
# endif
#include "ctmb.h"
#include "diag.h"
#include "docnam.h"
#include "emode.h"
#include "grdvar.h"
#include "hmixc.h"
#include "index.h"
#include "iounit.h"
#include "isleperim.h"
# if defined O_isopycmix
#include "isopyc.h"
# endif
#include "levind.h"
#include "mw.h"
#include "scalar.h"
#include "stab.h"
#include "state.h"
#include "switch.h"
#include "tmngr.h"
#include "vmixc.h"
# if defined O_mom_tbt
#include "tbt.h"
# endif
# if defined O_fourfil || defined O_firfil
# endif
# if defined O_tidal_kv
#include "tidal_kv.h"
# endif
# if defined O_fwa
#include "fwa.h"
# endif
#ifndef O_TMM
# if defined O_tidal_kv
# endif
# if defined O_rigid_lid_surface_pressure
# endif
# if defined O_implicit_free_surface
# endif
# if defined O_tidal_kv
# endif
# if defined O_linearized_density
# endif
# if defined O_linearized_advection
# endif
# if defined O_neptune
# endif
# if defined O_rigid_lid_surface_pressure || defined O_implicit_free_surface
# endif
# if defined O_stream_function
#  if defined O_neptune
#  else
#  endif
# endif
#endif ! not O_TMM
#ifndef O_TMM
# if defined O_restart_2
# endif
# if defined O_time_averages
# endif
# if defined O_stability_tests
# endif
# if defined O_restorst && !defined O_replacst
# endif
# if defined O_shortwave
# endif
# if defined O_tracer_averages
# endif
#
# if defined O_symmetry
# endif
# if defined O_symmetry
# endif
# if defined O_stream_function
# endif
# if defined O_fourfil || defined O_firfil
#  if defined O_cyclic
#  endif
#  if defined O_rigid_lid_surface_pressure || defined O_implicit_free_surface
#  endif
#  if defined O_stream_function
#  endif
# endif
# if defined O_rigid_lid_surface_pressure || defined O_implicit_free_surface
# endif
# if defined O_stream_function
# endif
# if defined O_consthmix
#  if defined O_biharmonic
#  else
#  endif
# endif
# if defined O_meridional_tracer_budget
# endif
# if defined O_bryan_lewis_vertical || defined O_bryan_lewis_horizontal
# endif
# if defined O_time_averages
# endif
# if defined O_xbts
# endif
# if defined O_mom_tbt
# endif
# if defined O_ppvmix
# endif
# if defined O_smagnlmix && !defined O_consthmix
# endif
# if defined O_isopycmix
# endif
#endif ! O_TMM
# if defined O_mobi
# endif
#ifndef O_TMM
# if defined O_fwa
# endif
#endif ! not O_TMM
# if defined O_cyclic
# endif
# if defined O_symmetry
# endif
# if defined O_gthflx
# endif
#include "size.h"
#include "param.h"
#include "mobi.h" ! rstd*
#include "pconst.h"
#include "stdunits.h"
#include "coord.h"
#include "csbc.h"
#include "iounit.h"
#include "levind.h"
#include "mw.h"
# if defined O_tai_slh
#include "diag.h"
#include "state.h"
#include "dens.h"
# endif
# if defined O_matrix
#include "matrix.h"
# endif 
#if defined O_mobi_silicon
#endif
#ifndef O_TMM
#endif ! not O_TMM
# if defined O_kk_ballast
# endif
# if defined O_mobi_silicon
# endif
#ifndef O_TMM
# if !defined O_idealized_ic
# endif
#endif ! not O_TMM
# if defined O_mobi_nitrogen_15
#  if defined O_mobi_silicon
#  endif             
# endif
# if defined O_carbon_13
#  if defined O_mobi
#   if defined O_mobi_silicon
#   endif             
#   if defined O_mobi_caco3
#   endif             
#   if defined O_mobi_nitrogen
#   endif
#  endif
# endif
# if defined O_carbon && defined O_carbon_14
# endif
#ifndef O_TMM
# if defined O_linearized_advection
# endif
# if defined O_tai_slh
# endif
# if defined O_sed
#  if !defined O_carbon
#  endif
#  if !defined O_mobi_alk
#  endif
#  if !defined O_mobi_o2
#  endif
# endif
#endif ! not O_TMM
# if defined O_gthflx
# endif
#ifndef O_TMM
#endif ! not O_TMM
#ifndef O_TMM
#endif      
# if !defined O_mobi_no_vflux
#  if defined O_mobi_caco3
#  endif
#  if defined O_kk_ballast
#  endif
#  if defined O_mobi_silicon
#  endif
# endif
# if !defined O_mobi_no_vflux
# endif
# if !defined O_mobi_no_vflux
#  if defined O_mobi_silicon
#  endif      
# endif
# if !defined O_mobi_no_vflux
#  if defined O_mobi_silicon
#  endif      
#  if defined O_mobi_caco3
#  endif      
# endif
# if !defined O_mobi_no_vflux
# endif
# if defined O_matrix
# endif
#endif
