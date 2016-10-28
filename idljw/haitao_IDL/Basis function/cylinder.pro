@cylint
pro cylinder,mv,nv,sita
;modeling of crosssecton profiles
cs=make_array(85,85,/complex)
xcom=make_array(85,85,/float)
ycom=make_array(85,85,/float)
x1=findgen(85)*0.0047-0.2
y1= findgen(85)*0.0047-0.2
;gama=1.0
common ratio
for p=0,84 do begin
  for q=0,84 do begin
    r=sqrt(x1(p)^2+y1(q)^2)
    if (r gt 0.2) then begin 
      cs(p,q)=0.0
      endif else begin
 ;test reconstructed profile of 20 zones
restore,'Reconstructed data of 20 zones4.save'
radius=findgen(zon+1)*0.2/zon
r1=findgen(1000)*0.2/999
da=radius-r
index=where(da ge 0.)
da1=da(index)
dam=min(da1)
index1=where(da eq dam)
dr=interpol(repro,r1,r,/LSQUADRATIC)
dis1=dcomplex(dr*cos(mv*atan(y1(q),x1(p))+sita+cphase(index1)),dr*sin(mv*atan(y1(q),x1(p))+sita+cphase(index1)))
;theoretical modeling profiles  
dis1=dcomplex(exp(-(r-0.1)^2/0.05^2)*cos(mv*atan(y1(q),x1(p))+sita),exp(-(r-0.1)^2/0.05^2)*sin(mv*atan(y1(q),x1(p))+sita))

;assumimg potential is in phase with intensity perturbation
disf=-2*(r-0.1)/(0.02^2)*dis1  ;derivative of radiius
dissita=mv*dis1*dcomplex(0.0,1.0)
elec_r=disf     ;electric field in r direction
elec_sita=1.0/r*dissita  ;electric field in sita direction
xcom(p,q)=cos(atan(y1(q),x1(p)))*elec_r-1.0/r*sin(atan(y1(q),x1(p)))*elec_sita
ycom(p,q)=sin(atan(y1(q),x1(p)))*elec_r+1.0/r*cos(atan(y1(q),x1(p)))*elec_sita

intensity1=replicate(n_elements(r),1.0) ;uniform background intensity distribution
intf=0
    
   ;intensity1=1.0-r^2/0.2^2                ;gaussian background intensity distribution
   ;intf=1-2*r/0.2^2
    
    intensity=intensity1;+gama*disf*intensity1+(1-gama)*intf*dis1
    
    ;cs(p,q)=intensity*exp(-(sqrt(x1(p)^2+y1(q)^2)-0.1)^2/0.02^2)*exp(complex(0,1)*mv*(atan(y1(q),x1(p))));-nv/1.0)
     cs(p,q)=dis1
     endelse
    endfor
    endfor
  ;
  ;
  cs1=cs
  ;save, cs, filename='Modeling crosssection at phase 0.25 pi.save
  ;save, cs1, filename='Reconstructed crosssection at phase 0.25 pi.save'
  stop
 restore,'Modeling crosssection at phase 0.25 pi.save
 imgplot, float(cs),/cb,title='Input crosssection profile',xtitle='X pixel',ytitle='Y pixel'
 restore, 'Reconstructed crosssection at phase 0.25 pi.save'
 imgplot, float(cs1),/cb,title='Reconstructed crosssection profile',xtitle='X pixel',ytitle='Y pixel'
 plot, float(cs(*,40))
 oplot, float(cs1(*,40)),color=3
 ;imgplot, float(cs)-float(cs1),title='Error of reconstruction',xtitle='X pixel',ytitle='Y pixel',/cb
stop


;modeling of integraed profiles
save,mv,nv,sita,filename='mode number.save'
x=findgen(85)+1.0
z=findgen(5)+1.0
sensor=200.0*1e-6
f=42.0*1e-3 
int=make_array(85,5,/double)
phase=make_array(85,5,/double)
signal=make_array(85,5,/double)
img=make_array(85,5,/double)
amp=make_array(85,5,/double)
comsignal=make_array(85,5,/dcomplex)
for i=0,84 do begin
  for j=0,4 do begin
    v=-[(x(i)-42.0)*sensor,f,(z(j)-2)*sensor]
    ;nv=v/total(v^2)
    ;if i eq 41 and j eq 42 then stop
   
    sight=cylint(v)
    int(i,j)=sight.int
    comsignal(i,j)=sight.integral
    phase(i,j)=atan(sight.integral,/phase)
   
    signal(i,j)=real_part(sight.integral)
    img(i,j)=imaginary(sight.integral)
    amp(i,j)=abs(sight.integral)
    endfor
    endfor
imgplot, signal,/cb

;save, signal,filename='Integrated data when m=1,n=0 at phase 1.875 pi.save'
 stop















 
rad=findgen(85)*0.2/85.0
p=plot(rad,exp(-(rad-0.1)^2/0.05^2),layout=[2,2,2],title='Radius amplitude profile',xtitle='Radius/m',ytitle='Amplidude(arb.)')
g=image(reverse(float(cs)),axis_style=1,xtitle='X pixel',ytitle='Y pixel',title='Cross section profile',layout=[2,2,1],rgb_table=4,/current)
c=colorbar(target=g,orientation=1,position=[0.48,0.58,0.51,0.93],uvalue=[-0.6,-0.3,0.0,0.3,0.6])
g1=image(signal,axis_style=1,xtitle='X pixel',ytitle='Y pixel',title='Integration profile',layout=[2,2,3],rgb_table=4,/current)
c1=colorbar(target=g1,orientation=1,position=[0.48,0.08,0.51,0.43])
p1=plot(signal(*,40),xtitle='X pixel',title='Integrated signal profile',ytitle='Integrated signal profile',layout=[2,2,4],/current)

stop
end
   
;g=image(rebin(int,850,850), axis_style=1,xtitle='X pixel',ytitle='Y pixel', rgb_table=4,title='Integrated imaginary part along line of sight for m=1')
; c=colorbar(target=g, orientation=1)
!p.multi=[0,2,3]
;imgplot,signal
;imgplot,img
imgplot,reverse(float(cs)),title='real cross section',/cb,xr=[0,100]
imgplot,imaginary(cs),title='imaginary cross section',/cb,xr=[0,100]
imgplot, signal,/cb,title='Integrated real part';,/ylog
imgplot,img,title='Integrated imaginary part',/cb;,/ylog
imgplot,amp,title='Integrated amplitude',/cb
imgplot,phase,title='Integrated phase',/cb
!p.multi=0
 ;save, sight, filename='sight intensity when m=2.save'
 
  


 
 
 stop
 end
 cylinder,1.0,0.0
 end
 