pro calcmne_fluc,li2p,ne_res,z_res,show=show,$
photon_error=photon_err, backgr_err=backgr_err,M=M,z_vect=z_vect,$
fail_n=fail_n
; calculates density profiles using perturbative density calculation
; z_vect:  list of z values, where the density will be calculated

default,K,double(1e-4)
default,photon_err,0 
K0=K
fail_n=0

loadxrr,xrr
np=(size(xrr))(1)
p0=fltarr(np)
nprof=(size(li2p))(1)
p0(*)=total(li2p,1)/nprof

default,backgr_err,max(p0)*4e-3

calcne,p0,n0,z,3
z=z(where(z ne 0))
n0=n0(where(z ne 0))
n0=n0>0

if (not keyword_set(z_vect)) then begin
  n0=xy_interpol(z,n0,xrr)
  z=[9,xrr]
  n0=[1e11,n0]
endif else begin
  n0=xy_interpol(z,n0,z_vect)
  z=z_vect
endelse  
nd=(size(n0))(1)
p0r=calc_light(z,n0,xrr)
  
if (not keyword_set(M)) then calcM,M,n0,z
calcH,H,n0,z

p1=fltarr(np)
ne_res=fltarr(nprof,nd)
z_res=fltarr(nprof,nd)
sigl=0.9
sigh=1.1


err=sqrt(photon_err*photon_err+backgr_err*backgr_err)
err=err/total(p0)*total(p0r)
nosol=0

for iprof=0,nprof-1 do begin
  z_res(iprof,*)=z
  p1(*)=li2p(iprof,*)
  p1r=(p1-p0)/total(p0)*total(p0r)+p0r
  sigma0=total((p1r-p0r)*(p1r-p0r)/err/err)/np
  if (sigma0 lt sigl) then begin
    n11=fltarr(nd)
    p11r=fltarr(np)
    sigma=sigma0
    goto,noiter
  endif

  stoprun=0
  nosol=0
  nK=0
rep:
  if ((K gt 1e15) or (nK gt 50)) then begin
    print,'Cannot find solution at profile '+i2str(iprof)
    nosol=1
    fail_n=fail_n+1
    stoprun=1
    K=K0
    goto,cont
  endif 
  calcT,T,n0,z,K=K,M=M,H=H,err=err
  n11=T#(p1r-p0r)*1e13
  p11r=M#n11/1e13
  sigma=total((p11r-(p1r-p0r))*(p11r-(p1r-p0r))/err/err)/np
  print,'iprof='+i2str(iprof)+'  K='+string(K)+'   sigma=',sigma
  if (nK eq 0) then begin
   sigma_list=sigma
   K_list=K
   nK=1
  endif else begin
   sigma_list=[sigma_list,sigma]
   K_list=[K_list,K]
   nK=nK+1  
  endelse
  if ((sigma gt sigl) and (sigma lt sigh)) then begin
    stoprun=1
    goto,cont
  endif  
  if (nK eq 1) then begin
    if (sigma lt sigl) then begin
      K=K/10
    endif else begin
      K=K*10
    endelse
  endif else begin
    K=((K_list(nK-1))-(K_list(nK-2)))/(sigma_list(nK-1)-sigma_list(nK-2))*$
         (1-sigma_list(nK-2))+(K_list(nK-2))
    if (K le 1e-7) then K=min(K_list)/2
  endelse  
cont:
  if (stoprun eq 0) then goto,rep
noiter:
  if (nosol eq 1) then n11(*)=0
  ne_res(iprof,*)=n11+n0   
   
  if (keyword_set(show)) then begin 
    hardcpy=0
hret:    
    if (hardcpy eq 1) then hardon     
    erase
    time_legend,'calcmne_fluc.pro'
    xyouts,0,0.95,'iprof='+i2str(iprof)+'  K='+string(K)+'  sigma='+string(sigma),/normal
    xr=[min(z),max(z)]
    plot,z,n0,xrange=xr,xstyle=1,xtitle='Z [cm]',ytitle='n!De!N [cm!U-3!N]',$
      pos=[0.1,0.55,0.43,0.85],/noerase,linestyle=1,$
      tit='Average and perturbed density'
    oplot,z,n11+n0
  
    yr=[min(n11),max(n11)]
    plot,z,n11,xrange=xr,xstyle=1,xtitle='Z [cm]',ytitle='n!De!N [cm!U-3!N]',$
      pos=[0.1,0.1,0.43,0.4],/noerase,linestyle=0,yrange=yr,$
      tit='Reconstructed dens. perturbation'
    if (yr(0)*yr(1) lt 0) then plots,xr,[0,0],linestyle=2

    plot,xrr,p0,xrange=xr,xstyle=1,xtitle='Z [cm]',ytitle='Li 2p light',$
      pos=[0.57,0.55,0.9,0.85],/noerase,linestyle=1,$
      tit='Average and perturbed Li 2p profile'
    oplot,xrr,p1

    yr=[min([p1r-p0r-err,p11r]),max([p1r-p0r+err,p11r])]
    plot,xrr,p1r-p0r,xrange=xr,xstyle=1,xtitle='Z [cm]',ytitle='Li 2p light',$
      pos=[0.57,0.1,0.9,0.4],/noerase,linestyle=1,yrange=yr,$
      tit='Measured and reconstr. light pert.'
    oplot,xrr,p11r
    if (yr(0)*yr(1) lt 0) then plots,xr,[0,0],linestyle=2
    errplot,xrr,p1r-p0r-err,p1r-p0r+err

    if (hardcpy eq 0) then begin
      if (ask('Hardcopy?')) then begin
        hardcpy=1
        goto,hret
      endif
    endif else begin
      hardoff
    endelse      
      
  endif  ; *** end of show ***
endfor

end
