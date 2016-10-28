;; c     $Date: 2000/03/11 00:01:29 $ $Author: lao $
;; c     @(#)$RCSfile: exparm.inc&v $ $Revision: 1.6 $
;; c
;; c-------------------------------------------------------------------
;; c--  New E-coil connections                       LLao& 95/07/11  --
;; c--  Add 8 new probes for radiative divertor      LLao& 97/03/17  --
;; c--  Update MSE to 35 channels                    LLao& 97/04/21  --
;; c--  Separate machine dependent configuration                     --
;; c--  	parameters from eparmdx.for		  QPeng&97/09/24  --
;; c--	added ntangle for toroidal x-ray	  QPeng&98/05/12  --
;; c--  Increase MSE channels from 35 to 36                98/12/01  --
;; c-------------------------------------------------------------------
;; c
;; c     magpri67	number of magnetic detectors at toroidal angle "1"
;; c     magpri322	number of magnetic detectors at toroidal angle "2"
;; c     magprirdp number of magnetic detectors for radiative divertor
;; c     magpri	total number of magnetic detectors
;; c     mpress	number of pressure data points
;; c     mse315
;; c     mse45
;; c     mse15
;; c     nstark	total number of mse channels
;; cheng necein    total number of ece channels
;; c     nacoil	number of advance divertor coils
;; c     nangle	dimension of poloidal sxr& first part of xangle&zxray&rxray
;; c     ntangle	dimension of toroidal xray& last part of xangle&zxray&rxray
;; c     necoil	number of ohmic heating coils
;; c     nesum	number of p.f. coil groups
;; c     nfbcoil	(obsolete)
;; c     nfcoil	number of p.f. coils
;; c     nlimbd	number of 'outer' limiter points
;; c     nlimit	maximum number of limiter points
;; c     nsilop	number of flux loops
;; c     nvesel	number of vessel segements
;; c

;      ;necoil=1&nvesel=46&nvapf=0&mpress=132
      necoil=1&nvesel=1&nvapf=18&mpress=132
      nfcoil=12+nvapf&mfcoil=16+nvapf&nsilop=45
;      ;@nfcoil=7&mfcoil=14&nsilop=5
      nrogow=1&nacoil=1
      nesum=1
      magpri67=1&magpri322=81&magprirdp=0&magudom=0
      magpri=magpri67+magpri322+magprirdp+magudom
      mse315=2&mse45=0&mse15=0&mse1h=0&mse315_2=0
      libim=0
      nmtark=mse315+mse45+mse15+mse1h+mse315_2
      nstark=nmtark+libim
      nnece=1&nnecein=1&neceo=1
      nlimit=160&nlimbd=6
      nangle=64&ntangle=12
      nfbcoil=12

;c
;c   1997/10/09 00:01:35 peng
;c
;c  @(#)eparmdx.for&v 4.19
;c  
;      implicit integer*4 (i-n)& real*8 (a-h& o-z
;c
;c --- experiment dependant parameters
;c
;      include 'exparm.inc'
;c
;c --- general parameters
;c
      ntime=501
      ndata=61
      nwwcur=18
      nffcur=18&nppcur=18&npcurn=nffcur+nppcur
          &nercur=18& necur2=nercur*2
     mfnpcr=nfcoil+npcurn+nvesel+nwwcur+nesum+nfcoil             + nercur
     npcur2=npcurn*2
     nrsmat=nsilop+magpri+nrogow+nffcur+1+npcurn+nwwcur+      mpress+nfcoil+nstark
     nwcurn=nwwcur+npcurn&npcur3=npcurn*2
     nwcur2=nwcurn*2
      npoint=500
      nw=65&nh=65&nwnh=nw*nh
      nh2=2*nh&nwrk=2*(nw+1)*nh
      ncurrt=nvesel+nesum+nfcoil
      mbdry=1105
      nbwork=nsilop
      kxiter=250&mqwant=30
      msbdry=mbdry+nsilop+nfcoil+1&msbdr2=2*msbdry
      nrsma2=2*nrsmat
      nwwf=2*nw
      nwf=nwwf
      nxtram=10&nxtrap=npoint
;;@      nxtlim=9&nco2v=3&nco2r=2
      nxtlim=9&nco2v=1&nco2r=1  ;@ modified by K.-I. You
      kubicx = 4& kubicy = 4& lubicx = nw - kubicx + 1
           lubicy = nh - kubicy + 1
           kujunk = kubicx*kubicy*lubicx*lubicy
      modef=4& modep=4& modew=4 & kubics=4 
      icycred_loopmax=1290
      boundary_count=2*nh+2*(nw-2)
;c
;c --- common block for areas that store green tables and general inputs
;c
;      include 'expath.inc'



a=[0, 160.19138957679877, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 844.62095014307909, 0, 0, 0, 0, 0, 0, 840.59637466727713, 0, 0, 840.5465448586009, 0, 0, 844.89811657893279, 0, 0, 0, 0, 0, 0, 0, 0, 772.39873150264907, 0, 0, 0, 0, 0, 0, 159.96448566295115, 0]
   end
