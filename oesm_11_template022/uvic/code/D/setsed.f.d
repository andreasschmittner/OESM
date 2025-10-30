setsed.f
#if defined O_sed
#include "size.h"
#include "param.h"
#include "pconst.h"
#include "stdunits.h"
#include "calendar.h"
#include "csbc.h"
#include "coord.h"
#include "grdvar.h"
#include "levind.h"
#include "sed.h"
#include "switch.h"
#include "tmngr.h"
# if !defined O_sed_uncoupled
# endif
#ifndef O_TMM
#else
#endif        
# if defined O_carbon
# endif
# if defined O_npzd_alk
# endif
# if defined O_npzd_o2
# endif
#ifndef O_TMM
# if defined O_restart_2
# endif
#endif ! !O_TMM
# if !defined O_sed_weath_diag
# endif
# if defined O_time_averages
# endif
# if defined O_time_step_monitor
# endif
#endif
