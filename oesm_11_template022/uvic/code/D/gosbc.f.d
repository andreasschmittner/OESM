gosbc.f
size.h
param.h
pconst.h
stdunits.h
calendar.h
csbc.h
coord.h
grdvar.h
tmngr.h
switch.h
cembm.h
atm.h
mw.h
ice.h
mtlm.h
levind.h
#if defined O_mom || defined O_embm
#include "size.h"
#include "param.h"
#include "pconst.h"
#include "stdunits.h"
#include "calendar.h"
#include "csbc.h"
#include "coord.h"
#include "grdvar.h"
#include "tmngr.h"
#include "switch.h"
# if defined O_embm
#include "cembm.h"
#include "atm.h"
# endif
# if defined O_mom
#include "mw.h"
# endif
# if defined O_ice
#  if defined O_ice_cpts
#include "cpts.h"
#  endif
#include "ice.h"
# endif
# if defined O_mtlm
#include "mtlm.h"
# endif
#include "levind.h"
# if defined O_fwa
#include "fwa.h"
#include "cregin.h"
# endif
# if defined O_sed && !defined O_sed_uncoupled
#include "sed.h"
# endif
# if defined O_mobi_silicon 
#include "mobi.h"
# endif
# if defined O_sulphate_data || defined O_sulphate_data_transient
#include "insolation.h"
# endif
# if defined O_embm_read_sflx || defined O_embm_write_sflx
# endif
# if defined O_pyism
# endif
#ifndef O_TMM
#else
#endif
#ifndef O_TMM
# if defined O_mom && defined O_embm
#  if defined O_plume
#   if !defined O_plume_brine
#   endif
#  endif
#  if defined O_convect_brine
#  endif
#  if defined O_pyism
#  endif
#  if defined O_pyism
#  endif
#  if defined O_plume
#  endif
#  if defined O_convect_brine
#  endif
#  if defined O_ice_evp || defined O_embm_awind
#  endif
#  if defined O_convect_brine
#  endif
# endif
# if defined O_embm
# endif
# if defined O_mtlm
#  if defined O_carbon
#  endif
#  if defined O_mtlm_carbon_13
#  endif
#  if defined O_mtlm_carbon_14
#  endif
#  if defined O_mtlm && defined O_carbon
#  endif
#  if defined O_mtlm_carbon_13
#  endif
#  if defined O_mtlm_carbon_14
#  endif
#  if defined O_carbon
#  endif
#  if defined O_mtlm_carbon_13
#  endif
#  if defined O_mtlm_carbon_14
#  endif
# else
# endif
#endif ! O_TMM
# if defined O_embm
#ifndef O_TMM
#  if defined O_mobi_silicon && defined O_kk_si_compensating_sources
#  endif
#endif ! O_TMM
#  if defined O_sed && !defined O_sed_uncoupled
#   if defined O_sed_constrain_weath
#   endif
#   if defined O_save_carbon_totals
#   endif
#   if defined O_global_sums || defined O_save_carbon_totals
#   endif
#   if defined O_carbon
#    if defined O_carbon_13
#    endif
#   if defined O_mobi_alk
#   endif
#    if defined O_save_carbon_totals
#    endif
#    if defined O_global_sums
#    endif
#   endif
#  endif
# endif
#ifndef O_TMM
# if defined O_sealev_data_transient && defined O_sealev_salinity
# endif
#endif ! not O_TMM
# if defined O_mom && defined O_embm
#ifndef O_TMM
#  if defined O_fwa
#   if defined O_fwa_precip
#   endif
#   if defined O_fwa_precip
#   endif
#   if defined O_fwa_compevap
#   endif
#   if defined O_fwa_compevap
#   endif
#  endif
#endif ! not O_TMM
#  if defined O_carbon || defined O_mobi_alk || defined O_mobi_o2 || defined O_mobi || defined O_cfcs_data || defined O_cfcs_data_transient
#ifndef O_TMM      
#else ! O_TMM
#endif ! O_TMM       
#   if defined O_carbon
#    if defined O_carbon_13
#    endif
#    if defined O_carbon_14
#    endif
#   endif
#   if defined O_mobi_silicon
#   endif
#   if defined O_mobi_alk
#   endif
#   if defined O_mobi_o2
#   endif
#   if defined O_mobi
#    if !defined O_mobi_no_vflux
#     if defined O_carbon_13
#     endif
#     if defined O_kk_ballast
#     endif
#     if defined O_mobi_caco3
#      if defined O_carbon_13
#      endif
#     endif
#     if defined O_mobi_silicon
#      if defined O_carbon_13
#      endif
#     endif
#    endif
#    if defined O_mobi_nitrogen
#     if !defined O_mobi_no_vflux
#      if defined O_carbon_13
#      endif
#     endif
#     if defined O_mobi_nitrogen_15
#      if !defined O_mobi_no_vflux 
#       if defined O_mobi_silicon
#       endif            
#      endif
#     endif
#    endif
#    if defined O_mobi_iron
#     if !defined O_mobi_no_vflux
#     endif
#    endif
#   endif
#   if defined O_carbon_13
#   endif
#   if defined O_cfcs_data || defined O_cfcs_data_transient
#   endif
#ifndef O_TMM      
#   if defined O_carbon
#    if defined O_carbon_13
#    endif
#    if defined O_carbon_14
#    endif
#   endif
#   if defined O_mobi_silicon
#   endif
#   if defined O_mobi_alk
#   endif
#   if defined O_mobi_o2
#   endif
#   if defined O_mobi
#    if !defined O_mobi_no_vflux
#     if defined O_kk_ballast
#     endif
#     if defined O_mobi_caco3
#     endif
#     if defined O_mobi_silicon
#     endif
#    endif
#    if defined O_mobi_iron
#     if !defined O_mobi_no_vflux
#     endif
#    endif
#    if defined O_mobi_nitrogen
#     if !defined O_mobi_no_vflux
#     endif
#     if defined O_mobi_nitrogen_15
#      if !defined O_mobi_no_vflux
#       if defined O_mobi_silicon
#       endif      
#      endif
#     endif
#    endif
#    if defined O_carbon_13
#     if !defined O_mobi_no_vflux
#      if defined O_mobi_silicon
#      endif
#      if defined O_mobi_caco3
#      endif
#      if defined O_mobi_nitrogen
#      endif
#     endif
#    endif
#   endif
#   if defined O_cfcs_data || defined O_cfcs_data_transient
#   endif
#  endif
# endif
#endif | not O_TMM
# if defined O_embm_read_sflx
# elif defined O_embm_write_sflx
# endif
#endif
# if defined O_embm && defined O_sulphate_data || defined O_sulphate_data_transient
#  if defined O_sulphate_data_direct && !defined O_sulphate_data_indirect
#  endif
#  if defined O_sulphate_data_indirect && !defined O_sulphate_data_direct
#  endif
# endif
#if defined O_embm_read_sflx
#include "size.h"
#include "param.h"
#include "pconst.h"
#include "stdunits.h"
#include "tmngr.h"
#endif
#if defined O_embm_write_sflx
#include "size.h"
#include "param.h"
#include "pconst.h"
#include "stdunits.h"
#include "coord.h"
#include "tmngr.h"
#endif
