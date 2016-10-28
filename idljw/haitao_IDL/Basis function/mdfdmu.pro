pro mdfdmu,zonen, samn  ;tomography reconstruction of mdf data
;save, zonen,samn,filename='zone and sample parameter.save' ; zonen means the number of zones, samn means the sampling points
radius=findgen(1000)*0.2/999.0
;calculating signle zone integraton profiles
;zonedata=zoneinte(zonen)
;save,zonedata, filename='zone integration proifle for 20 zones4.save' ; sample points along line is 50000
;save,zonedata, filename='zone integration proifle for 30 zones4.save' ; sample points along line is 50000

;calculate line integration profile at different phases
;d=croip(1.0,0.0,0.0) ;the funcion 'croip' uses for calculation the integration for 16 phases, this is saved for following purpose
;save, d, filename='Integrated data for different phases.save'  ; line ingegration number equals 1000
;save, d, filename='Integrated data for different phases1.save'  ;line ingegration number equals 5000
;save, d, filename='Integrated data for different phases2.save'  ;line ingegration number equals 10000
;save, d, filename='Integrated data for different phases3.save'  ;line ingegration number equals 20000
;save, d, filename='Integrated data for different phases4.save'  ;line ingegration number equals 50000
;save, d, filename='Integrated data for different phases5.save'  ;line ingegration number equals 50000 testing uniform distribution

;;construct response matrix .................................................
;modeling data of m=1 n=0 at different phase 
mdata=make_array(85,5,16,/float)
mdata1=make_array(85,5,8,/float)
restore,'Integrated data for different phases4.save'
mdata=d
for i=0,7 do begin
  mdata1(*,*,i)=mdata(*,*,2*i)
  endfor
mdata8=make_array(85,5,16,/float)
mdata8(*,*,0:7)=mdata1
mdata8(*,*,8:15)=mdata1
!p.multi=[0,2,4]
phn=['0.0','0.25','0.5','0.75','1.0','1.25','1.5','1.75']
for i=0,7 do begin
  imgplot, mdata8(*,*,i),title='Phase at '+phn(i)+' !pi',/cb
  endfor

 ;fourier transform of modeling data of 8 samples per one period
mdatas=make_array(16,85*5)  ;measured data 85*85*16,taking two period  of 8 samples per one period
for i=0,85*5-1 do begin
  array=findgen(85,5)
  index=array_indices(array,i)
  mdatas(*,i)=mdata8(index(0),index(1),*)
  endfor
fmdata=make_array(16,85*5,/dcomplex) ;fourier transform of measured data

for j=0,85*5-1 do begin
  fda=fft(reform(mdatas(*,j)))
  fda(0:1)=0.0
  fda(3:*)=0.0
  fmdata(*,j)=fft(fda,/inverse)
  endfor
 
 ;fourier transform of modeling data of 16 samples per one period
;mdatas=make_array(16,85*85)  ;measured data 85*85*16,taking one period  of 8 samples per one period
;for i=0,85*85-1 do begin
  ;array=findgen(85,85)
  ;index=array_indices(array,i)
  ;mdatas(*,i)=mdata(index(0),index(1),*)
  ;endfor
;fmdata=make_array(16,85*85,/dcomplex) ;fourier transform of measured data
;for j=0,85*85-1 do begin
  ;fda=fft(reform(mdatas(*,j)))
  ;fda(0)=0.0
  ;fda(2:*)=0.0
  ;fmdata(*,j)=fft(fda,/inverse)
  ;endfor
  
;;modeling data of zones, 0 order spline function
zon=zonen
knots=findgen(zon+1)*0.2/zon
bfu=splin(1000,knots)
da=bfu.order0
restore, 'zone integration proifle for 20 zones4.save'

bdata=make_array(85,5,zon,/dcomplex)
rbdata=0.5*real_part(zonedata)
ibdata=0.5*imaginary(zonedata)
fd=make_array(zon*2,85*5*2,/float)
for i=0,zon-1 do begin
for j=0,85*5-1 do begin
rbdata1=reform(rbdata(*,*,i))
ibdata1=reform(ibdata(*,*,i))
  fd(2*i,j*2)=rbdata1(j)
  fd(2*i,j*2+1)=ibdata1(j)
  fd(2*i+1,j*2)=-ibdata(j)
  fd(2*i+1,j*2+1)=rbdata1(j)
  endfor
  endfor 
 
;peudo inverse
la_svd,fd, w,u,v,status=status,/double
ffd=u##diag_matrix(w)##transpose(v)
index=where(w lt 4000.0) ;delete extrme sigular value
w1=1.0/w
w1(index)=0.0
ivfd=v##diag_matrix(w1)##transpose(u)

mmdata=make_array(1,85*5*2,/float) ;modeling measured data
mmdata(0,2*findgen(85*5))=real_part(fmdata(1,*))
mmdata(0,2*findgen(85*5)+1)=imaginary(fmdata(1,*))
cb=reform(ivfd##mmdata)
;0 order spline function
cphase=make_array(zon,/float)
cweights=make_array(zon,/float)
for i=0,zon-1 do begin
  cphase(i)=atan(cb(2*i+1),cb(2*i))
  cweights(i)=sqrt(cb(2*i+1)^2+cb(2*i)^2)
 endfor
 radius1=findgen(zon+1)*0.2/zon
radius1=radius1(0:zon-1)+0.005
inpro=exp(-(radius-0.1)^2/0.05^2)
for i=0,zon-1 do begin
  da(*,i)=cweights(i)* da(*,i)
  endfor
repro=total(da,2)
sam=interpol(repro, radius, radius1)
inputpha=replicate(!pi/4, zon)
!p.multi=[0,3,3]
plot, radius, inpro,title='Input amplitude profile',xtitle='Radius/m',ytitle='Amp'
plot, radius1, sam,title='Reconstructed amplitude profile',xtitle='Radius/m',ytitle='Amp',color=3,yrange=[0,1]
plot, radius, inpro,title='Amplitude profile',xtitle='Radius/m',ytitle='Amp'
oplot,radius1, sam,color=3
plot, radius1,inputpha, title='Input phase profile',xtitle='Radius/m',ytitle='Phase/radians',yrange=[0,1]
plot, radius1,cphase,title='Reconstructed phase',xtitle='Radius/m',ytitle='Phase/radians',color=6,yrange=[0,1]
plot, radius1,inputpha,title='Reconstructed phase',xtitle='Radius/m',ytitle='Phase/radians',yrange=[0,1]
oplot, radius1,cphase,color=6

;save, repro,zon,cphase,filename='Reconstructed data of 20 zones4.save';50000 sampling points cutting sigualr value 0.25
;save, repro,zon,cphase,filename='Reconstructed data of 20 zones3.save';20000 sampling points cutting sigualr value 0.25
;save, repro,zon,cphase,filename='Reconstructed data of 20 zones2.save';10000 sampling points cutting sigualr value 0.25
;save, repro,zon,cphase,cb,filename='Reconstructed data of 20 zones1.save';5000 sampling points cutting sigualr value 0.25
;save, repro,zon,cphase,filename='Reconstructed data of 20 zones.save';1000 sampling points cutting sigualr value 0.35


;save, repro,zon,cphase,filename='Reconstructed data of 30 zones4.save';50000 sampling points cutting sigualr value 0.10
;save, repro,zon,cphase,filename='Reconstructed data of 30 zones3.save';20000 sampling points  cutting sigular value 0.15
;save, repro,zon,cphase,filename='Reconstructed data of 30 zones2.save';10000 sampling points cutting sigular value 0.2
;save, repro,zon,cphase,filename='Reconstructed data of 30 zones1.save';5000 sampling points,cuuting sigular value 0.20
;save, repro,zon,cphase,filename='Reconstructed data of 30 zones.save';1000 sampling points ,cutting sigular value 0.2

;save, repro,zon,cphase,filename='Reconstructed data of 10 zones4.save';50000 sampling points ,cutting sigular value 0.25
;save, repro,zon,cphase,filename='Reconstructed data of 40 zones4.save';50000 sampling points ,cutting sigular value 0.15


stop
  
; the 0 order spline function generates good amplitude profile, but the phase profile at the edge is  not good, to test whether it is caused by the edge effect of the inverse method,try to recover three phase stage at once
mmdata3=make_array(3,85*5*2,/float)
for k=0,2 do begin
mmdata3(k,2*findgen(85*5))=real_part(fmdata(k,*))
mmdata3(k,2*findgen(85*5)+1)=imaginary(fmdata(k,*))
endfor
cb=ivfd##mmdata3 

cphase=make_array(3,zon,/float)
cweights=make_array(3,zon,/float)
for j=0,2 do begin
for i=0,zon-1 do begin
  cphase(j,i)=atan(cb(2*i+1),cb(2*i))
  cweights(j,i)=sqrt(cb(2*i+1)^2+cb(2*i)^2)
 endfor
 endfor
 stop
 
;;;modeling data of first order spline function with 11 knots
kn=11
knots=findgen(kn)*0.2/(kn-1.0)
bfuc=splin(1000,knots)
da=bfuc.order1
;save, da, filename='First order spline function with 11 knots.save'
restore, 'basis fuction integration proifle for 11 knots.save'
bdata=bafucp
rbdata=0.5*real_part(bdata)
ibdata=0.5*imaginary(bdata)
fd=make_array(2*(kn-2),85*85*2,/float)
for i=0,kn-3 do begin
for j=0,85*85-1 do begin
rbdata1=reform(rbdata(*,*,i))
ibdata1=reform(ibdata(*,*,i))
  fd(2*i,j*2)=rbdata1(j)
  fd(2*i,j*2+1)=ibdata1(j)
  fd(2*i+1,j*2)=-ibdata(j)
  fd(2*i+1,j*2+1)=rbdata1(j)
  endfor
  endfor
la_svd,fd, w,u,v,status=status
ffd=u##diag_matrix(w)##transpose(v)
ivfd=v##diag_matrix(1.0/w)##transpose(u)
;first order spline function 
mmdata=make_array(85*5*2,/float)
mmdata(2*findgen(85*5))=real_part(fmdata(1,*))
mmdata(2*findgen(85*5)+1)=imaginary(fmdata(1,*))
cb=ivfd##mmdata 
cphase=make_array(kn-2,/float)
cweights=make_array(kn-2,/float)
for i=0,kn-3 do begin
  cphase(i)=atan(cb(2*i+1),cb(2*i))
  cweights(i)=sqrt(cb(2*i+1)^2+cb(2*i)^2)
  endfor
inpro=exp(-(radius-0.1)^2/0.05^2)
repro=make_array(1000,kn-2,/float)
rephase=make_array(1000,kn-2,/float)
for i=0,kn-3 do begin
  rephase(*,i)=cphase(i)*da(*,i)
  repro(*,i)=da(*,i)*cweights(i)
  endfor
repro=total(repro,2)
rephase=total(rephase,2)
;;;

stop

;save, cphase,cp,filename='Reconstructed raidial profile.save'
;save, cphase,cp,filename='Reconstructed raidial profile1.save'
stop
end