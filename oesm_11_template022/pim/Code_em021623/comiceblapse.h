c     Statement function for effect on framp (below) of: 
c       topbedeq (hbeq),
c       std dev sub-grid topog (hbsd), 
c       mean sub-grid slope ampl (hbsl).
c     (nb: hbsd,hbsl are zero except with -DEISANTA, SEARISEINIT)

#if defined (NOBLAPSE)

      blapse(zhbeq, zhbsd, zhbsl) = 0.0

#else

c     hbeq:
c     blapse (zhbeq, zhbsd, zhbsl) = 0.03 * max (0.,zhbeq-1500.)
c     blapse (zhbeq, zhbsd, zhbsl) = 0.10 * max (0.,zhbeq-1800.)
c     blapse (zhbeq, zhbsd, zhbsl) = 0.20 * max (0.,zhbeq-1800.)  ! zz8
c     blapse (zhbeq, zhbsd, zhbsl) = 0.05 * max (0.,zhbeq-1800.)  ! zz9

c     hbsd:
c     blapse (zhbeq, zhbsd, zhbsl) = 0.10 * max (0.,zhbsd-200.)

c     hbsl:
c     blapse (zhbeq, zhbsd, zhbsl) = 200. * max (0.,zhbsl-.02)

c     combo (hbeq, hbsl, don't use hbsd)
c     nb: Gamburtsevs: hbsl ~zero (!), hbeq = 1800 to 2500.
c         Other mtns:  hbsl ~.02 to 1, hbeq < 1800. 
      blapse (zhbeq, zhbsd, zhbsl) = 0.05 * max (0.,zhbeq-1700.)  ! zz11
     *                             + 500. * max (0.,zhbsl-.02)    ! zz11

#endif

c------

c     Statement function for areal fraction (0-1) of unfrozen base.
c     Uses linear ramp vs. homologous basal temp, and influence of 
c     subgrid mountain topography (blapse, above).

#if defined (TRAMP)
      parameter (tramp = TRAMP)
#else
c     parameter (tramp = 0.5)
      parameter (tramp = 3.)
#endif

c     blapse affects basal temperature:
c     framp(zt, zb) = min (1.,max (0., (zt + zb + tramp)/ tramp))
c     blapse affects tramp:
      framp(zt, zb) = min (1.,max (0., (zt + zb + tramp)/ (zb + tramp)))

