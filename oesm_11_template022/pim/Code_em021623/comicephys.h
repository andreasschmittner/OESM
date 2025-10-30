c comicephys.h

c        Basic quantities:

      parameter (tmelt  = 273.15)
c     parameter (hfus   = 0.3336e6)
      parameter (hfus   = 0.335 e6)
c     air-temp cutoff for rainfall vs. snowfall (in iceclimall.F):
#if defined (TRAINSNOW)
      parameter (trainsnow = tmelt + TRAINSNOW)
#else
      parameter (trainsnow = tmelt)
#endif

      parameter (rhobed = 3370., rhosed = 2390.) ! kg/m3

#if defined (EISLINE) && defined (LINEM)
      parameter (rhoice =  900.)
      parameter (rholiq = 1000.)
      parameter (grav   = 9.80)
#elif defined (NHA) && defined (GREENLAND) 
      parameter (rhoice =  917.)
      parameter (rholiq = 1027.)
      parameter (grav   = 9.81)
#elif defined (NHA) && ! defined (GREENLAND) 
      parameter (rhoice =  910.)
      parameter (rholiq = 1028.)
      parameter (grav   = 9.81)
#elif defined (EISLINE) || defined (EISANTA) || defined (CARB) || defined (TEST2DAXI)
      parameter (rhoice =  910.)
      parameter (rholiq = 1028.)
      parameter (grav   = 9.81)
#elif defined (TEST2D)
      parameter (rhoice =  900.)
      parameter (rholiq = 1000.)
      parameter (grav   = 9.80)
#else
      parameter (rhoice =  910.)
      parameter (rholiq = 1000.)
      parameter (grav   = 9.80616)
#endif
      parameter (rhor = rhoice/rholiq)
      parameter (rhoip = (1.-rhoice/rholiq)*rhoice)

c        Ice rheology, internal deformation:

      integer powi
c     parameter (powi = 1)   ! can't use n=1, only n=3 for shear 
      parameter (powi = 3)   ! softening in icedyn, icetherm

c     for shelf:
#if defined (LINSHELF) 
      parameter (powiv = 0.)
      parameter (powir = 1.)
#else
      parameter (powiv = (powi-1.)/(2.*powi))
      parameter (powir = (1./powi))
#endif
      parameter (powih = (powi+1.)/(2.*powi))  ! horiz shear heating

c        Basal (non-sed) sliding rheology:

      integer powb
#if defined (EISLINE) && defined (LINEF)
      parameter (powb = 2)
c     parameter (powb = 3)   ! schoof
#elif defined (EISLINE) && defined (LINEM)
#  if defined (BASALa)
      parameter (powb = 3)
#  elif defined (BASALb)
      parameter (powb = 1)
#  endif
#elif defined (TEST2D) 
      parameter (powb = 3)
#else
c     parameter (powb = 1)
      parameter (powb = 2)
c     parameter (powb = 3)
#endif

c        Sediment rheology (other parameters set in sedflow)

c     parameter (pows  = 1.25)
      integer pows
      parameter (pows = powb - 1) ! so sed and basal can combine crh's

c        Avoid singular matrix if floating areas.
c        Also used for water friction (coefbsu*(ub-uw),coefbsv*(vb-vw))
c        in icedyn, with uw,vw set in movewater, to mimic ice-dam
c        breaking in catastrophic floods.

#if defined (EISLINE)
      parameter (coefbwater    =  0.)
#else
      parameter (coefbwater    = .001)  ! Pa/(m/a)
c     parameter (coefbwater    = .100)  ! Pa/(m/a)
#endif

c        Water thickness (hw, m) above which considered lake or ocean

#if defined (NOMOVET) && ! defined (MOVEW)
      parameter (hwcut = 0.)
#else
c     parameter (hwcut = 0.2)   ! can't be zero in movewater 
      parameter (hwcut = 0.)    ! can't be zero in movewater 
#endif

c        Geothermal heat flux (J/m2/a, ~0.9 ucal/cm2/s):

#if defined (EISANTA)
      parameter (geoflux_eais = .0546 * 31556926)
#  if defined (GEOFLUX_W)
      parameter (geoflux_wais = (GEOFLUX_W/1000.) * 31556926)
#  else
      parameter (geoflux_wais = .070  * 31556926)
#  endif
#elif defined (EISLINE)
      parameter (geoflux_unif = .0711 * 31556926)
#elif defined (NHA) || defined (CARB)
      parameter (geoflux_unif = .042  * 31556926)
#else
      parameter (geoflux_unif = .0546 * 31556926)
c     parameter (geoflux_unif = (0.9*4.187*.01)*31556926)
#endif

c        Rate of decrease of ice pressure-melting point with depth (K/m)

      parameter (dtmdh = 8.66e-4)
c     parameter (dtmdh = .0074*1.e-5*rhoice*9.80616)

c        Thermal conductivities, heat capacities     
c        condice  = condicea * exp(-condiceb*t)
c        cheatice = cheaticea + cheaticeb*(t-tmelt)

#if defined (EISLINE) || defined (EISANTA) || defined (NHA) || defined (CARB)
      parameter (condicea = 2.1*31556926)                     ! J/a/m/K
      parameter (condiceb = 0.)                               ! J/a/m/K
      parameter (cheaticea= 2009.)                            ! J/kg/K
      parameter (cheaticeb= 0.)                               ! J/kg/K^2
#else
      parameter (condicea = 3.10e8)                           ! J/a/m/K
      parameter (condiceb = .0057)                            ! 1/K
      parameter (cheaticea= 2115.3)                           ! J/kg/K
      parameter (cheaticeb= 7.79)                             ! J/kg/K^2
#endif

      parameter (condsed  = 3.3*31556926)                     ! J/a/m/K
      parameter (cheatsed = 1000.)                            ! J/kg/K

      parameter (condbed  = 3.3*31556926)                     ! J/a/m/K
      parameter (cheatbed = 1000.)                            ! J/kg/K

      parameter (condliq = 70.*31556926)                      ! J/a/m2/K
      parameter (cheatliq = 4218.)                            ! J/kg/K

      parameter (condair = 10.*31556926)                      ! J/a/m2/K

c        lapse rate for surface-air temperature corrections (+ve, K/m)
c        (in iceclim[all,gcm].F)

#if defined (LAPSEPARAM)
      parameter (rlapse = LAPSEPARAM)
#elif defined (RLAPSE)
      parameter (rlapse = RLAPSE)
#else
#  if defined (NHA)
      parameter (rlapse = .0050)
#  else
      parameter (rlapse = .0080)
#  endif
#endif

c        temperature scaling for "zdt" precip corrections (C)

#if defined (TLAPSEPRECIP)                   
c     for elevation differences:
      parameter (tlapseprecip = TLAPSEPRECIP)          ! 0 for no effect
#else
      parameter (tlapseprecip = 10.)
#endif

#if defined (TLAPSEPRECIPCLIM)           
c     for parameterized climate shifts:
      parameter (tlapseprecipclim = TLAPSEPRECIPCLIM   ! 0 for no effect
#else
      parameter (tlapseprecipclim = 10.)
#endif

#if defined (NHA)
      parameter (alorb =  70.) ! latitude for insol-based weighting (oN)
#else
      parameter (alorb = -70.) ! latitude for insol-based weighting (oN)
#endif

c        For sediment domain-wide diagnostic budget

      common /sedbud/ 
     *  totquar,  totpelag,  totdump,  totslump, 
     *  totquara, totpelaga, totdumpa, totslumpa,
     *  totsed, totsedprev, timesedprev

c        Various basal/sed coefficients, units are (m/a) / Pa^powb

      parameter (crhnos = 1.e-15)                 ! ~no sliding (frozen)
      parameter (crhhard= 1.e-10)                 ! hard bedrock
c     parameter (crhsed = 1.e-5)                  ! deformable sediment 
      parameter (crhsed = 1.e-4)                  ! deformable sediment 

