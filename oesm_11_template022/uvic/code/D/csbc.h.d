csbc.h
#if defined O_embm_awind
#endif
#if defined O_carbon_co2_2d
#endif
#if defined O_shortwave
#endif
#if defined O_ice_evp
#endif
#if defined O_carbon
# if defined O_carbon_13
# endif
# if defined O_carbon_14
# endif
#endif
#if defined O_mobi_alk
#endif
#if defined O_mobi_o2
#endif
#if defined O_mobi_silicon
#endif
#if defined O_mobi
# if !defined O_mobi_no_vflux
#  if defined O_kk_ballast
#  endif
#  if defined O_mobi_caco3
#  endif
#  if defined O_mobi_silicon
#  endif
# endif
# if defined O_mobi_iron
#  if !defined O_mobi_no_vflux
#  endif
# endif
# if defined O_mobi_nitrogen
#  if !defined O_mobi_no_vflux
#  endif
#  if defined O_mobi_nitrogen_15
#   if !defined O_mobi_no_vflux
#    if defined O_mobi_silicon
#    endif		 
#   endif
#  endif
# endif
#endif
#if defined O_carbon_13
# if !defined O_mobi_no_vflux
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_caco3
#  endif
#  if defined O_mobi_nitrogen
#  endif
# endif
#endif
#if defined O_cfcs_data || defined O_cfcs_data_transient
#endif
#if defined O_mtlm
#endif
#if defined O_mtlm && defined O_carbon
#endif
#if defined O_mtlm_carbon_13
#endif
#if defined O_mtlm_carbon_14
#endif
#if defined O_sed
# if defined O_carbon
# endif
# if defined O_mobi_alk
# endif
#endif
#if defined O_gthflx
#endif
#if defined O_plume
#endif
#if defined O_mtlm
#endif
#if defined O_mobi_silicon
#endif
