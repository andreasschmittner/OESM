! source file: /home/aschmitt/models/UVic2.9/git_test/myfork/UVic2.9/source/common/cpolar.h
!====================== include file "cpolar.h" =========================

!     polar transform coefficients used to transform velocities near
!     poles before filtering

      real spsin, spcos
      common /cpolar_r/ spsin(imt), spcos(imt)
