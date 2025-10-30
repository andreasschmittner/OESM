! source file: /data2/aschmitt/models/OESM/0.1/oesm_11_t020_short/uvic/updates/riv.h
!======================== include file "riv.h" =========================

!     parameters for use in the river model

!     maxnb   = maximum number of basins
!     nb      = number of basins
!     nbp     = number of basin points per basin
!     ndp     = number of discharge points per basin
!     ndis    = map of discharge points
!     nrfill  = map of filled river numbers (extrapolated over water)
!     nriv    = map of river (basin) numbers
!     psum    = total discharge for a basin
!     psum_nomskd = total unmasked discharge for a basin
!     wdar    = discharge weights over discharge area
!     ta_psum = time average total discharge for a basin
!     ta_psum_unmskd = time average total unmasked discharge for a basin
! ericmod adding fwf for coupled model (3 line below)
!     fwf     = freshwater flux forcing (obsolete)
!     runliq  = meltwater release from ice sheet
!     runfrz  = ice (frozen meltwater?) release from ice sheet

      integer maxnb
      parameter (maxnb=200)

      integer nb, nbp, ndp, ndis, nrfill, nriv
      common /river_i/ nb, nbp(maxnb), ndp(maxnb), ndis(imt,jmt)
      common /river_i/ nrfill(imt,jmt), nriv(imt,jmt)

! ericmod adding runliq,runfrz for coupled model (1st and 3rd lines below)
      real psum, wdar, ta_psum, runliq, runfrz
      real psum_unmskd, ta_psum_unmskd
      common /river_r/ psum(maxnb), wdar(imt,jmt)
      common /river_r/ psum_unmskd(maxnb)
      common /river_r/ runliq(imt,jmt), runfrz(imt,jmt)
!      real psum, wdar, ta_psum
!      common /river_r/ psum(maxnb), wdar(imt,jmt)
      common /river_r/ ta_psum(maxnb)
      common /river_r/ ta_psum_unmskd(maxnb)
