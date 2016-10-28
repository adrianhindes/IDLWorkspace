PRO NEBULA_KBPS, dens_arr	  ,rarr 	 , zarr ,beamlet  ,bhat ,n2pop   , $
	        chat=chat	  ,centre=centre , ntime=ntime    ,pslice=pslice , $
	        mastbeam=mastbeam ,tline=tline   , shot=shot	  ,narray=narray , $
	        bener=bener	  ,rpsi=rpsi	 , zpsi=zpsi	  ,temp=temp	 , $
	        dens=dens	  ,bmass=bmass   , element=element,bcurr=bcurr   , $
	        noplasma=noplasma ,frac_ions=frac_ions     ,visualbeam=visualbeam, $
	        div_beam_att=div_beam_att,entrance=entrance, btravel=btravel,$
		bemis_arr=bemis_arr,rotangle=rotangle,frac_hydrogen=frac_hydrogen,fakeshot=fakeshot,xx=xx,yy=yy,zz=zz,psi=psi
;----------------------------------------------------------------------------------
; Purpose : Beam Profile Shape code used in NEBULA
; Author  : Stuart Henderson
; Date    : May 2011
; Contact : stuart.henderson@ccfe.ac.uk
;----------------------------------------------------------------------------------
;-----------------------------------------------------------
; ***** User parameters *****
;-----------------------------------------------------------
; Get global defaults if not already specified
;-----------------------------------------------------------

default,mastbeam,'k1'
tline=[1.,1.1]
nebula_kbeam_defaults,pslice=pslice ,mastbeam=mastbeam ,shot=shot     ,ntime=ntime	,$
                     centre=centre ,chat=chat         ,narray=narray ,noplasma=noplasma ,$
	             btravel=btravel		      ,visualbeam=visualbeam	        ,$
	             div_beam_att=div_beam_att        ,entrance=entrance,rotangle=rotangle
;-----------------------------------------------------------
; Specify the beam parameters
;-----------------------------------------------------------
nebula_kbparam, shot	       , mastbeam	      , ntime	    , tline=tline,$
               bener=bener     , bvdrift=bvdrift      , bdens=bdens , bmass=bmass,$
               element=element , frac_ions=frac_ions  , bcurr=bcurr,frac_hydrogen=frac_hydrogen

;-----------------------------------------------------------
; Create your plasma, t_e, n_e, time
;-----------------------------------------------------------
if keyword_set(fakeshot) then shh=28280 else shh=shot
nebula_kplasmaconditions, shh      , tline     , rpsi=rpsi ,$
		         zpsi=zpsi , temp=temp , dens=dens,psi=psi
;-----------------------------------------------------------

; Find Line integrated density of plasma
;-----------------------------------------------------------
nebula_plasmaline,dens,rpsi,zpsi,intdens,tline			 
;-----------------------------------------------------------
; Make a grid through which the beam is interrogated
;-----------------------------------------------------------
nebula_kgrid, centre   ,chat	,pslice   ,tline   ,narray   ,beamlet ,rarr     ,zarr   ,$
             btravel  ,bdens    ,dens_arr ,darr    ,bhat     ,ispace  ,mastbeam ,entrance,$
	     diff     ,rotangle    ,xx=xx,yy=yy,zz=zz
;-----------------------------------------------------------
; The above routines can be bypassed by specifying a user
; input
;-----------------------------------------------------------
;-----------------------------------------------------------
; *** Now fire the beam into the plasma! ***
;-----------------------------------------------------------
nebula_beamplasma,rarr   , zarr , dens_arr , temp    , dens  ,$
                  rpsi   , zpsi , bener    , bvdrift , tline ,$
	          pslice , darr , beamlet  , n2pop   , bmass ,$
	          frac_ions     , element  , noplasma, ispace,$
	          div_beam_att  , intdens  , diff    , bemis_arr

;contourn2,dens_arr(*,*,10,0,0),/cb





END
;nebula_kbps

;end
