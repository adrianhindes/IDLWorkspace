pro generate_signals,shot_sim,channels=channels,mode=mode,$
   ampmax=ampmax,add=add,nophoton=nophoton,$
	 frequency=frequency,sampletime=sampletime,trange=trange,matrix=matrix,over=over,$
   npoints=npoints,max_photon=max_photon,inttime=inttime,$
   decay=decay,width=width,period=period,output_sampletime=output_sampletime,$
   background_amp=background,background_time=background_time,no_files=no_files,$
   startz=startz,endz=endz
   
; Generates test signals for processing with correlation function
; calculation. Density fluctuations are generated and Li2p light fluctuations
; are calculated using the M transmission matrix.
; Signals are saved using wftwrite.pro
;
; npoints: number of time points/channel to generate (def:200000)
; chn: number of channels (def:24)
; mode=5: bumps at random positions with decay time
; /add: adds generated signals to end of the ones already on disk
; /nophoton: do not generate photon statistics
; multi: multiplication factor for original density profile
;        (uses 31920x<multi>_.mx file
;        (fluctuation profile will be nmultiplied accordingly)
; frequancy of test signal for mode=4 in Hz
; max_photon: number of detected photons/sec  for channel at maxiumum of Li2p profile
; inttime: integration time constant of amplifiers
; output_sampletime: sampletime for data output (a multiple of sampletime)
; background: background signal profile relative to maximum of 2p light profile
;              if scalar then constant background
; background_time: length of background time interval at the end of data (sec)
; /no_files: do not write final output files

pid=getpid()
tmpbase='tmp/sim_'+getenv('HOST')+'_'+i2str(pid)+'_'

if (not keyword_set(matrix)) then begin
  print,'Must specify matrix file!'
  return
endif  

default,background_time,0
default,background,0

default,mode,0  ; no fluctuation                 

default,sampletime,1e-6
default,output_sampletime,sampletime
if (output_sampletime ne sampletime) then $
        output_sampletime=round(output_sampletime/sampletime)*sampletime
if (not keyword_set(npoints)) then default,npoints,long((trange(1)-trange(0))/sampletime)
default,channels,defchannels(shot_sim)
default,chn,n_elements(channels)
default,nic_int,3e-6
default,max_photon,4e7
default,inttime,5e-7


if (not keyword_set(add)) then begin   
  if (!version.os eq 'linux') then begin 
    if (not mode eq 3) then begin
      maxpoints=long(40000) 
    endif else begin
      maxpoints=long(20000)
		endelse	
  endif else begin
    maxpoints=long(2e5)
	endelse	
  if (npoints gt maxpoints) then begin
	  points_left=npoints
		while (points_left ne 0) do begin
		  if (points_left gt maxpoints) then begin
			  if (points_left lt maxpoints*2) then begin
          np=points_left/2 
        endif else begin
          np=maxpoints
				endelse
			endif else begin		
		    np=points_left
			endelse
			if (points_left eq npoints) then begin  ; first piece
			  generate_signals,shot_sim,npoints=np,channels=channels,mode=mode,$
         ampmax=ampmax,nophoton=nophoton,$
         frequency=frequency,matrix=matrix,$
         max_photon=max_photon,inttime=inttime,$
         background_amp=background,background_time=background_time,/no_files,$
         over=over,trange=trange,sampletime=sampletime,output_sampletime=output_sampletime,$
         width=width,decay=decay,period=period,startz=startz,endz=endz
			endif else begin
        if (np eq points_left) then no_files=0 else no_files=1		
			  generate_signals,shot_sim,npoints=np,channels=channels,mode=mode,$
         ampmax=ampmax,nophoton=nophoton,$
         /add,frequency=frequency,matrix=matrix,$
         max_photon=max_photon,inttime=inttime,$
         background_amp=background,background_time=background_time,no_files=no_files,$
         over=over,trange=trange,sampletime=sampletime,output_sampletime=output_sampletime,$
         width=width,decay=decay,period=period,startz=startz,endz=endz
			endelse	
		  points_left=points_left-np
		endwhile
		return
	endif
endif			

SHOT=0
T=0
MULTI=0
ZEFF=0
M=0
Z_VECT=0
N0=0
Z0=0
P0=0
P0R=0
TE=0
LIZ=0
LINE=0
LIZ_2P=0
LI2P=0
LIZ_TE=0
LITE=0
TIMEFILE_MX=0
BACKTIMEFILE_MX=0
TEMPFILE=0
CAL=0
CHANNELS_MX=0
SMOOTH=0
PROBE_AMP=0
restore,'matrix/'+matrix

loadxrr,xrr
xrr=xrr(channels-1) 
z_vect=z_vect(where(z_vect le max(xrr)+1))
dens_chn=(size(z_vect))(1)
M=M(channels-1,0:dens_chn-1)

default,liz,z0
default,line,n0
n0=xy_interpol(liz,line,z_vect)/1e13
p0r=p0r(channels-1)

; mode=5 parameters
if (keyword_set(mode eq 5)) then begin
  default,width,1.5 ; cm
  default,startz,8.
  default,endz,max(z_vect)+3
  default,decay,6e-6 ; decay time
  default,period,6e-6
  default,ampmax,0.1
endif

; mode=6 parameters
if (keyword_set(mode eq 6)) then begin
  default,width,[1.5,2.] ; cm
  default,decay,[6e-6,2e-5] ; decay time
  default,period,[6e-6,2e-5]
  default,ampmax,[0.3,0.03]
  default,startz,[18,8]
  default,endz,[33,18]
endif
                                              

if ((size(background))(0) eq 0) then background=fltarr(chn)+background
data=fltarr(npoints,chn)
data_dens=fltarr(npoints,dens_chn)
if (mode eq 5) then begin
  width2=width^2
  for i=long(0),npoints-1 do begin
    if (randomu(seed) lt sampletime/period) then begin
	    z0=randomu(seed)*(endz-startz)+startz
	    pert=ampmax*width2/(width2+(z_vect-z0)^2)
      pert=pert < n0*0.7
      pert=pert > (-n0*0.7)
      for ii=i,(i+round(decay*3/sampletime)) < npoints-1 do begin
        data_dens(ii,*)=data_dens(ii,*)+pert*exp(-(ii-i)*sampletime/decay)
      endfor  
    endif    
	endfor	
endif
if (mode eq 6) then begin
  width2=width^2
  for j=0,1 do begin
    for i=long(0),npoints-1 do begin
      if (randomu(seed) lt sampletime/period(j)) then begin
  	    z0=randomu(seed)*(endz(j)-startz(j))+startz(j)
  	    pert=ampmax(j)*width2(j)/(width2(j)+(z_vect-z0)^2)
        pert(where(abs(z_vect-z0) gt width(j)*2))=0
        pert=pert < n0*0.7
        pert=pert > (-n0*0.7)
        for ii=i,(i+round(decay(j)*3/sampletime)) < npoints-1 do begin
          data_dens(ii,*)=data_dens(ii,*)+pert*exp(-(ii-i)*sampletime/decay(j))
        endfor  
      endif    
  	endfor
  endfor  	
endif
if (mode eq 4) then begin
  dd=ampmax*sin(findgen(npoints)*1e-6/(1/frequency)*2*!pi)
	for i=0,chn-1 do data(*,i)=dd
endif	

dens_flucprof=fltarr(dens_chn)
dens_avr=total(data_dens,1)/npoints
for i=0,dens_chn-1 do data_dens(*,i)=(data_dens(*,i)-dens_avr(i)) > (-0.9*n0(i))
dens_avr=total(data_dens,1)/npoints
for i=0,dens_chn-1 do dens_flucprof(i)=sqrt(total((data_dens(*,i)-dens_avr(i))^2)/npoints)
nprof=fltarr(chn)
flucprof=fltarr(chn)
flucavr=fltarr(chn)
photon_amp=max_photon/max(p0r)
backgr_prof=background*max(p0r)
if (not (mode eq 4)) then begin
	nprof=fltarr(dens_chn)
	i=long(0)
	flucprof=fltarr(chn)
	for i=long(0),npoints-1 do begin
	  if (long(i/5000)*5000 eq i) then print,i
	  nprof(*)=data_dens(i,*)
    pf=M#nprof
	  p=(p0r+pf+backgr_prof)*photon_amp> 0
		flucprof=flucprof+(pf*photon_amp)^2
		flucavr=flucavr+pf*photon_amp
	  data(i,*)=p
	endfor
  if (not keyword_set(nophoton)) then begin
    print,'Doing photon statistics...'
    for i=0,chn-1 do begin
      print,'Channel '+i2str(channels(i))
      sig=data(*,i)
      photon_noise,sig,tres=sampletime,inttime=inttime,outsig=outsig
      data(*,i)=outsig
    endfor
  endif    
  flucavr=flucavr/npoints
  flucprof=flucprof-flucavr^2*npoints
	flucprof=sqrt(flucprof/npoints)
endif
flucprof=flucprof*3./max_photon
data=data*3./max_photon
p0r=p0r*photon_amp*3./max_photon

if (output_sampletime ne sampletime) then begin
  m=round(output_sampletime/sampletime)
  ind=lindgen(npoints/m)*m
  data_dens=data_dens(ind,*) 
  data=data(ind,*)
endif   

for i=0,chn-1 do begin  
  if (keyword_set(add)) then begin
    dd1=data(*,i)
    restore,tmpbase+i2str(i+1)+'.dat'
    dd=[dd,dd1]
    save,dd,file=tmpbase+i2str(i+1)+'.dat'
	endif else begin
    dd=data(*,i)
    save,dd,file=tmpbase+i2str(i+1)+'.dat'
	endelse	
endfor
for i=0,dens_chn-1 do begin	
	data_dens(*,i)=data_dens(*,i)+n0(i)
  if (keyword_set(add)) then begin
	  dd1=data_dens(*,i)
    restore,tmpbase+i2str(i+1)+'_dens.dat'
		dd=[dd,dd1]
    save,dd,z_vect,file=tmpbase+i2str(i+1)+'_dens.dat'
	endif else begin
	  dd=data_dens(*,i)
    save,dd,z_vect,file=tmpbase+i2str(i+1)+'_dens.dat'
	endelse  	
endfor	
  
if (not keyword_set(no_files)) then begin
  print,'Writing files and calculating background signal...'
  for i=0,chn-1 do begin
    print,'Channel '+i2str(channels(i))  
    restore,tmpbase+i2str(i+1)+'.dat'
    if (background_time ne 0) then begin
      backgr_points=background_time/output_sampletime
      db=fltarr(backgr_points)+max(p0r)*background(i)/3.*max_photon
      photon_noise,db,tres=output_sampletime,inttime=inttime,outsig=outsig
      dd=[dd,outsig*3./max_photon]
    endif  
    wftwrite,flukfile(shot_sim,channels(i)),dd,tstart=trange(0),sampletime=output_sampletime,$
    user_notes='Simulation',over=over
    spawn,'rm -f '+tmpbase+i2str(i+1)+'.dat'
  endfor
  for i=0,dens_chn-1 do begin  
    spawn,'mv '+tmpbase+i2str(i+1)+'_dens.dat data/'+i2str(shot_sim,digits=5)+i2str(i+1,digits=3)+'_dens.dat'
  endfor

  default,decay,0
  default,ampmax,0
  default,period,0
  default,width,0
  default,nophoton,0
  default,startz,8.
  default,endz,max(z_vect)+3
  save,shot_sim,mode,matrix,z_vect,p0r,n0,channels,max_photon,inttime,$
       trange,sampletime,multi,decay,ampmax,period,width,output_sampletime,$
       flucprof,dens_avr,dens_flucprof,nophoton,background,background_time,startz,endz,$
       file='data/'+i2str(shot_sim,digits=5)+'.simpara'
  openw,unit,'cal/'+i2str(shot_sim,digits=5)+'.cal',/get_lun,error=error
  if (error ne 0) then begin
    print,'Warning! Cannot write calibration file: cal',+i2str(shot_sim,digits=5)+'.cal'
  endif else begin
    for i=0,27 do printf,unit,float(1.)
    close,unit
    free_lun,unit
    cal=getcal(shot_sim)    
    openw,unit,'cal/'+i2str(shot_sim,digits=5)+'.cal',/get_lun
    for i=0,27 do printf,unit,1/cal(i)
    close,unit
    free_lun,unit
  endelse
endif

end
  
