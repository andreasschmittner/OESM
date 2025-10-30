mobi.f
#if defined O_mom && defined O_mobi 
#include "size.h"
#include "mobi.h"
#include "calendar.h"
#include "coord.h"
#include "stdunits.h"
#include "scalar.h"
# if defined O_mobi_iron || defined O_mobi_silicon
#include "param.h"
#include "pconst.h"
# endif
# if defined O_mobi_iron
#  if defined O_mobi_silicon
#  endif
# endif
# if defined O_kk_ballast
# endif
# if defined O_mobi_silicon
# endif
# if defined O_mobi_silicon
# endif      
# if defined O_kk_ballast
# endif
# if !defined O_mobi_nitrogen
# endif
# if !defined O_mobi_silicon
# endif
# if defined O_mobi_nitrogen
#  if !defined O_mobi_o2
#  endif
# endif
# if defined O_mobi_nitrogen_15
#  if !defined O_mobi_nitrogen
#  endif      
# endif
# if defined O_mobi_iron
#  if !defined O_mobi_o2
#  endif
#  if defined O_mobi_silicon
#  endif
# endif
# if defined O_mobi_caco3
#  if !defined O_carbon
#  endif      
# endif
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_silicon
#  endif
# if defined O_mobi_iron
# else
# endif
# if defined O_mobi_caco3
# endif            
# if defined O_mobi_caco3
# endif 
# if defined O_mobi_silicon
# endif 
# ifndef O_TMM
#  if defined O_mobi_iron
#  endif
#  if defined O_mobi_silicon
#  endif
# endif ! not O_TMM
# if defined O_mobi_silicon
# endif   
# if defined O_carbon || defined O_mobi_alk
# endif
# if defined O_carbon
#  if defined O_carbon_13
#   if defined O_mobi_nitrogen
#   endif
#   if defined O_mobi_silicon
#   endif
#   if defined O_mobi_caco3
#   endif
#  endif
# endif
# if defined O_mobi_nitrogen
#  if defined O_mobi_nitrogen_15
#   if defined O_mobi_silicon
#   endif
#  endif
# endif
# if defined O_mobi_caco3
# endif
# if defined O_kk_ballast
# endif
# if defined O_mobi_silicon
# endif
# if defined O_mobi_iron
# endif
# if defined O_mobi_o2
# endif
# if defined O_carbon_13 || defined O_mobi_caco3
# endif
# if defined O_carbon_13      
# endif
# if defined O_mobi_silicon
# endif
# if defined O_mobi_nitrogen
#  if defined O_mobi_nitrogen_15
#  endif
# endif
# if defined O_sed
# endif
#include "size.h"
#include "coord.h"
#include "grdvar.h"
#include "mw.h"
#include "mobi.h"
# if defined O_save_mobi_diagnostics
# endif
# if defined O_mobi_o2
# endif
# if defined O_mobi_iron
#  if defined O_save_mobi_diagnostics
#  endif      
# endif
# if defined O_kk_ballast
# endif
# if defined O_mobi_caco3
# endif
# if defined O_carbon_13 || defined O_mobi_caco3
#  if defined O_mobi_caco3
#  endif
# endif
# if defined O_mobi_silicon
#   if defined O_mobi_iron
#   endif
# endif
# if defined O_mobi_silicon
# endif
# if defined O_mobi_nitrogen
# endif   
# if defined O_sed
# endif
# if defined O_save_mobi_fluxes
# endif
# if defined O_mobi_nitrogen_15
# endif
# if defined O_carbon_13
#  if defined O_mobi_caco3
#  endif
# endif
# if defined O_mobi_iron
# endif
# if defined O_kk_ballast
# endif
# if defined O_mobi_caco3
# endif
# if defined O_mobi_silicon
# endif  
# if defined O_mobi_caco3
# endif
# if defined O_save_mobi_fluxes
#  if defined O_mobi_nitrogen
#   if defined O_mobi_silicon
#   endif
#  endif
#  if defined O_kk_ballast
#  endif
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_iron
#   if defined O_save_mobi_diagnostics
#    if defined O_mobi_silicon
#    endif
#   endif
#  endif
#  if defined O_save_mobi_diagnostics
#  endif
# endif
# if defined O_mobi_nitrogen_15
# endif
# if defined O_carbon_13 || defined O_mobi_caco3
#  if defined O_carbon_13
#   if defined O_mobi_caco3         
#   endif
#  endif
#  if defined O_mobi_caco3
#  endif
#  if defined O_mobi_silicon
#  endif
# endif
# if defined O_mobi_caco3
# endif
# if defined O_mobi_nitrogen
# endif
# if defined O_mobi_silicon
# endif
# if defined O_mobi_caco3     
# endif
# if defined O_kk_ballast
# endif
# if defined O_mobi_iron
# endif
#  if defined O_mobi_silicon
#  endif
# if defined O_mobi_o2
# else
# endif
# if defined O_mobi_nitrogen         
# endif
# if defined O_mobi_caco3
# endif        
# if defined O_kk_ballast
# endif
# if defined O_mobi_silicon
# endif
# if defined O_mobi_nitrogen
# endif
# if defined O_carbon
#  if defined O_mobi_caco3
#  endif
# endif
# if defined O_save_mobi_fluxes
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_nitrogen
#   if defined O_mobi_silicon
#   endif
#  endif
#  if defined O_save_mobi_diagnostics
#  endif
# endif
# if defined O_mobi_nitrogen_15
# endif
# if defined O_carbon_13
#  if defined O_mobi_caco3
#  endif
# endif
# if defined O_mobi_iron
#  if defined O_save_mobi_diagnostics
#   if defined O_mobi_silicon
#   endif         
#  endif
# endif         
# if defined O_mobi_o2
# endif
# if defined O_mobi_iron
# endif
# if defined O_mobi_caco3
# endif
# if defined O_mobi_silicon
# endif
# if defined O_kk_ballast
# endif
# if defined O_mobi_nitrogen_15
# endif
# if defined O_carbon_13
#  if defined O_mobi_caco3
#  endif
# endif
# if defined O_mobi_caco3
# endif
# if defined O_save_mobi_fluxes
#  if defined O_mobi_nitrogen
#  endif
#  if defined O_mobi_silicon
#  endif
#  if defined O_kk_ballast
#  endif
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_iron
#   if defined O_save_mobi_diagnostics
#    if defined O_mobi_silicon
#    endif         
#   endif
#  endif
#  if defined O_save_mobi_diagnostics
#  endif
# endif
# if defined O_mobi_caco3
#  if defined O_sed
#  endif
# endif
# if defined O_kk_ballast
# else               
# endif
# if defined O_mobi_nitrogen
#  if defined O_mobi_nitrogen_15
#  else
#  endif
#  if defined O_kk_ballast
#  else               
#  endif
#  if defined O_save_mobi_fluxes
#  endif
#  if defined O_mobi_nitrogen_15
#  endif              
# endif
# if defined O_mobi_iron
#  if defined O_save_mobi_fluxes
#  endif
#  if defined O_save_mobi_diagnostics
#  endif
# endif
# if defined O_carbon
# endif
# if defined O_carbon_13
# endif
# if defined O_save_mobi_fluxes
#  if defined O_kk_ballast
#  else
#  endif               
# endif
# if defined O_carbon         
# endif         
# if defined O_mobi_nitrogen
#  if defined O_mobi_nitrogen_15
#   if defined O_mobi_silicon
#   endif         
#  endif
# endif
# if defined O_carbon_13
#  if defined O_mobi_nitrogen
#  endif         
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_caco3
#  endif
# endif
# if defined O_mobi_caco3
# endif
# if defined O_kk_ballast
# endif
#  if defined O_mobi_silicon
#  endif
# if defined O_mobi_iron
# endif
# if defined O_mobi_silicon
#  if defined O_kk_variable_sipr && defined O_mobi_iron
#  else
#  endif
# endif
# if !defined O_carbon
# else
#  if !defined O_mobi_caco3         
#  endif
#  if defined O_carbon_13
#   if defined O_mobi_caco3          
#   endif
#   if !defined O_mobi_caco3          
#   endif
#  endif
# endif       
# if defined O_mobi_alk
#  if !defined O_mobi_caco3
#  endif
# endif
# if defined O_carbon_13
#  if defined O_mobi_caco3
#  endif         
# endif         
# if defined O_kk_ballast
# endif         
# if defined O_mobi_iron
# endif
# if defined O_mobi_caco3
# endif
# if defined O_mobi_silicon
# endif
# if defined O_save_mobi_fluxes
# endif
# if defined O_sed
#  if defined O_mobi_caco3
#  endif
# endif
# if defined O_mobi_o2
#  if defined O_mobi_nitrogen
#   if defined O_mobi_nitrogen_15
#   else
#   endif
#   if defined O_mobi_nitrogen_15
#   endif
#   if defined O_mobi_nitrogen_15
#   endif
#   if defined O_mobi_alk
#   endif
#   if defined O_save_mobi_fluxes
#   endif
#  endif
# endif
# if defined O_carbon
#  if defined O_mobi_caco3
#  else
#  endif
#  if defined O_carbon_13
#   if defined O_mobi_caco3
#   else              
#   endif
#  endif
# endif
# if defined O_mobi_alk
#  if defined O_mobi_caco3
#  else
#  endif
# endif
# if defined O_carbon
#  if defined O_mobi_caco3
#  else
#   if defined O_sed
#   endif
#  endif
#  if defined O_carbon_13
#   if defined O_mobi_caco3
#   else  
#   endif
#  endif
# endif
# if defined O_mobi_alk
#  if defined O_mobi_caco3
#  else
#  endif
# endif
#  if defined O_mobi_silicon
#  endif
# if defined O_mobi_caco3
# endif
# if defined O_kk_ballast
# endif
# if defined O_mobi_silicon
# endif
# if defined O_mobi_nitrogen
# endif      
# if defined O_carbon
#  if defined O_mobi_caco3
#  endif      
# endif      
# if defined O_save_mobi_fluxes
#  if defined O_mobi_silicon
#  endif      
#  if defined O_mobi_nitrogen
#   if defined O_mobi_silicon
#   endif
#  endif
#  if defined O_save_mobi_diagnostics
#  endif
# endif
# if defined O_mobi_nitrogen_15
# endif
# if defined O_carbon_13
#  if defined O_mobi_caco3
#  endif
# endif
# if defined O_mobi_iron
#  if defined O_save_mobi_diagnostics
#   if defined O_mobi_silicon
#   endif  
#  endif
# endif       
# if defined O_mobi_o2
# endif
# if defined O_mobi_silicon
#  if defined O_mobi_iron
#  endif
# endif
#include "size.h"
#include "param.h"
#include "pconst.h"
#include "stdunits.h"
#include "calendar.h"
#include "mobi.h"
# if defined O_carbon      
# endif
# if defined O_mobi_nitrogen
#  if defined O_mobi_nitrogen_15
#   if defined O_mobi_silicon
#   endif      
#  endif
# endif
# if defined O_carbon_13
#  if defined O_mobi_nitrogen
#  endif
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_caco3
#  endif
# endif
# if defined O_mobi_caco3
# endif
# if defined O_kk_ballast
# endif
# if defined O_mobi_silicon
# endif
# if defined O_mobi_iron
# endif
# if defined O_mobi_nitrogen
#  if defined O_mobi_nitrogen_15
#   if defined O_mobi_silicon
#   endif
#  endif
# endif
# if defined O_carbon_13
#  if defined O_mobi_silicon
#  endif      
#  if defined O_mobi_caco3
#  endif      
#  if defined O_mobi_nitrogen
#  endif
# endif
# if defined O_mobi_iron
# endif
# if defined O_kk_ballast
# endif
# if defined O_mobi_caco3
# endif
# if defined O_mobi_silicon
# endif
# if defined O_carbon
# endif
# if defined O_mobi_nitrogen
#  if defined O_mobi_nitrogen_15
#   if defined O_mobi_silicon
#   endif      
#  endif
# endif
# if defined O_carbon_13
#   if defined O_mobi_silicon
#   endif 
#   if defined O_mobi_caco3
#   endif 
#   if defined O_mobi_nitrogen
#   endif 
# endif
# if defined O_kk_ballast
# endif
# if defined O_mobi_caco3
# endif
# if defined O_mobi_silicon
# endif
# if defined O_mobi_iron
# endif
# if defined O_mobi_iron
#  if defined O_mobi_silicon
#  else
#  endif
#  if defined O_mobi_nitrogen
#  endif
# endif
#  if defined O_mobi_nitrogen        
#  endif
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_caco3
#  endif
#  if defined O_mobi_silicon
#  endif
# if defined O_mobi_iron
# else
# endif
# if defined O_mobi_iron
# else
# endif
# if defined O_mobi_nitrogen
#  if defined O_mobi_iron
#  else
#  endif
#  if defined O_mobi_iron
#  else
#  endif
# endif
# if defined O_mobi_silicon
#  if defined O_mobi_iron
#  else
#  endif
#  if defined O_mobi_iron
#  else
#  endif
# endif
# if defined O_mobi_nitrogen
# endif
# if defined O_mobi_nitrogen_15
# endif
# if defined O_carbon_13
#  if defined O_mobi_caco3
#  endif
# endif
# if defined O_mobi_caco3
# endif
# if defined O_kk_ballast
# endif
# if defined O_mobi_silicon
# endif
# if defined O_mobi_iron
# endif
# if defined O_save_mobi_fluxes
#  if defined O_mobi_nitrogen
#    if defined O_mobi_silicon
#    endif
#  endif
#  if defined O_mobi_iron
#   if defined O_save_mobi_diagnostics
#    if defined O_mobi_silicon
#    endif      
#   endif
#  endif
#  if defined O_save_mobi_diagnostics
#  endif
# endif
# if defined O_mobi_iron
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_nitrogen
#  endif
# endif 
# if defined O_mobi_nitrogen
#  if defined O_mobi_silicon
#  endif
# else
#  if defined O_mobi_silicon
#  endif
# endif        
# if defined O_mobi_nitrogen
#  if defined O_mobi_silicon
#  endif
#  if defined O_kk_ballast
#  endif
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_silicon
#  endif
# else
#  if defined O_kk_ballast
#  endif
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_silicon
#  endif        
# endif
# if defined O_mobi_silicon
# endif
# if defined O_mobi_nitrogen
#  if defined O_mobi_silicon
#  endif
# endif
# if defined O_mobi_nitrogen        
# endif        
# if defined O_mobi_caco3
# endif
# if defined O_kk_ballast
# endif
# if defined O_mobi_silicon
# endif
# if defined O_mobi_iron
#  if defined O_kk_ballast
#  endif          
# endif
# if defined O_mobi_nitrogen_15
# endif
# if defined O_mobi_nitrogen_15
# endif
# if defined O_mobi_nitrogen_15
# endif
# if defined O_mobi_nitrogen_15
# endif
# if defined O_mobi_nitrogen_15
# endif
# if defined O_mobi_nitrogen_15
# endif
# if defined O_mobi_nitrogen_15
# endif
# if defined O_mobi_nitrogen_15
# endif
# if defined O_mobi_nitrogen
#  if defined O_mobi_nitrogen_15
#  endif
#  if defined O_mobi_silicon
#   if defined O_mobi_nitrogen_15
#   endif
#  endif
#   if defined O_mobi_nitrogen_15
#   endif
#  if defined O_mobi_nitrogen_15
#  endif
#  if defined O_mobi_nitrogen_15
#  endif
#  if defined O_mobi_nitrogen_15
#  endif
#  if defined O_mobi_nitrogen_15
#  endif
#  if defined O_mobi_nitrogen_15
#  endif
# else
#  if defined O_mobi_silicon
#  endif
# endif
# if defined O_kk_ballast
#  if defined O_mobi_nitrogen_15
#  endif
# endif
# if defined O_mobi_caco3
# endif
# if defined O_mobi_silicon
# endif
# if defined O_mobi_iron
# endif
# if defined O_kk_ballast
# endif        
# if defined O_mobi_silicon
# endif        
# if defined O_kk_ballast
# endif        
# if defined O_mobi_silicon
# endif
# if defined O_kk_ballast
# endif
# if defined O_mobi_silicon
# endif
# if defined O_kk_ballast
# endif  
# if defined O_mobi_silicon
# endif
# if defined O_kk_ballast
# endif
# if defined O_mobi_silicon
# endif
# if defined O_kk_ballast
# endif  
# if defined O_mobi_silicon
# endif
# if defined O_mobi_nitrogen
# endif
# if defined O_mobi_nitrogen_15
#  if defined O_mobi_silicon
#  endif
# endif
# if defined O_carbon_13
#  if defined O_mobi_silicon
#  endif        
#  if defined O_mobi_caco3
#  endif        
#  if defined O_mobi_nitrogen
#  endif        
# endif
# if defined O_mobi_caco3
# else
# endif
# if defined O_mobi_silicon
# endif
# if defined O_mobi_nitrogen
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_silicon
#  endif
#  if defined O_kk_ballast
#   if defined O_mobi_silicon
#   endif
#   if defined O_mobi_silicon
#   endif
#  else        
#   if defined O_mobi_silicon
#   endif
#  endif
#  if defined O_carbon
#   if defined O_mobi_silicon
#   endif
#  endif
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_silicon
#  endif
# else
#  if defined O_mobi_silicon
#  endif
#  if defined O_kk_ballast
#   if defined O_mobi_silicon
#   endif
#   if defined O_mobi_silicon
#   endif
#  else        
#   if defined O_mobi_silicon
#   endif
#  endif        
#  if defined O_carbon
#   if defined O_mobi_silicon
#   endif
#  endif
# endif
# if defined O_mobi_caco3
# endif        
# if defined O_mobi_silicon
# endif
# if defined O_mobi_iron
#  if defined O_mobi_nitrogen
#   if defined O_mobi_silicon
#   endif
#   if defined O_mobi_silicon
#   endif        
#  else
#   if defined O_mobi_silicon
#   endif
#   if defined O_mobi_silicon
#   endif
#   if defined O_kk_ballast
#   endif        
#  endif
# endif
# if defined O_mobi_nitrogen_15
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_silicon
#  endif        
#  if defined O_mobi_silicon
#  endif
# endif
# if defined O_carbon_13
#  if defined O_mobi_nitrogen
#   if defined O_mobi_silicon
#   endif        
#   if defined O_mobi_silicon
#   endif       
#   if defined O_mobi_silicon
#   endif
#   if defined O_mobi_silicon
#   endif
#  else ! no nitrogen
#   if defined O_mobi_silicon
#   endif
#   if defined O_mobi_silicon
#   endif        
#   if defined O_kk_ballast
#   else
#   endif        
#   if defined O_mobi_silicon
#   endif
#  endif
#  if defined O_mobi_caco3
#  endif
#  if defined O_mobi_silicon
#  endif
# endif
# if defined O_mobi_nitrogen_15
# endif
# if defined O_carbon_13
#  if defined O_mobi_caco3
#  endif
# endif
# if defined O_mobi_caco3
# endif
# if defined O_mobi_silicon
# endif
# if defined O_mobi_nitrogen
# endif
# if defined O_mobi_iron
# endif
# if defined O_save_mobi_fluxes
#  if defined O_mobi_nitrogen
#   if defined O_mobi_silicon
#   endif        
#  endif
#  if defined O_kk_ballast
#  endif
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_iron
#   if defined O_save_mobi_diagnostics
#    if defined O_mobi_silicon
#    endif        
#   endif
#  endif
#  if defined O_save_mobi_diagnostics
#   if defined O_mobi_nitrogen
#   endif
#  endif
# endif
# if defined O_mobi_nitrogen
#  if defined O_mobi_nitrogen_15
#   if defined O_mobi_silicon
#   endif
#  endif
# endif
# if defined O_mobi_caco3
#  if defined O_kk_ballast
#  endif
#  if defined O_mobi_silicon
#  endif
# endif        
# if defined O_mobi_iron
# endif
# if defined O_carbon_13
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_caco3
#  endif        
#  if defined O_mobi_nitrogen
#  endif        
# endif
# if defined O_carbon
# endif
# if defined O_mobi_nitrogen
#  if defined O_mobi_nitrogen_15
#   if defined O_mobi_silicon
#   endif
#  endif
# endif
# if defined O_mobi_caco3
#  if defined O_kk_ballast
#  endif
# endif
#  if defined O_mobi_silicon
#  endif
# if defined O_mobi_iron
# endif
# if defined O_carbon_13
#  if defined O_mobi_nitrogen
#  endif      
#  if defined O_mobi_silicon
#  endif
#  if defined O_mobi_caco3
#  endif
# endif
#endif
