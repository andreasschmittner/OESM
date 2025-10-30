
c-----------------------------------------------------------------------

      subroutine climate_all (budgsnow, budgrain, budgevap, budgmelt,
     *                        tsurf, tsurfi,
     *                        h, hs, hsbal, hb, maskwater,
     *                        tog, tmon, pmon, 
#if defined (LOVECLIP)
     *                        emon, qmon,
#endif
     *                        bedge, fedge, hedge,
     *                        ro18, sealev, weirun, 
     *                        dtantann, dtseas,
     *                        rco2, ecc, obl, prec,
     *                        facice, facorb, facco2,
#if defined (CO2INTER)
     *                        toge, tage, prge, ruge, runofa,
#elif defined (RCMRACMO)  
     *                        ruge, runofa,
#endif
     *                        timeice, dtimeice, dtimeclim, dtimebudg,
     *                        iloop, iffirsr)

c     Gets surface climate (tmon,pmon) and calls surfbudg to 
c     calculate annual surface mass balance (budg*) and tsurf,tsurfi. 
c     surfbudg does one point at a time, to allow SUBGRIDEDGE sub-grid 
c     method here. For simple flowline runs (EISLINE), T and P not 
c     needed, and their simple params for budg* and tsurf* are done 
c     in surfbudg.   

c     Units of all budg, precip are meters of liquid equivalent/year,
c     of all temperatures are deg K, of ruge,runofa are mm/day 
c     (latter for iceco2 only)

#include <comicephys.h>
#include <comicegrid.h>

c     passed:
      dimension 
     *  budgsnow(nx,ny),     budgrain(nx,ny),
     *  budgevap(nx,ny),     budgmelt(nx,ny),
     *  tsurf(nx,ny),        tsurfi(nx,ny),
     *  h(nx,ny),            hs(nx,ny),          hsbal(nx,ny),
     *  hb(nx,ny),           maskwater(nx,ny),
     *  tog(nx,ny),
     *  tmon(nmon,nx,ny),    pmon(nmon,nx,ny),
#if defined (LOVECLIP) 
     *  emon(nmon,nx,ny),    qmon(nmon,nx,ny),
#endif
     *  bedge(nx,ny),        fedge(nx,ny),    hedge(nx,ny)
#if defined (CO2INTER)
     * ,toge(nlong,nlatg),
     *  tage(nmon,nlong,nlatg), prge(nmon,nlong,nlatg),
     *  ruge(nlong,nlatg),      runofa(nx,ny)
#elif defined (RCMRACMO)
     * ,ruge(nlong,nlatg),      runofa(nx,ny)
#endif

      logical ifdoneclim

c     local:
      dimension hsprevcalc(nx,ny),   iftodo(nx,ny)
      save  hsprevcalc

#if defined (SUBGRIDEDGE)
c     for sub-grid budg:
      logical firstedge
      data firstedge /.true./
      parameter (nedge = max (2*nint(0.5*dd0/5.e3),1))     ! ensure even
c     parameter (nedge = max (2*nint(0.5*dd0/2.e3),1))     ! ensure even
      parameter (nedge2 = nedge*nedge)
      dimension wedge (nedge,nedge,4)
      save wedge, firstedge

      dimension hsedge(-1:1,-1:1)
      parameter (nlook = 8)   ! 4 for E-W/N-S, 8 for diagonals too
      dimension ish(nlook), jsh(nlook)
      save ish, jsh
c     First 4 are E-W/N-S, last 4 are diagonals:
      data ish /-1, 1,  0, 0, -1,  1, -1, 1/
      data jsh / 0, 0, -1, 1, -1, -1,  1, 1/
#endif

c     intra-annual timestep for surfmodel[1-3] (secs):
#if defined (DTIMESURF)
      parameter (dtimed = DTIMESURF*3600.)       ! DTIMESURF is in hours
#else
      parameter (dtimed = 5.*86400.)             ! 5 days
c     parameter (dtimed = 3600.)                 ! 1 hour 
#endif
      parameter (nspy = nint((86400.*365)/dtimed))

#if defined (SURFINSOL)
      parameter (dlatq = 2.)            ! regular lat spacing for qinsol
      parameter (nlatq = nint(180./dlatq))
      dimension qinsol(nspy,nlatq), qrange(nspy,nlatq)
      save qinsol, qrange
      dimension cosq(nlatq), fraq(nlatq), cosq24(nlatq), fraq24(nlatq),
     *          alatq(nlatq)
      parameter (solcon = 1367.)
#endif

#if defined (LOVECLIP) && defined (DEGLACTEST)
      logical firstdeglac
      save firstdeglac
      data firstdeglac /.true./
      save zweideglac
#endif

c++++++++++++++++++++
#if defined (GLACBAY)
c++++++++++++++++++++

c     balance amounts (m/y ice equiv)


c     zela = 1500. ! m
c     zacc = 0.3   ! m/y
c     zabl = .005  ! m/y per m

c     zela = 1500. ! m
c     zela = 1800. ! m  e
      zela = 2000. ! m  f
      zacc = 1.    ! m/y
      zabl = .006  ! m/y per m

      do j=1,ny
        do i=1,nx
          budgsnow(i,j) = zacc
          budgmelt(i,j) = max (0., zabl*(zela-hs(i,j) + zacc))
          budgrain(i,j) = 0.
          budgevap(i,j) = 0.
          tsurf(i,j) = tmelt
          tsurfi(i,j) = min (tsurf(i,j), tmelt)

          bedge(i,j) = budgsnow(i,j) + budgrain(i,j) 
     *               - budgevap(i,j) - budgmelt(i,j)

          if (maskwater(i,j).eq.0) fedge(i,j) = 1.
        enddo
      enddo

      return
c+++++
#endif
c+++++

      n = max (1, nint (dtimeclim/dtimeice))
c<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      if (mod (iloop, n).eq.0 .or. iffirsr.eq.1) then
c<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

c=======================================================================
#if defined (GCMMATRIX) || defined (RCMMATRIX) || defined (RCMRACMO) || defined (LOVECLIP) || defined (CSMCLIM) || defined (CLEMCLIM)
c=======================================================================

cbbbbbbbbbbbbbbbbbbbbbbbb
#  if defined (PARAMCLIM)
      if (timeice.gt.0.) then
#  else
      if (.true.) then
#  endif
cbbbbbbbbbbbbbbbbbbbbbbbb

        call climate_gcm (tog, tmon, pmon, h, hs, hsbal,
#  if defined (LOVECLIP)
     *                    emon, qmon,
#  endif
#  if defined (CO2INTER)
     *                    toge, tage, prge, ruge, runofa,
#  elif defined (RCMRACMO)
     *                    ruge, runofa,
#  endif
     *                    timeice, rco2, ecc, obl, prec,
     *                    facice, facorb, facco2)

cbbbbbbbbbb
      endif
cbbbbbbbbbb

c=====
#endif
c=====

c======================
#if defined (PARAMCLIM) 
c======================

cbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
#  if defined (GCMMATRIX) || defined (RCMMATRIX) || defined (RCMRACMO) || defined (LOVECLIP) || defined (CSMCLIM) || defined (CLEMCLIM)
      if (timeice.le.0.) then
#  else
      if (.true.) then
#  endif
cbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb

#  if defined (CO2INTER)
c       for toge, tage, prge, ruge (global):
        call climate_gcm (tog, tmon, pmon, h, hs, hsbal,
     *                    toge, tage, prge, ruge, runofa,
     *                    timeice, rco2, ecc, obl, prec,
     *                    facice, facorb, facco2)
#  endif
c       (re)set tog, tmon, pmon over ice model domain:
        call climate_param (tog, tmon, pmon, h, hs, hsbal,
     *                      ro18, dtantann, dtseas, 
     *                      rco2, timeice)

cbbbbbbbbbb
      endif
cbbbbbbbbbb

c=====
#endif
c=====

c================
#if defined (EBM) 
c================
        call climate_ebm (tog, tmon, pmon, h, hs, 
     *                    rco2, ecc, obl, prec)
c=====
#endif
c=====

c       increase air temperatures uniformly:
        zdt = 0.

#if defined (ATMOSDT)
        zdt = zdt + ATMOSDT
#elif defined (ATMOSDT1) && defined (ATMOSDT2) && defined (ATMOSDT3)
        zfac = min (1., abs(facice))
        if (facice.lt.0.) then
          zdt = zfac*ATMOSDT1 + (1.-zfac)*ATMOSDT2
        else
          zdt = zfac*ATMOSDT3 + (1.-zfac)*ATMOSDT2
        endif
#endif

#if defined (CO2LGMDT)
        rco2lgm = 185./280.
        zdt = zdt - CO2LGMDT * (log(1.) - log(rco2)) 
     *                       / (log(1.) - log(rco2lgm))
#endif

#if defined (LOVECLIP) && defined (DEGLACTEST)
c       parameterized lgm-to-modern deglac forcing (for OSUVIC test).
c       sealev set in iceinit.F. For OSUVIC (LOVECLIP) coupling,
c       climate is only set once each run (dtimeclim is large),
c       but make sure using firstdeglac here.

        if (firstdeglac) then
          call slice5g (zsl, timeice, iutsin) 
          call slice5g (zslmod, 0., iutsin) 
          call slice5g (zsllgm, -20000., iutsin) 
          zweideglac = (zsl - zsllgm) /  (zslmod-zsllgm)
          firstdeglac = .false.
        endif
        zdt = zdt - 10.*(1.-zweideglac)
#endif

        do m=1,nmon
          do j=1,ny
            do i=1,nx
              tmon(m,i,j) = tmon(m,i,j) + zdt
#if defined (LOVECLIPGCMTEST)
              if (tlapseprecipclim.ne.0.)
     *          pmon(m,i,j) = pmon(m,i,j) * (2.**(zdt/tlapseprecipclim))
#endif
            enddo
          enddo
        enddo

        ifdoneclim = .true.

c<<<<<<<<<
      else
c<<<<<<<<<

        ifdoneclim = .false.

c<<<<<<<<<<
      endif
c<<<<<<<<<<

c        Remainder of subr is budget section, given current climate.
c        (Includes lapse rate corrections for ice topog)

      n = max (1, nint (dtimebudg/dtimeice))
c>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      if (mod (iloop, n).eq.0 .or. iffirsr.eq.1 .or. ifdoneclim) then
c>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        call scopy (nx*ny, hs, 1, hsprevcalc, 1)
        call reseti (iftodo, nx*ny, 1)
c>>>>>>>>>
      else 
c>>>>>>>>>
c       do points whose sfc elev has changed > 50 m since last calc:
        npoi = 0
        do j=1,ny
          do i=1,nx
            if (abs(hs(i,j)-hsprevcalc(i,j)).gt.50.) then
              hsprevcalc(i,j) = hs(i,j)
              iftodo(i,j) = 1
              npoi = npoi + 1
            else
              iftodo(i,j) = 0
            endif
          enddo
        enddo
        if (npoi.eq.0) return
c>>>>>>>>>>
      endif
c>>>>>>>>>>

c     for now, hedge only different from h for shelf points (ocean)
      do j=1,ny
        do i=1,nx
          if (maskwater(i,j).ne.1) hedge(i,j) = h(i,j)
        enddo
      enddo

c......................
#if defined (SURFINSOL)
c......................
c        Set qinsol, fine-timestep cycle of insol at regular latitudes.
c        Also set qrange, noon minus midnight insol. They will be 
c        interpolated vs lat. to model latitude in surfbudg.

      zs = sin (0.5*prec) / sqrt ((1.+ecc)/(1.-ecc))
      zc = cos (0.5*prec)
      ze = 2. * atan2 (zs,zc)
      vern = ze - ecc * sin(ze)

      dtq = min (86400., dtimed)

      do j=1,nlatq
        alatq(j) = (-90. + 180.*(j-.5)/nlatq) *pi/180.
      enddo

c----------------
      do m=1,nspy
c----------------
        isecyr = nint ( (m-.5)*dtimed )
        isecdy = mod  ( nint((m-1.)*dtimed), 86400 )

        call zencal (nint(timeice), isecyr, isecdy, dtq,
     *               ecc, obl, prec,
     *               vern, dist, eccf,
     *               cosq, fraq, cosq24, fraq24, alatq, nlatq)
        do j=1,nlatq
          qinsol(m,j) = cosq(j)*fraq(j)*eccf*solcon
        enddo

c       range noon-midnight (qrange):
        call zencal (nint(timeice), isecyr, 0, 60.,
     *               ecc, obl, prec,
     *               vern, dist, eccf,
     *               cosq, fraq, cosq24, fraq24, alatq, nlatq)
        do j=1,nlatq
          qrange(m,j) = cosq(j)*fraq(j)*eccf*solcon
        enddo
        call zencal (nint(timeice), isecyr, 86400/2, 60.,
     *               ecc, obl, prec,
     *               vern, dist, eccf,
     *               cosq, fraq, cosq24, fraq24, alatq, nlatq)
        do j=1,nlatq
          qrange(m,j) = cosq(j)*fraq(j)*eccf*solcon - qrange(m,j)
        enddo
c----------
      enddo
c----------

c     diagnostic:
c     do m=1,nspy
c       if (m.eq.1) then
c         write (101,'(/a,16x,20f10.2)') 
c    *               'zencal alatq :', (alatq(j)*180./pi, j=nlatq,1,-5)
c         write (102,'(/a,16x,20f10.2)') 
c    *               'zencal alatq :', (alatq(j)*180./pi, j=nlatq,1,-5)
c       endif
c       write (101,'(a,i6,f7.2, 3x, 20f10.3)') 
c    *        'zencal qinsol:', m, m*dtimed/86400.,
c    *        (qinsol(m,j), j=nlatq,1,-5)
c       write (102,'(a,i6,f7.2, 3x, 20f10.3)') 
c    *        'zencal qrange:', m, m*dtimed/86400.,
c    *        (qrange(m,j), j=nlatq,1,-5)
c     enddo   
c.....
#endif
c.....

c**************************
#if ! defined (SUBGRIDEDGE)
c**************************

      do j=1,ny
        do i=1,nx
          if (iftodo(i,j).eq.1) then
            call surfbudg (budgsnow(i,j),  budgrain(i,j), 
     *                     budgevap(i,j),  budgmelt(i,j),
     *                     tsurf(i,j),     tsurfi(i,j), 
     *                     hs(i,j),        tog(i,j),
     *                     tmon(1,i,j),    pmon(1,i,j),
#  if defined (LOVECLIP)
     *                     emon(1,i,j),    qmon(1,i,j),
#  endif
#  if defined (SURFINSOL)
     *                     qinsol, qrange, nlatq, dlatq, 
#  endif
     *                     nspy, dtimed, dtantann, dtseas,
     *                     weirun, timeice, i, j)
            bedge(i,j) = budgsnow(i,j) + budgrain(i,j) 
     *                 - budgevap(i,j) - budgmelt(i,j)
c           fedge(i,j) = 1.
            if (maskwater(i,j).eq.0) fedge(i,j) = 1.
          endif
        enddo
      enddo

c****
#else
c****

c        Sub-grid computation of budg*, for **grounded** ice only,
c        for cells adjacent to or at last cell of terrestrial margin,
c        or adjacent to (upstream of) grounding line.
c          1. Decide which points have fractional (< 100%) ice cover
c             fedge (i.e., pts at ice sheet margin). 
c          2. For fedge=1 pts, calculate estimated elevations at 8
c             cell-edge pts. Normal average for fedge=1 neighbors,
c             or algorithm based on 2 segments (fedge < or > .5) for
c             fedge<1 neighbors.
c          3. For fedge=1 pts, calculate and aggregate budgets on 
c             fine sub-grid (nedge*nedge), using elevations
c             bilinearly interpolated from edge elevs from (2).
c          4. For fedge<1 pts, multiply calculated budgets by fedge 
c             (i.e., only for fraction covered with ice)
c         nb: budg* variables here are local "vertical-column" values
c         over ice. The ice fraction fedge will be applied when
c         setting budgall in icectl.F.

c       Set ice thickness scale for fedge calculation

      if (nint(dd0/1.e3).ge.40) then
        hedgenorm = 1000.
        powedge = 0.5   ! not used
      else 
        hedgenorm = 500.
        powedge = 1.    ! not used
      endif
         
c        Initialize weights for bilinear interpolation

c++++++++++++++++++++++++
      if (firstedge) then
c++++++++++++++++++++++++
        do je = 1,nedge
          do ie = 1,nedge
            zh = abs ((ie-.5 - 0.5*nedge)/nedge) 
            zv = abs ((je-.5 - 0.5*nedge)/nedge) 
            wedge(ie,je,1) = (1.-zh)*(1.-zv)
            wedge(ie,je,2) = (   zh)*(1.-zv)
            wedge(ie,je,3) = (1.-zh)*(   zv)
            wedge(ie,je,4) = (   zh)*(   zv)
          enddo
        enddo
        firstedge = .false.
c++++++++++
      endif
c++++++++++

c       Set fedge (sub-grid ice fraction). fedge < 1 if:
c         h < hedgenorm, 
c         at least 1 neighbor with h = 0, and
c         at least 1 nghbr with ice and elev higher than this elev.
c       else fedge = 1.

      do j=1,ny
        do i=1,nx
          if (iftodo(i,j).eq.1) then

c           sets grid-center budg* for all pts (grounded and floating): 
            call surfbudg (budgsnow(i,j),  budgrain(i,j), 
     *                     budgevap(i,j),  budgmelt(i,j),
     *                     tsurf(i,j),     tsurfi(i,j), 
     *                     hs(i,j),        tog(i,j),
     *                     tmon(1,i,j),    pmon(1,i,j),
#  if defined (LOVECLIP)
     *                     emon(1,i,j),    qmon(1,i,j),
#  endif
#  if defined (SURFINSOL)
     *                     qinsol, qrange, nlatq, dlatq,
#  endif
     *                     nspy, dtimed, dtantann, dtseas,
     *                     weirun, timeice, i, j)
            bedge(i,j) = budgsnow(i,j) + budgrain(i,j) 
     *                 - budgevap(i,j) - budgmelt(i,j)

            if (maskwater(i,j).eq.0) then
              if (h(i,j).ge.hedgenorm) then
                fedge(i,j) = 1.
              else if (h(i,j).eq.0.) then
                fedge(i,j) = 0.
              else
                ifa = 0
                ifb = 0
                do look=1,4
                  ii = max (1, min (nx, i + ish(look)))
                  jj = max (1, min (ny, j + jsh(look)))
                  if (h(ii,jj).gt.0. .and. hs(ii,jj).gt.hs(i,j)) ifa=1
                  if (h(ii,jj).eq.0.) ifb = 1
                enddo
                if (ifa.eq.1 .and. ifb.eq.1) then
                  fedge(i,j) = min (1., h(i,j)/hedgenorm)
                else
                  fedge(i,j) = 1.
                endif
              endif
            endif

          endif
        enddo
      enddo

      do j=1,ny
        do i=1,nx
          if (iftodo(i,j).eq.1) then
c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          if  (maskwater(i,j).eq.0 .and. fedge(i,j).eq.1.) then
c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            ifedgenext = 0
            do look = 1,8
              ii = max (1, min (nx, i + ish(look)))
              jj = max (1, min (ny, j + jsh(look)))
              if (fedge(ii,jj).ne.1. .or. maskwater(ii,jj).ne.0) 
     *          ifedgenext = 1
            enddo
c....................................
            if (ifedgenext.eq.1) then
c           if (.true.) then
c....................................

c             For grounded cells with fedge=1, calculate estimated elevs
c             at the cell edges, half-way to 8 surrounding cell centers.
c             Store in hsedge(-1:1,-1:1).
c             This is the half-way elev of a straight line from this 
c             cell's hs to: 
c               For grounded neighbor:
c                 If neighbor has fedge < 0.5, to the linear bedrock 
c                   line at fedge into the neiboring cell.
c                 If neighbor has fedge > 0.5, 2.*(fedge-.5) up the 
c                   vertical line from the nghbr's central hb to its hs.
c               For floating neighbor:  
c                 Flotation elevation of ice at grounding line,
c                   assuming g.l. is located at mid pt between cells.

              do jb = -1,1
                do ib =-1,1
                  if (jb.ne.0 .or. ib.ne.0) then
                    ii = max (1, min (nx, i + ib))
                    jj = max (1, min (ny, j + jb))
                    zfe = fedge(ii,jj)
                    if (maskwater(ii,jj).eq.0) then 
c                     grounded neighbor:
                      if (zfe.lt.0.5) then
                        zha = (0.5+zfe)*hb(ii,jj) + (0.5-zfe)*hb(i,j)
                        zhs = (zfe*hs(i,j) + 0.5*zha) / (zfe+0.5)
                      else
                        zha=((1.-zfe)*hb(ii,jj)+(zfe-0.5)*hs(ii,jj))/0.5
                        zhs = 0.5 * (hs(i,j) + zha)
                      endif

                    else
c                     floating neighbor (nb: will not work for lakes):
c                     perhaps use fracg[u,v] instead of 0.5: 
                      zhb = min (0.5*(hb(i,j)+hb(ii,jj)), sealev)
                      zhs = sealev + (sealev-zhb)*(rholiq/rhoice-1.)
                    endif
                    hsedge(ib,jb)  = zhs

                  else
                    hsedge(ib,jb)  = hs(i,j)
                  endif
                enddo
              enddo

c             Now basic bilinear interpolation of elevs on fine grid,
c             and calculate and aggregate budg quantities

              budgsnow(i,j) = 0.
              budgrain(i,j) = 0.
              budgmelt(i,j) = 0.
              do je=1,nedge
                do ie=1,nedge
                  ishif = isign (1, ie-(nedge/2+1))     ! isign(1,0) = 1
                  jshif = isign (1, je-(nedge/2+1))     ! isign(1,0) = 1
                  zhs   =   wedge(ie,je,1)*hsedge(0,    0    )
     *                    + wedge(ie,je,2)*hsedge(ishif,0    )
     *                    + wedge(ie,je,3)*hsedge(0,    jshif)
     *                    + wedge(ie,je,4)*hsedge(ishif,jshif)
                  call surfbudg (zbudgsnow,      zbudgrain, 
     *                           zbudgevap,      zbudgmelt,
     *                           ztsurf,         ztsurfi, 
     *                           zhs,            tog(i,j),
     *                           tmon(1,i,j),    pmon(1,i,j),
#  if defined (LOVECLIP)
     *                           emon(1,i,j),    qmon(1,i,j),
#  endif
#  if defined (SURFINSOL)
     *                           qinsol, qrange, nlatq, dlatq,
#  endif
     *                           nspy, dtimed, dtantann, dtseas,
     *                           weirun, timeice, i, j)

                  budgsnow(i,j) = budgsnow(i,j) + zbudgsnow/nedge2
                  budgrain(i,j) = budgrain(i,j) + zbudgrain/nedge2
                  budgmelt(i,j) = budgmelt(i,j) + zbudgmelt/nedge2
                enddo
              enddo
c...............
            else
c...............
c              budg* already set by "bedge" call to surfbudg above
c................
            endif
c................

c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          else if  (maskwater(i,j).eq.0 .and. fedge(i,j).lt.1.) then
c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

c             Nb: sfc budgets (budgsnow, etc) will be multiplied by 
c             fedge when setting budgall in icectl.F (recognising they
c             apply only over a cell's ice fraction, not ice-free frac.)

c             Reduction of elevation for fedge < 1 pts (?)
c             Not currently used (budg* already set for unmodified 
c             hb by "bedge" call to surfbudg above)
c
c           zhs = hb(i,j) + (fedge(i,j)**powedge)*h(i,j)
c           call surfbudg (budgsnow(i,j),  budgrain(i,j), 
c    *                     budgevap(i,j),  budgmelt(i,j),
c    *                     tsurf(i,j),     tsurfi(i,j), 
c    *                     zhs,            tog(i,j),
c    *                     tmon(1,i,j),    pmon(1,i,j),
#  if defined (LOVECLIP)
c    *                     emon(1,i,j),    qmon(1,i,j),
#  endif
#  if defined (SURFINSOL)
c    *                     qinsol, qrange, nlatq, dlatq,
#  endif
c    *                     nspy, dtimed, dtantann, dtseas,
c    *                     weirun, timeice, i, j)

c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          else if  (maskwater(i,j).ne.0) then
c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

c            budg* already set by "bedge" call to surfbudg above
c            (sub-grid ocmelt calcs for floating ice done in iceocean.F)

c~~~~~~~~~~~~~~
          endif
c~~~~~~~~~~~~~~
          endif
        enddo
      enddo

c*****
#endif
c*****

#if defined (MORESHELFMELT)
      do j=1,ny
        do i=1,nx
          if (iftodo(i,j).eq.1 .and. maskwater(i,j).eq.1) then
            zpr = budgsnow(i,j) + budgrain(i,j)
            zfr = budgrain(i,j) / max (zpr, .0001)
            zfr = min (1., zfr + 0.3)
            budgsnow(i,j) = (1.-zfr)*zpr
            budgrain(i,j) = zfr*zpr
            budgmelt(i,j) = budgmelt(i,j) + 1.0    ! m/y
          endif
        enddo
      enddo
#endif
#if defined (NOSURFACEWATER)
      do j=1,ny
        do i=1,nx
          if (iftodo(i,j).eq.1) then
            budgsnow(i,j) = budgsnow(i,j) + budgrain(i,j)
            budgrain(i,j) = 0.
            budgmelt(i,j) = 0.
            tsurf(i,j) = min (tsurf(i,j), tmelt)
          endif
        enddo
      enddo
#endif
#if defined (MOREWILKESSNOW)
      zfac = 4.
      do j=1,ny
        do i=1,nx
          if (iftodo(i,j).eq.1) then
            if (alatd(i,j).gt. -82. .and. alatd(i,j).lt.-60. .and.
     *          alond(i,j).gt.  90. .and. alond(i,j).lt.160.) then
              budgsnow(i,j) = MOREWILKESSNOW*budgsnow(i,j)
            endif
          endif
        enddo
      enddo
#endif

      return
      end

c-----------------------------------------------------------------------

      subroutine surfbudg (budgsnow,  budgrain,
     *                     budgevap,  budgmelt,
     *                     tsurf,     tsurfi,
     *                     hs,        tog,
     *                     tmon,      pmon,
#if defined (LOVECLIP)
     *                     emon,      qmon,
#endif
#if defined (SURFINSOL)
     *                     qinsol, qrange, nlatq, dlatq,
#endif
     *                     nspy, dtimed, dtantann, dtseas,
     *                     weirun, timeice, i, j)

c     Calculates annual surface mass balance (budg*) and tsurf,tsurfi,
c     for one point, for all types of runs (except EBM):
c       (1) 1-D flowline runs (EISLINE).
c       (2) analytic (sinusoidal) pdd (PARAMCLIM).
c       (3) explicit pdd + refreezing ([GCM,RCM]MATRIX). Does lapse rate
c           correction to tmon (pmon), from tog (gcm-interpolated
c           topography at ice grid-box center to hs.
c     Does one point (i,j) or sub-point at a time, to allow 
c     SUBGRIDEDGE method in subr climate_all.

#include <comicephys.h>
#include <comicegrid.h>

c passed (for [GCM,RCM]MATRIX):
      dimension tmon(nmon), pmon(nmon)
#if defined (LOVECLIP)
     *         ,emon(nmon), qmon(nmon)
#endif
#if defined (SURFINSOL)
     *         ,qinsol(nspy,nlatq), qrange(nspy,nlatq)
#endif

c local (for [GCM,RCM]MATRIX):
      dimension ta(nspy), pa(nspy)
#if defined (SURFINSOL) 
     *         ,qa(nspy), qar(nspy)
#endif
#if defined (LOVECLIP) 
     *         ,qadum(nspy)
#endif

      dimension ndaypm(nmon)
      data ndaypm /31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31/
      save ndaypm

      budgsnow = 0.
      budgrain = 0.
      budgevap = 0.
      budgmelt = 0.
      tsurf    = tmelt
      tsurfi   = tmelt

c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#if defined (EISLINE) && ! defined (PARAMCLIM)
c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

c        For EISLINE* experiments, budgsnow represents whole surface 
c        budget, and budgrain, budgmelt, etc, are zero. 

#  if defined (LINEB)
c     tsurf = tmelt - 15. - 10.*weirun - .0051*hs
c     budgsnow = 0.15 - 0.10*weirun
      tsurf = tmelt - 20.
      budgsnow = 0.10
#  elif defined (LINEC)
cold  tsurf = tmelt - 15. - 10.*weirun - .0051*hs
cold  budgsnow = 0.15 * (2.**((tsurf-tmelt+15.)/10.))
ccold budgsnow = 0.15*exp(-hs/3000.)
#    if defined (SINBED)
c     zela = 130.
c     zela = 100.
      zela =   0.
#    elif defined (FLATANT)
      zela = -100. + 1000.*max (timeice-200000.,0.)/200000.
      dtantann = .01*zela ! for display (fort.22) only
#    else
      if (timeice.lt.250000.) then
        zela = 250.
      else if (timeice.lt.500000.) then
        zela = 450.  ! "...rev..."
      else
        zela = 750.  ! "...rev500..."
      endif
#    endif
      tsurf = tmelt
      budgsnow = min (0.1, .005*(hs-zela))
#  elif defined (LINED)
      tsurf = tmelt - 15. - 10.*weirun - .0051*hs
      budgsnow = 0.15 * (2.**((tsurf-tmelt+15.)/10.))
      if (weirun.eq.0.) budgsnow = -1.
#  elif defined (LINEE)
      tsurf = tmelt - 15. - 10.*weirun - .0051*hs
      budgsnow =  0.
#  elif defined (LINEF)
      tsurf = tmelt - 15. 
      budgsnow = 1.0
c     budgsnow = 0.50
c     budgsnow = 0.30 ! schoof
c     budgsnow = 0.20
c     budgsnow = 0.15
c     budgsnow = 0.10
c     budgsnow = 0.05
c     budgsnow =  max(-1.,min(.15,.0005*(hs-500.) ))
c     if (timeice.lt.50000.) then
c       budgsnow = 0.10
c     else if (timeice.lt.100000.) then
c       budgsnow = 0.15
c     endif
c     budgsnow = 0.10 ! .15
c     if (timeice.lt.20000.) then
c       zr = xh(i,j)
c       if (zr.gt.500.e3) budgsnow = -1.0
c     endif
      if (nx.gt.1.and.i.eq.nx) budgsnow = 0.
      if (ny.gt.1.and.j.eq.ny) budgsnow = 0.
#  elif defined (LINEG)
      tsurf = tmelt - 20.
      budgsnow =  0.20
      zr = xh(i,j)
c     for no ocean:
      if (zr.gt.900.e3) budgsnow = -1.0
#  elif defined (LINEH3) || defined (LINEH4)
      tsurf = tmelt - 20.
      budgsnow =  0.10
#  elif defined (LINEM)
      tsurf = tmelt - 20.
      budgsnow =  0.30
#  elif defined (SLMODEL)
      tsurf = tmelt - 20.
#    if defined (SLSNOWFALL)
      budgsnow =  SLSNOWFALL
#    else
      budgsnow =  0.10
#    endif
      if (nx.gt.1.and.i.eq.nx) budgsnow = 0.
      if (ny.gt.1.and.j.eq.ny) budgsnow = 0.
#  endif

      tsurfi = min (tmelt, tsurf)

c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#elif defined (TEST2D) || defined (TEST2DAXI)
c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

c     can be functions of i,j, (hs,...) :
c     tsurf = tmelt - 20.
cc    budgsnow = 0.10
cc    budgsnow = 0.50
c     budgsnow = 1.00
c     tsurfi = min (tmelt, tsurf)

      tsurf = tmelt
      tsurfi = min (tmelt, tsurf)
c     zela = 2500.
c     budgsnow = min (0.1, .005*(hs-zela))
#  if defined (MISMIP3D_ACCUM)
      budgsnow = MISMIP3D_ACCUM ! mismip3d
#  else
      budgsnow = 0.3            ! mismip3d
#  endif

c~~~~~~~~~~~~~~~~~~~~~~
#elif defined (SIMPPDD)
c~~~~~~~~~~~~~~~~~~~~~~

c        SIMPPDD is very simple PDD and snow/rain partition using tmon,
c        no refreezing. budgsnow is snowfall, budgrain is rain, budgmelt
c        is surface melt (all runoff, no refreezing), budgevap=0.
c        PDD coefficient is hard-coded below.
c
c        (Nb: budgrain and budgmelt contribute to baseperc in 
c        icetherm/vdif, and baseperc is included in budgall in icectl)

c        Lapse rate correction (zdt) from climate data's topog to ice hs
c        (Searise, GCM, RCM, Loveclip), for air temp, and for precip 
c        if requested. Includes SUBGRIDEDGE topog vars if used. 

c        Ablation is based on simple pdd and monthly meteo cycle. 
c        Also modify precip for fraction falling as snow (zsn).
c        qmon(m), monthly dnwd sfc solar flux (W/m2) is available 
c        for pdd scheme if LOVECLIP, but not currenty used 
c        (see commented-out line below in call to intdrive).

      tsurf = 0.
      prsurf = 0.
      pdd = 0.
      zsn = 0.
      tsurfi = 0.

#  if defined (TPDD)
      t0 = tmelt + TPDD
#  else
      t0 = tmelt
#  endif

      do m=1,nmon
        zdt = - rlapse*(hs-tog)
        zta = tmon(m) + zdt
        zpr = pmon(m)
        if (tlapseprecip.ne.0.) then
          zpr = zpr * (2.**(zdt/tlapseprecip))  ! Ritz et al,2001 ?
c         zpr = zpr * exp  (zdt/tlapsleprecip)  ! Huybr et al,PPP,1991 ?
        endif
        tsurf  = tsurf  + zta*ndaypm(m)/365.
        prsurf = prsurf + zpr*ndaypm(m)/365.

        pdd = pdd + max (zta - t0, 0.) * ndaypm(m)
        if (zta.lt.trainsnow) zsn = zsn + ndaypm(m)/365.
        tsurfi = tsurfi + min (zta,tmelt) * ndaypm(m)/365.
      enddo

      budgsnow = zsn*prsurf
      budgrain = (1.-zsn)*prsurf
      budgmelt = .005 * pdd          ! pdd coeff = .005 m per degree-day

c~~~~
#else
c~~~~

c        Default surface snow-ice mass budget treatment (not SIMPPDD), 
c        for use with PARAMCLIM or [GCM,RCM]MATRIX. First, interpolate 
c        monthly climate tmon, pmon onto finer-time-step annual cycle. 

c        Interpolate monthly tmon,pmon to dtimed-interval ta,pa

      call intdrive (tmon, pmon, ta, pa,
#  if defined (LOVECLIP)
c    *               qmon, qa,      ! use Loveclip's dwnd sfc solar rad 
     *               qmon, qadum,   ! keep TOA insol from zencal
#  endif
     *               nspy, dtimed)

#  if defined (SURFINSOL)
c     interpolate qinsol and qrange vs. lat, to fine-time-step qa, qar:
      zj = (alatd(i,j) + 90.) / dlatq
      ja = nint (zj)
      jb = ja + 1
      zfa = jb - (zj+0.5)
      ja = max (1, min (nlatq, ja))
      jb = max (1, min (nlatq, jb))
      do m=1,nspy  
        qa(m)  = zfa*qinsol(m,ja) + (1.-zfa)*qinsol(m,jb)
        qar(m) = zfa*qrange(m,ja) + (1.-zfa)*qrange(m,jb)
      enddo
#  endif

c        Lapse rate correction from climate data's topog to ice hs 
c        (Searise, GCM, RCM, Loveclip), for air temp, and precip 
c        if requested. Includes SUBGRIDEDGE topog vars if used. 

      do m=1,nspy
c       zwe = min (1., max (0., (hs-1000.)/1000.))
c       zdt = -((1.-zwe)*rlapse + zwe*.0030) * (hs-tog)
        zdt = - rlapse*(hs-tog)
        ta(m) = ta(m) + zdt
        if (tlapseprecip.ne.0.) then
          pa(m) = pa(m) * (2.**(zdt/tlapseprecip))  ! Ritz et al, 2001 ?
c         pa(m) = pa(m) * exp  (zdt/tlapseprecip)   ! Huybr, PPP, 1991 ?
        endif
      enddo
c        sdt is std. dev. of temps, passsed to degree_day.
c        If dtimed < 86400 (tadiurn) and/or TASYNOP are used, perhaps 
c        should specify smaller SDT (associated s.d.'s are 
c        tadiurn/(2^1.5) and tasynop/(2^1.5)). 
c        nb: If SURFMODEL2, SURFINSOL, and dtimed < 86400, degree_day 
c        is not called in surfmodel2 so sdt is not used.

#  if defined SDT
      sdt = SDT
#  else
      sdt = 5.                      ! as old standard model (surfmodel3)
#  endif

c        If sub-diurnal timestep (dtimed) used, superimpose
c        diurnal cycle on ta, with max at 14:00 hrs, min 2:00 hrs.
c        Full max-min amplitude is TADIURN (default=10 C).
c        This will correlate with qa cycles if SURFINSOL is used.

c------------------------------------
      if (nint(dtimed).lt.86400) then
c------------------------------------
#  if defined (TADIURN)
        tadiurn = TADIURN
#  else
        tadiurn = 10. 
#  endif
        do m=1,nspy
          zsecdy = mod ((m-.5)*dtimed, 86400.)
          ta(m) = ta(m) + 0.5 * tadiurn
#  if defined (SURFINSOL)
c    *                    * min (1., qar(m)/1000.)               !777777
#  endif
     *                    * cos (2.*pi*(zsecdy-14.*3600.)/86400.)
        enddo
c----------
      endif
c----------

c        Superimpose "synoptic" variation (ampl. TASYNOP, 10 day period)
        
#  if defined (TASYNOP)
      do m=1,nspy
        ta(m) = ta(m) + 0.5 * TASYNOP
     *                  * cos (2.*pi*(m-.5)*dtimed/(10.*86400.))
      enddo
#  endif

c>>>>>>>>>>>>>>>>>>>
c     SURFMODEL1:
c       One-step model: annual cycle with explicit snow and ice amounts,
c       based on refreezing fraction (sim. to Robinson et al.,TC,2010).
c     SURFMODEL2:
c       One-step model: annual cycle with explicit solid snow and 
c       embedded liquid amounts in pore space.
c     SURFMODEL3 (default):
c       Two-step model: (1) annual cycle for pdd, etc. 
c       (2) refreezing correction based on annual quantities.
c     Multiple annual cycles (nyear) to spin up snow, etc; use last one.

#  if defined (NYEAR)
      nyear = NYEAR
#  else
      nyear = 0
#  endif

#  if defined (SURFMODEL1)
      if (nyear.eq.0) nyear = 4
      call surfmodel1 (
#  elif defined (SURFMODEL2)
      if (nyear.eq.0) nyear = 4
      call surfmodel2 (
#  else 
      if (nyear.eq.0) nyear = 2
      call surfmodel3 (                 ! default, as old standard model
#  endif
     *                 ta, pa,
#  if defined (SURFINSOL) 
     *                 qa, qar,
#  endif
     *                 budgsnow, budgrain, budgmelt, budgevap, 
     *                 hs, tsurf, tsurfi, 
     *                 sdt, nspy, dtimed, nyear, i, j
     *                 )
c>>>>>>>>>>>>>>>>>>>

c End of overall surface budget options 

c~~~~~
#endif
c~~~~~

#if defined (LOVECLIP) 
c     set annual mean evaporation.                               dp 3/23
c     (evap is ignored by all surfmodel[1,2,...], which set budgevap=0).
c     (emon is 0 except LOVECLIM).
c     (nb: For LOVEANOM, evap is not corrected (emonctl not used),
c     becaue there is no available modern observed evap dataset).
      evsurf = 0.
      do m=1,nmon
        evsurf = evsurf + emon(m)*ndaypm(m)/365.
      enddo
      budgevap = evsurf 
#endif

c        Convert water mass (m/y of liq equiv) to m/y of ice, as needed 
c        in icedyn. All climate-model (GCM,RCM,RACMO,Loveclim) precip
c        is provided in m/y liq. SeaRise data precip is in m/y ice, 
c        but was multiplied by rhoice/1000 in iceclimparam.F, converted
c        back to ice equiv here.

      budgsnow = budgsnow * (1000./rhoice)
      budgrain = budgrain * (1000./rhoice)
c     do also for evap,melt, assuming treatments above yield liq equiv: 
      budgevap = budgevap * (1000./rhoice)
      budgmelt = budgmelt * (1000./rhoice)

#if defined (NOSURFACEWATER)
      budgsnow = budgsnow + budgrain
      budgrain = 0.
      budgmelt = 0.
      tsurf = min (tsurf, tmelt)
      tsurfi = min (tsurfi, tmelt)
#endif

      return
      end

c-----------------------------------------------------------------------

      subroutine intdrive (tmon, pmon, ta, pa, 
#if defined (LOVECLIP)
     *                     qmon, qa,
#endif
     *                     nspy, dtimed)  

c     Linearly interpolate monthly tmon, pmon to dtimed-interval ta, pa 

#include <comicephys.h>
#include <comicegrid.h>

      dimension tmon(nmon), pmon(nmon), ta(nspy), pa(nspy)
#if defined (LOVECLIP)
      dimension qmon(nmon), qa(nspy)
#endif

      dimension ndaypm(nmon), daymid(0:nmon+1)
      data ndaypm /31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31/
      parameter (nspymax=10000)
      dimension 
     *  imona(nspymax), imonb(nspymax), wmona(nspymax), wmonb(nspymax) 
      save imona, imonb, wmona, wmonb

      logical firstintdrive
      data firstintdrive /.true./
      save firstintdrive

c        Set indices and weights from dtimed intervals to monthly midpts

c----------------------------
      if (firstintdrive) then
c----------------------------

        if (nspy.gt.nspymax) then
          write (6,'(/a,2i8)') 
     *      '*** Error (intdrive): nspy > nspymax:', nspy, nspymax 
          stop
        endif
          
        daymid(0) = -0.5*ndaypm(nmon) 
        daymid(1) =  0.5*ndaypm(1) 
        do im=2,nmon
          daymid(im) = daymid(im-1) + 0.5*(ndaypm(im-1)+ndaypm(im))  
        enddo
        daymid(nmon+1) = 365. + 0.5*ndaypm(1) 

        do k=1,nspy
          zday = (k-0.5)*dtimed/86400.
          do im=1,nmon+1
            if (zday.le.daymid(im)) then
              wmona(k) = (daymid(im)-zday) / (daymid(im)-daymid(im-1))
              wmonb(k) = 1. - wmona(k)
              imona(k) = im-1
              imonb(k) = im
              if (imona(k).eq.0) imona(k) = nmon
              if (imonb(k).eq.nmon+1) imonb(k) = 1
              goto 100
            endif
          enddo
  100     continue
c         write (ioterm,'(a,i4, f8.2, 2i4, f8.3)') 
c    *      'intdrive: ', k, zday, imona(k), imonb(k), wmona(k)
        enddo

        firstintdrive = .false.
c----------
      endif
c----------

c        Interpolate monthly tmon,pmon to dtimed-intervals

      do k=1,nspy
        ta(k) = wmona(k)*tmon(imona(k)) +  wmonb(k)*tmon(imonb(k))
        pa(k) = wmona(k)*pmon(imona(k)) +  wmonb(k)*pmon(imonb(k))
#if defined (LOVECLIP)
        qa(k) = wmona(k)*qmon(imona(k)) +  wmonb(k)*qmon(imonb(k))
#endif
      enddo

      return
      end

c-----------------------------------------------------------------------

      subroutine surfmodel1 (ta, pa, 
#if defined (SURFINSOL) 
     *                       qa, qar,
#endif
     *                       budgsnow, budgrain, budgmelt, budgevap, 
     *                       hs, tsurf, tsurfi, 
     *                       sdt, nspy, dtimed, nyear,i,j)

c     One-step model: annual cycle with explicit snow and ice,
c     based on refreezing fraction (rf). Similar to Robinson et al.  
c     (The Cryo.,2010). Snow amount (snowm) includes refrozen 
c     snow+rain, and ice amount (sicem) is the ice-sheet column from 
c     the previous year. But correct Robinson et al. by: 
c     (i)  include rain (same treatment as snowmelt).
c     (ii) change their Eq. 12a to d(hi)/dt = 0 if hs > 0, because 
c          Ms*rf has already been added to snow (hs) in Eq. 11 (??).
c   
c     Returned: budgsnow is snowfall, budgrain is rain, budgmelt is 
c     surface melt allowing for refreezing, budgevap (= 0).
c     Uses separate pdd coefficients for snow and ice (ratsno,ratice, 
c     set below). If SURFINSOL, atmos melt is computed not as pdd, 
c     but as a linearized surface energy flux equation.
 
#include <comicephys.h>
#include <comicegrid.h>

      dimension ta(nspy), pa(nspy)
#if defined (SURFINSOL) 
     *         ,qa(nspy), qar(nspy)
#endif

c     degree-day coefficients (kg/m2/deg C day):
c     parameter (ratsno = 3.5, ratice = 8.16) ! Ritz, CD, 1997
      parameter (ratsno = 3.0, ratice = 8.0)
      parameter (rhosno = 250.)  ! snow density, kg/m3
      parameter (rmax = 0.6)
      parameter (hsnorm = .15)

c        Zero initial snow and ice amounts
c        (carried over from year to year)

      snowm = 0. ! snow amount (kg/m2)
      sicem = 0. ! ice amount (kg/m2)

c        Loop over years

c---------------------
      do iyear=1,nyear
c---------------------

c          Zero annual accumulators

        araina = 0. ! annual rainfall (kg/m2)
        asnowa = 0. ! annual snowfall (kg/m2)
        taira  = 0. ! annual air temp (K)
        ticea  = 0. ! annual ice temp (K)
        runof  = 0. ! annual runoff (kg/m2)
        refroz = 0. ! annual refrozen snow and rain (kg/m2)
        tmassa = snowm + sicem ! total snow+ice amount (kg/m2)

c          Loop over timesteps through one year

c------------------
        do k=1,nspy
c------------------

c         diurnal+synoptic, degree_day (erf):
          call degree_day (dtimed, ta(k), pdd, qdd, tmelt, sdt)

c         fraction of snow in precip, Robinson et al (2010) p. 132:
          ztt = max (-7., min (7., ta(k)-tmelt))
          as2p = 0.5 * ( 1. + sin(((ztt+7.)/14. + 0.5)*pi) )
          qdd = as2p ! override degree_day

c         raa is rainfall, sna is snowfall:
          raa = (1.-qdd) * pa(k)*1000./(365.*86400.)  ! m/yr to kg/m2/s
          sna =     qdd  * pa(k)*1000./(365.*86400.)  ! m/yr to kg/m2/s

c         snow-covered areal fraction:
          zs = max (0., min (1., snowm/(rhosno*hsnorm) ))
#if defined (SURFINSOL)
          zalb = (1.-zs)*0.50 + zs*0.80            ! weighted sfc albedo
          ztrans = 0.5
          dmelm = max (0.,                             ! tot melt, kg/m2
     *                 10.*(ta(k)-tmelt)
     *                 + ztrans*(1.-zalb)*qa(k)
     *                 - 20.
     *                ) * dtimed / hfus
#else
          zrat = zs*ratsno  + (1.-zs)*ratice       ! weighted pdd coeff
          dmelm = zrat*pdd                         ! tot melt, kg/m2
#endif

c         set refreezing fraction for melt (Robinson et al., 2010):
          zwei = max (0., min (1., ((snowm/rhosno)-1.)/1. ))
          rf = rmax*as2p*(1.-zwei) + 1.*zwei
          if (snowm/rhosno.lt.1.e-6) rf = 0. ! Robinson et al., 2010

          snowm = snowm + dtimed*sna       ! add snowfall to snow amount
          dsnowm = min (dmelm,snowm)       ! set snowmelt
          dmelm = dmelm - dsnowm           ! decrement total atmos melt
          snowm = snowm - dsnowm           ! reduce snow amount
     *                  +  rf*(dsnowm + dtimed*raa)
          sicem = sicem - dmelm            ! reduce ice amount

          runof = runof + (1.-rf)*(dsnowm + dtimed*raa) + dmelm

          refroz = refroz + rf*(dsnowm + dtimed*raa)  ! refroz snow+rain

c            Reset some snow to ice if snow column exceeds 5 m

          if (snowm .gt. rhosno*5.) then
            sicem = sicem + (snowm - rhosno*5.)
            snowm = rhosno*5.
          endif

c            Increment annual snowfall, rainfall (kg/m2)

          araina = araina + dtimed*raa
          asnowa = asnowa + dtimed*sna
          taira  = taira  + ta(k)/nspy
          ticea  = ticea  + min(ta(k),tmelt)/nspy  ! needed for therm

c------------
        enddo ! timestep loop
c------------
        tmassb = snowm + sicem
c----------
      enddo   ! year loop
c----------

      ablata = runof          ! melted snow+ice that runs off (kg/m2/yr)
      terr = asnowa + araina - (tmassb-tmassa) - runof

c        Transfer to budg* for ice model, converting flux units 
          
      budgsnow = asnowa*.001                          ! kg/m2/yr to m/yr
      budgrain = araina*.001                          ! kg/m2/yr to m/yr
      budgmelt = ablata*.001                          ! kg/m2/yr to m/yr
      budgevap = 0.

c     also returned (deg K):
      tsurf  = taira
c     tsurfi = ticea
c     Robinson et al: effect of refreezing on upper temp for ice model:
      tsurfi = min (taira,tmelt) + 29.2*(refroz/rhoice)
      tsurfi = min (tsurfi,tmelt)

      return
      end

c-----------------------------------------------------------------------

      subroutine surfmodel2 (ta, pa, 
#if defined (SURFINSOL) 
     *                       qa, qar,
#endif
     *                       budgsnow, budgrain, budgmelt, budgevap, 
     *                       hs, tsurf, tsurfi, 
     *                       sdt, nspy, dtimed, nyear,i,j)

c     One-step model: annual cycle with explicit solid snow (snowm) 
c     and embedded liquid (sliqm) amounts in pore space. Runoff
c     escapes from snowpack only when the snowpack is saturated
c     with embedded liquid (no air), and further melting occurs. 
c   
c     The ice amount (sliqm) does *not* include previous year's  
c     underlying ice column. The latter can be melted if enough melt
c     energy, so to keep track of mass budget (for conservation check,  
c     terr), an ice-sheet column mass is used (sice). 
c   
c     Returned: budgsnow is snowfall, budgrain is rain, budgmelt is 
c     surface melt allowing for refreezing, budgevap (= 0).
c     Uses separate pdd coefficients for snow and ice (ratsno,ratice, 
c     set below). If SURFINSOL, atmos melt is computed not as pdd, 
c     but as a linearized surface energy flux equation.
 
#include <comicephys.h>
#include <comicegrid.h>

      dimension ta(nspy), pa(nspy)
#if defined (SURFINSOL) 
     *         ,qa(nspy), qar(nspy)
#endif

c     degree-day coefficients (kg/m2/deg C day):
c     parameter (ratsno = 3.5, ratice = 8.16) ! Ritz, CD, 1997
      parameter (ratsno = 3.0, ratice = 8.0)
      parameter (rhosno = 250.)  ! snow density, kg/m3
      parameter (rholem = 1000.) ! embedded-liquid density, kg/m3
      parameter (ffreez = 1.)    ! fraction of surface (winter) cooling
                                 ! that refreezes
      parameter (hsnorm = .15)

      logical firstdump
      data firstdump /.true./

c        Zero initial solid-snow and embedded-liquid amount (kg/m2)
c        (carried over from year to year)

      snowm = 0.      ! snow mass (kg/m2)
      sliqm = 0.      ! embedded ice mass (kg/m2)
      sice  = 910.*1000. ! ice below model, just to check conserv.

c        Loop over years

c---------------------
      do iyear=1,nyear
c---------------------

c          Zero annual accumulators

        araina = 0.   ! annual rainfall (kg/m2)
        asnowa = 0.   ! annual snowfall (kg/m2)
        taira  = 0.   ! annual air temp (K)
        ticea  = 0.   ! annual ice temp (K)
        runofs = 0.   ! annual runoff due to saturated emb.liq. (kg/m2)
        runofi = 0.   ! annual runoff due to prev.yr ice sfc.melt(kg/m2)
        tmassa = snowm + sliqm + sice ! total snow_emb.liq. mass (kg/m2)

c          Loop over timesteps through one year

c------------------
        do k=1,nspy
c------------------

c---
c         Derivation of expression for sliqmax (liquid mass within
c         snow if saturated, i.e., max embedded liquid capacity, kg/m2):
c
c         snowm = rhosno*Vtot
c         assuming indiv. snow-crystal density=rholem:
c         Vvoid = (1-rhosno/rholem)**Vtot
c         sliqmax = rholem*Vvoid
c                 = rholem*(1-rhosno/rholem) * (snowm/rhosno)
c                 = (rholem/rhosno-1)*snowm

#if defined (SNOWCRIT)
c         max snow depth (kg/m2) avail for embedded liq:        ! 777777
          snowcrit = SNOWCRIT
#else
c         snowcrit = 200.                                       ! 777777
          snowcrit = 1000.                                      ! 777777
#endif

c         set maximum embedded-liquid capacity:
          sliqmax = min(snowm,snowcrit) * ((rholem/rhosno)-1.)
c---

c         snow-covered areal fraction:
          zs = max (0., min (1., snowm/(rhosno*hsnorm) ))

c>>>>>>>>>>>>>>>>>>>>>>
#if defined (SURFINSOL)
c>>>>>>>>>>>>>>>>>>>>>>
#  if defined (ATRANS)
          ztrans = ATRANS
#  else
          ztrans =0.46 + .00006*hs              ! Robinson TC 2010 Eq.17
#  endif
#  if defined (AFAC)
          zafac = AFAC
#  else
          zafac = 10.
#  endif
#  if defined (CFAC)
          zcfac = CFAC
#  else
          zcfac = -50.
#  endif
          zl = max (0., min (1., sliqm/max(sliqmax,1.e-6))) ! liq/maxliq
c         zalb = (1.-zs)*0.5 + zs*(zl*0.60 + (1.-zl)*0.80)  ! sfc alb
          zalb = (1.-zs)*0.4 + zs*(zl*0.60 + (1.-zl)*0.80)  ! 777777

c---
c         basic, no sigma effect:
c         dmel =    ( 
c    *                  zafac*(ta(k)-tmelt)
c    *                + ztrans*(1.-zalb)*qa(k)
c    *                + zcfac
c    *              ) * dtimed / hfus
c
c         dmelm = max (0., dmel)               ! total atmos melt, kg/m2
c
c         freeze some emb. liquid if net atmos heat loss:
c         dmelf = max (0.,-ffreez*dmel)      ! total atmos freeze, kg/m2
c---

c-----------------------------------------
          if (nint(dtimed).lt.86400) then
c-----------------------------------------

c           no extra sigma (diurnal + synoptic cycle resolved):

            dmel = (   zafac*(ta(k)-tmelt)
     *               + ztrans*(1.-zalb)*qa(k)
     *               + zcfac 
     *             ) * dtimed / hfus

            dmelm = max (0., dmel)             ! total atmos melt, kg/m2
c           freeze some emb. liquid if net atmos heat loss:
            dmelf = max (0.,-ffreez*dmel)    ! total atmos freeze, kg/m2
#  if defined (DMELF)   
            dmelf = DMELF*dmelf ! 777777
#  else
c           dmelf = 0.2*dmelf   ! 777777
            dmelf = 0.5*dmelf   ! 777777
#  endif

            if (ta(k).gt.trainsnow) then
              qdd = 0.
            else
              qdd = 1.
            endif

c-------------
          else
c-------------

c           sigma (pdd) temp offset depends on (diurnal-mean) insol:

c           temp offset depends on insol:
            zt0 = tmelt - (ztrans*(1.-zalb)*qa(k) + zcfac) / zafac

            call degree_day (dtimed, ta(k), pdd, qdd, zt0, sdt)

            zday = dtimed/86400.
            dmelm = (zafac*pdd/zday) * dtimed/hfus
            dmelf = max ( 0., -zafac * ((ta(k)-ztoff) - pdd/zday) ) 
     *              * dtimed/hfus

c--------------
          endif
c--------------

c>>>>
#else
c>>>>
c         diurnal+synoptic, degree_day (erf):
          call degree_day (dtimed, ta(k), pdd, qdd, tmelt, sdt)

          zrat = zs*ratsno  + (1.-zs)*ratice       ! weighted pdd coeff
          dmelm = zrat*pdd                         ! tot melt, kg/m2

          dmelf = 0.
c         zday = dtimed/86400.
c         dmelf = max ( 0., -zrat * ((ta(k)-tmelt)*zday - pdd) ) 
c>>>>>
#endif
c>>>>>

c         raa is rainfall, sna is snowfall:
          raa = (1.-qdd) * pa(k)*1000./(365.*86400.)  ! m/yr to kg/m2/s
          sna =     qdd  * pa(k)*1000./(365.*86400.)  ! m/yr to kg/m2/s

          snowm = snowm + dtimed*sna          ! add snowfall
          sliqm = sliqm + dtimed*raa          ! add rainfall to emb.liq.

          dsnowm = min (dmelm,snowm)          ! solid-snow melt (kg/m2)
          snowm = snowm - dsnowm              ! decrease solid snow
          sliqm = sliqm + dsnowm              ! add to embedded liquid
          dmelm = dmelm - dsnowm              ! subtract from total melt

          dsliqm = min (dmelf,sliqm)          ! emb.liquid freeze(kg/m2)
          sliqm = sliqm - dsliqm              ! decrease embedded liquid
          snowm = snowm + dsliqm              ! add to solid snow

c         recompute maximum embedded-liquid capacity:
          sliqmax = min(snowm,snowcrit) * ((rholem/rhosno)-1.)

c         if embedded liquid exceeds maximum, some runs off:
          if (sliqm.gt.sliqmax) then
            runofs = runofs + (sliqm-sliqmax)          ! kg/m2
            sliqm = sliqmax
          endif

c         if any total atmos melt (energy) left, melt prev-yr ice sfc:
          if (dmelm.gt.0.) then
            runofi = runofi + dmelm                   ! kg/m2 
            sice   = sice   - dmelm                   ! kg/m2
          endif

c            Increment annual snowfall, rainfall (kg/m2)

          araina = araina + dtimed*raa
          asnowa = asnowa + dtimed*sna
          taira  = taira  + ta(k)/nspy
          ticea  = ticea  + min(ta(k),tmelt)/nspy  ! needed for therm

#if defined (SURFINSOL)
c         diagnostic (for qa,qar, etc):
 
          if (i.eq.1 .and. j.eq.1) then  
             write (103,'(a,4i6,5f10.3)') 
     *         'surfmodel2:', iyear, i, j, k, 
     *         (k-.5)*dtimed/86400., ta(k)-tmelt, qa(k), qar(k), dmelm
          endif   
 
c         zlat1 = 75.1
c         zlon1 = -35.6
c         zlat2 = 82.9
c         zlon2 = -35.6

          zlat1 = 65.3
          zlon1 = -40.4
          zlat2 = 79.1
          zlon2 = -20.8
          if ( ( ( abs(alond(i,j)-zlon1).lt.0.2 .and.
     *             abs(alatd(i,j)-zlat1).lt.0.1 ) 
     *           .or.
     *           ( abs(alond(i,j)-zlon2).lt.0.2 .and.
     *             abs(alatd(i,j)-zlat2).lt.0.1 ) )
     *        .and. firstdump
     *       ) then
            if (abs(alatd(i,j)-zlat1).lt.0.1) iu = 104
            if (abs(alatd(i,j)-zlat2).lt.0.1) iu = 105
            if (k.eq.1) write (iu,*)
            write (iu,'(2f6.1, i3,f6.1,  3f7.2, 3f8.2, 2f8.2, 3f7.2)') 
     *        alatd(i,j), alond(i,j), 
     *        iyear, k*dtimed/86400.,
     *        snowm/1000., zs, zl,  
     *        ta(k)-tmelt, qa(k), qar(k),
     *        zafac*(ta(k)-tmelt), ztrans*(1.-zalb)*qa(k), 
     *        dmelm, runofs/1000., runofi/1000.
 
            if (abs(alatd(i,j)-zlat2).lt.0.1 .and. 
     *          iyear.eq.nyear .and. k.eq.nspy) firstdump = .false.
          endif
#endif

c------------
        enddo ! timestep loop
c------------
        tmassb = snowm + sliqm + sice
c----------
      enddo   ! year loop
c----------


c     melted snow+ice, and immed. rain,  that runs off (kg/m2/yr):
      ablata = runofs + runofi
      terr = asnowa + araina - (tmassb-tmassa) - (runofs+runofi)

c        Transfer to budg* for ice model, converting flux units 
          
      budgsnow = asnowa*.001                          ! kg/m2/yr to m/yr
      budgrain = araina*.001                          ! kg/m2/yr to m/yr
      budgmelt = ablata*.001                          ! kg/m2/yr to m/yr
      budgevap = 0.
c     also returned (deg K):
      tsurf = taira
      tsurfi= ticea

      return
      end

c-----------------------------------------------------------------------

      subroutine surfmodel3 (ta, pa, 
#if defined (SURFINSOL) 
     *                       qa, qar,
#endif
     *                       budgsnow, budgrain, budgmelt, budgevap, 
     *                       hs, tsurf, tsurfi, 
     *                       sdt, nspy, dtimed, nyear,i,j)

c     Two-step snow-ice surface mass balance model: 
c     (1) Run a basic time-stepped intra-annual snow/ice "model" 
c     through annual cycles (several, to spin up snow), just to get 
c     annual pdd, snowfall, rain, etc (not for snow thickness). 
c     (2) Do refreezing correction using total annual quantities.
c
c     Returned: budgsnow is snowfall, budgrain is rain, budgmelt is
c     surface melt allowing for refreezing, budgevap (= 0).
c     Uses separate pdd coefficients for snow and ice (ratsno,ratice,
c     set below). If SURFINSOL, atmos melt is computed not as pdd,
c     but as a linearized surface energy flux equation.

#include <comicephys.h>
#include <comicegrid.h>

      dimension ta(nspy), pa(nspy)
#if defined (SURFINSOL) 
     *         ,qa(nspy), qar(nspy)
#endif

c     degree-day coefficients (kg/m2/deg C day):
      parameter (ratsno = 3.5, ratice = 8.16) ! Ritz, CD, 1997
c     parameter (ratsno = 3.0, ratice = 8.0)  ! default
c     parameter (ratsno = 3.5, ratice = 10.0)  ! RD
      parameter (rhosno = 250.)  ! snow density, kg/m3
      parameter (rholem = 1000.) ! embedded-liquid density, kg/m3
      parameter (hsnorm = .15)

c============================================================
c     First step: seasonal cycle model to get annual pdd, etc
c============================================================

c        Zero initial snow thickness (carried over from year to year)

      hsnowa = 0.

c        Loop over years

c---------------------
      do iyear=1,nyear
c---------------------

c          Zero annual accumulators

        araina = 0. ! total rainfall (kg/m2)
        asnowa = 0. ! total snowfall (kg/m2)
        taira  = 0. ! surface air temperature (K)
        ticea  = 0. ! surface ice temperature (K)
        pdda   = 0. ! total positive-degree-days (deg C > 0 * day)
        dmela  = 0. ! total melt (kg/m2)

c          Loop over timesteps through one year

c------------------
        do k=1,nspy
c------------------

c         Simple one-level slab "snow/ice model", timestepping through 
c         an annual cycle. Seasonal cycle of snow thickness (hsnowa) is 
c         tracked very simply to distinguish which pdd-coefficient to 
c         use (ratsno or ratice) at each timestep. 
c
c         Units of precip in this "model" are kg/m2/sec. 
c         pa is passed as m/yr, converted below.
c         pdd calc (degree_day) allows for diurnal+synoptic variations.
c         If SURFINSOL, surface energy eqn is used instead of pdd:
c          qa = insolation (W/m2)

c         diurnal+synoptic, degree_day (erf):
          call degree_day (dtimed, ta(k), pdd, qdd,  tmelt, sdt)

c         raa is rainfall, sna is snowfall:
          raa = (1.-qdd) * pa(k)*1000./(365.*86400.)  ! m/yr to kg/m2/s
          sna =     qdd  * pa(k)*1000./(365.*86400.)  ! m/yr to kg/m2/s

          zs = max (0., min (1., hsnowa/hsnorm))   !fractional snow area
          zrat = zs*ratsno  + (1.-zs)*ratice       ! weighted pdd coeff

#if defined (SURFINSOL)
          zalb = (1.-zs)*0.50 + zs*0.80            ! weighted sfc albedo
          ztrans = 0.5
          dmelm = max (0.,                     ! total atmos melt, kg/m2
     *                 10.*(ta(k)-tmelt)
     *                 + ztrans*(1.-zalb)*qa(k)
     *                 - 20.
     *                 ) * dtimed / hfus
c         use pdd as "units change" only, so can use annual calcs below
          pdd =  dmelm/zrat
#else
          dmelm = zrat*pdd                     ! total atmos melt, kg/m2
#endif

          tice = min (ta(k), tmelt)    ! needed for therm

c            Increment snow thickness
 
          hsnowa = hsnowa + sna*dtimed/rhosno
          if (hsnowa.gt.0.) hsnowa = hsnowa 
c    *               + (raa*dtimed - dmelm)/rhosno
     *               + (           - dmelm)/rhosno ! rain passes through
                                                   ! in this 1st step
          hsnowa = max (hsnowa, 0.)

c            Check min/max surface temperatures (test for blowup)

          if (tice.lt.tmelt-120.) then
             write (ioterm,273) iyear, k, (k-0.5)*dtimed/86400.,
     *                          tice-tmelt, i, j, alond(i,j), alatd(i,j)
  273        format('*** Warning (surfbudg): Extreme sfc temperature',
     *              ' at iyear=',i3,'   k=',i6,'   day=',f8.2
     *             /'   tice=',f10.2,'  at i,j=',2i4,'  lon,lat=',2f8.2)
c            call flush(ioterm)           ! doesn't work on linux/iguana
          endif

          if (tice.gt.tmelt+90.) then
             write (ioterm,273) iyear, k, (k-0.5)*dtimed/86400.,
     *                          tice-tmelt, i, j, alond(i,j), alatd(i,j)
c            call flush(ioterm)           ! doesn't work on linux/iguana
          endif

c            Increment annual snowfall, rainfall, melt (kg/m2)

          araina = araina + dtimed*raa
          asnowa = asnowa + dtimed*sna
          taira  = taira  + ta(k)/nspy
          ticea  = ticea  + tice/nspy
          pdda   = pdda   + pdd
          dmela  = dmela  + dmelm

c------------
        enddo ! timestep loop
c------------
c----------
      enddo   ! year loop
c----------

c================================================================
c     Second step: refreezing corrections using annual quantities
c================================================================

c Calculate annual budgets for last year,with correction for refreezing.
c Simple "model" using annual totals, dealing with refreezing in the 
c previous winter's snowpack. Should really be combined with seasonal 
c time loop above, and a multi-year firn model vs. z (future work). 

c>>>>>>>>>>>>>>>>>>>>
#if defined (NEWWAY3)
c>>>>>>>>>>>>>>>>>>>>

c Like surfmodel2, but with annual increments:

      snowm = asnowa                      ! snowfall to snow
      sliqm = araina                      ! rainfall to emb.liq.

      dsnowm = min (dmela,snowm)          ! solid-snow melt (kg/m2)
      snowm = snowm - dsnowm              ! decrease solid snow
      sliqm = sliqm + dsnowm              ! add to embedded liquid
      dmela = dmela - dsnowm              ! subtract from total melt

c     recompute maximum embedded-liquid capacity:
      sliqmax = max (1.e-6, snowm*(rholem/rhosno-1.))

c     if embedded liquid exceeds maximum, some runs off:
      if (sliqm.gt.sliqmax) then
        runofs = sliqm-sliqmax            ! kg/m2
        sliqm = sliqmax
      else
        runofs = 0.
      endif

c     if any total atmos melt (energy) left, melt prev-yr ice sfc:
      if (dmela.gt.0.) then
        runofi = dmela                   ! kg/m2
      else
        runofi = 0.
      endif

c     melted snow+ice, and immed. rain, that runs off (kg/m2/yr):
      ablata = runofs + runofi
      terr = 0.

c>>>>
#else
c>>>>

c As in current sheetshelf ice model.

c Here, imagine:
c
c (1) Previous year's surface is assumed to be pure ice (no firn model).
c (2) In winter: 
c     snowfall produces asnowa (kg/m2) snow layer (assuming no melt or 
c     rain in winter).
c (3) Then, in spring/summer/fall:
c (3a) First, liquid from rain+snowmelt saturates (some or all of) the 
c      snow-layer pore space, fraction 1-rsw. The amount (kg/m2) is 
c      zsuper. The amount from snowmelt alone is zsuperpdd, and
c      the pdd amount left over (still available for more melt) is 
c      subtracted from pdda (pdda - zsuperpdd/ratsno). The amount of 
c      rain that is used to saturate the snowpack (zsuper-zsuperpdd) is 
c      subtracted from annual rainfall (araina) and added to annual 
c      snowfall (asnowa).
c (3b) Any remaining pdda is used to melt the embedded snow in the
c      saturated snowpack. This releases not only the melted snow,
c      but also the embedded liquid around it (hence rate ratice/rsw).  
c      The released amount is zrunsno. The pdd amount used for this is 
c      subtracted from pdda. 
c (3c) Any remainin pdd is used to melt ice (previous year's surface,
c      now exposed).

      rsw = rhosno/1000.    ! solid-snow vol/total vol, = 1 - pore space

c (3a):
      zsuper    = min (asnowa*(1.-rsw), ratsno*pdda + araina)
      zsuperpdd = min (zsuper, ratsno*pdda)
      pdda      = pdda - zsuperpdd/ratsno
      araina    = araina - (zsuper-zsuperpdd)
      asnowa    = asnowa + (zsuper-zsuperpdd)
c (3b):
c     melt embedded snow in the saturated snowpack (at ratice/rsw rate):
      zrunsno = min (asnowa, (ratice/rsw)*pdda)
      pdda = pdda - zrunsno/(ratice/rsw)
c (3c):
c     melt ice below snow:
      zrunice = ratice*pdda

      ablata = zrunsno + zrunice         ! melted snow+ice that runs off
      terr = 0.

c>>>>>
#endif
c>>>>>

c        Transfer to budg* for ice model, converting flux units 
          
      budgsnow = asnowa*.001                          ! kg/m2/yr to m/yr
      budgrain = araina*.001                          ! kg/m2/yr to m/yr
      budgmelt = ablata*.001                          ! kg/m2/yr to m/yr
      budgevap = 0.
c     also returned (deg K):
      tsurf = taira
      tsurfi= ticea

      return
      end

c-----------------------------------------------------------------------

      subroutine degree_day (dt, ta, pdd, qdd, t0in, sdtin)

c        Degree-day parameterization, for 1 point, involving  
c        error function for normally-distributed diurnal/synoptic 
c        variability. Degree-day increments returned in pdd,
c        and snowfall/precip ratio in qdd.
c
c        t0 is zero-pdd temperature (deg K), and sdt is standard
c        deviation of temperature over period dt.

#include <comicephys.h>
#include <comicegrid.h>

      parameter (nerf=3000, xerf=3., derf = xerf/nerf)
      dimension erf(0:nerf)
      save erf, pisq

      logical first
      data first /.true./
      save first

c.......................................
c       Alternate very basic degree-day:
c       pdd = max (ta-t0, 0.) * (dt/86400.)
c       if (ta.gt.trainsnow) then
c         qdd = 0.
c       else
c         qdd = 1.
c       endif
c       return
c.......................................

#if defined (TPDD)
      t0 = t0in + TPDD
#else
      t0 = t0in
#endif

      sdt = max (0.1, sdtin)     ! protect 1/sdt,exp's below for sdtin=0

      sdt2 = sdt*sqrt(2.)

      if (first) then
        erf (0) = 0.
        do i=1,nerf
          if (i.eq.1) then
            zx  = 0.25*derf
            zdx = 0.5 *derf
          else
            zx  = (i-1)*derf
            zdx = derf
          endif
          erf(i)  = erf(i-1)  +   exp(-zx*zx)*zdx
        enddo
        pisq = sqrt(pi)
        first = .false.
      endif

c     positive degree days:
      ztm = ta - t0
      zx = abs(ztm/sdt2)
      ierf = max (1, min (nerf, nint(zx/derf + 0.5) ))
      zdd = 0.5*(sdt2/pisq) * exp(-(ztm/sdt2)**2)
     *   + (ztm/pisq) * (0.5*pisq + sign(1.,ztm)*erf(ierf))
      if (zdd.lt..001) zdd = 0.        !protect against roundoff error
      pdd = zdd*(dt/86400.)

c     snowfall:precip ratio:
      ztp = ta - trainsnow
      zx = abs(ztp/sdt2)
      ierf = max (1, min (nerf, nint(zx/derf + 0.5) ))
      zaop = (1./pisq) * (0.5*pisq - sign(1.,ztp)*erf(ierf))
      if (zaop.lt..001) zaop = 0.        !protect against roundoff error
      if (zaop.gt..999) zaop = 1.        !protect against roundoff error
      qdd = zaop

      return
      end

c-----------------------------------------------------------------------
