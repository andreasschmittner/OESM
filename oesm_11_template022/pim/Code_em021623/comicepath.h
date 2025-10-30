c comicepath.h

c     For Suns, must be in common (no substrings allowed with params).
c     For linux, must be parameters (multiply-defined errors with vars).

#if defined (SUN)
      common /cpathnamec/ cpathhome, cpathbed, 
     *                    cpathdrive, cpathdrivercm, cpathdriveobs,
     *                    cpathmap, cpathslgrid
#endif
      character*80 cpathhome, cpathbed, 
     *             cpathdrive, cpathdrivercm, cpathdriveobs,
     *             cpathmap, cpathslgrid

c-------------------------------------------------------------------
c     for empirical data files (time series, Ant precip, orbits...):
c-------------------------------------------------------------------
#if defined (SUN)
      data cpathhome /
#else
      parameter (cpathhome =
#endif

#if defined (SUN) || defined (IGUANA)
     *  '/iguana/s1/deconto/Ebm2d/Codesheetshelf/'

#elif defined (LION)
     *  '/gpfs/work/deconto/Sheetshelf_data/'

#elif defined (STELLA)
#  if defined (DECONTO)
     *  '/usr/data/deconto/Sheetshelf/'
#  else
     *  '/usr/data/deconto/Sheetshelf/'
#  endif

#elif defined (MAC)
     *  '/Users/deconto/Desktop/Sheetshelf/'

#elif defined (OSU)
     *  '/home/ mortenson/Dataicearea/'

#else
     *  '../'
#endif

#if defined (SUN)
     *  /
#else
     *  )
#endif

c----------------------------
c     for BEDMAP1 data files:
c----------------------------
#if defined (SUN)
      data cpathbed /
#else
      parameter (cpathbed =
#endif

#if defined (SUN) || defined (IGUANA)
     *  '/iguana/s1/deconto/Ebm2d/Codesheetshelf/Data_bedmap1/'

#elif defined (LION)
     *  '/gpfs/work/deconto/Bedmap/'

#elif defined (STELLA)
#  if defined (DECONTO)
     *  '/usr/data/deconto/Bedmap/'
#  else
     *  '/usr/data/deconto/Bedmap/'
#  endif

#elif defined (MAC)
     *  '/Users/deconto/Desktop/Sheetshelf/Bedmap/'

#else
     *  '../Bedmap1/'
#endif

#if defined (SUN)
     *  /
#else
     *  )
#endif

c---------------------------
c     for GCM driving files:
c---------------------------
#if defined (SUN)
      data cpathdrive /
#else
      parameter (cpathdrive =
#endif

#if defined (SUN) || defined (IGUANA)
     *  '/iguana/s1/deconto/Ebm2d/Codesheetshelf/Driveice/Gcm/'

#elif defined (LION)
     *  '/gpfs/work/deconto/Driveice/Gcm/'

#elif defined (STELLA)
#  if defined (DECONTO)
     *  '/usr/data/deconto/Driveice/Gcm/'
#  else
     *  '/usr/data/deconto/Driveice/Gcm/'
#  endif

#elif defined (MAC)
     *  '/Users/deconto/Desktop/Sheetshelf/Gcm/'

#else
     *  '../Driveice/Gcm/'
#endif

#if defined (SUN)
     *  /
#else
     *  )
#endif

c---------------------------
c     for OBS driving files:
c---------------------------
#if defined (SUN)
      data cpathdriveobs /
#else
      parameter (cpathdriveobs =
#endif

#if defined (SUN) || defined (IGUANA)
     *  '/iguana/s1/deconto/Ebm2d/Codesheetshelf/Driveice/Obs/'

#elif defined (LION)
     *  '/gpfs/work/driveice/Driveice/Obs/'

#elif defined (STELLA)
#  if defined (DECONTO)
     *  '/usr/data/deconto/Driveice/Obs/'
#  else
     *  '/usr/data/deconto/Driveice/Obs/'
#  endif

#elif defined (MAC)
     *  '/Users/deconto/Desktop/Sheetshelf/Obs/'

#else
     *  '../Driveice/Obs/'
#endif

#if defined (SUN)
     *  /
#else
     *  )
#endif

c---------------------------
c     for RCM driving files:
c---------------------------
#if defined (SUN)
      data cpathdrivercm /
#else
      parameter (cpathdrivercm =
#endif

#if defined (SUN) || defined (IGUANA)
     *  '/iguana/s1/deconto/Ebm2d/Codesheetshelf/Driveice/Rcm/'

#elif defined (LION)
     *  '/gpfs/work/deconto/Driveice/Rcm/'

#elif defined (STELLA)
#  if defined (DECONTO)
     *  '/usr/data/deconto/Driveice/Rcm/'
#  else
     *  '/usr/data/deconto/Driveice/Rcm/'
#  endif

#elif defined (MAC)
     *  '/Users/deconto/Desktop/Sheetshelf/Rcm/'

#else
     *  '../Driveice/Rcm/'
#endif

#if defined (SUN)
     *  /
#else
     *  )
#endif

c---------------------------------------
c     for Genesis global map data files:
c---------------------------------------
#if defined (SUN)
      data cpathmap /
#else
      parameter (cpathmap =
#endif

#if defined (SUN) || defined (IGUANA)
     *  '/iguana/s1/deconto/Genesis.3.0/Datafiles/'

#elif defined (LION)
     *  '/gpfs/home/deconto/Genesis.3.0/Datafiles/'

#elif defined (TERRA)
#  if defined (DECONTO)
c    *  '/usr/data/deconto/Genesis.3.0/Datafiles/'
     *  '/usr/data/deconto/Datafiles/' 
#  else
c    *  '/usr/data/deconto/Genesis.3.0/Datafiles/'
     *  '/usr/data/deconto/Datafiles/'
#  endif

#elif defined (MAC)
     *'/Users/deconto/Desktop/Sheetshelf/Genesis.3.0/Datafiles/'

#else
     *  '../Genesis.3.0/Datafiles/'
#endif

#if defined (SUN)
     *  /
#else
     *  )
#endif

c------------------------------------------------------------
c     for Gomez-Mitrovica bedrock model files (permanent area, 
c     only for Gridfiles, in bedrock_sl). 
c------------------------------------------------------------

#if defined (SUN)
      data cpathslgrid /
#else
      parameter (cpathslgrid =
#endif

#if defined (SUN) || defined (IGUANA)
     *  '/iguana/s1/deconto/Gomez/SEANEW/'

#elif defined (LION)
     *  '/gpfs/home/deconto/Gomez/SEANEW/'

#elif defined (MAC)
     *  '/home/ng50/coupled_code/Sheetshelf/SEANEW/'

#else

     *  '../Gomez/SEANEW/'
#endif

#if defined (SUN)
     *  /
#else
     *  )
#endif

