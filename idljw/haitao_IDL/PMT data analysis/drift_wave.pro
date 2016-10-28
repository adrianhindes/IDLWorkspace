pro drift_wave,m,n,sita,phi
;sita is the phase of intensity perturbation, phi is the phse difference between intensity and potential perturbations
npts=200.0  ;grid points 
xp=range(-0.05,0.05,npts=npts)
r=range(0,0.05,npts=npts)
delsam=xp(1)-xp(0)
unit = replicate(1.,npts)
xx = xp#unit
yy = transpose(xx)
rr = (xx^2+yy^2)^0.5
theta=atan(yy,xx)
;theta(0:49,50)=!pi
;theta(*,0:49)=theta(*,0:49)+!pi*2.0

f=0.135  ;camera focus
radius=0.05 ;plasma radius
sz=24.0*1e-6 ;camera sensor size
pn=512  ;pixel number
;constants in mks
e=1.6*1e-19
ev=11600.0
k=1.38*1e-23
te=5.0
ti=0.2
magnetic=0.1
pcoor=0.02 ;gaussian distribution intensity peak posion
pwidth=0.02 ;gaussian distribution intensity width


intn=make_array(pn,/float)
intn1=make_array(pn,/float)
intpro=make_array(pn,/float)
intpro0=make_array(pn,/float)
flowpro=make_array(pn,/float)
flowpro0=make_array(pn,/float)
dispara=make_array(pn,/float)
ch=make_array(pn,/float)
ch1=make_array(pn,/float)
ch2=make_array(pn,/float)
ch3=make_array(pn,/float)

;grid method by clive---------------------------------------------------------------------------------
center=[npts/2.0,1.09*npts/2.0/radius+npts/2.0]  ;the interpolate function interpols the location of an image, shift the coordinates
int_0=exp(-125.0*(rr-0.07/2.0/!pi*sin(!pi*2.0/0.07*rr)));exp(-rr^2/0.02^2);
int_0_dif=-125.0*(1-cos(rr/0.07*!pi*2.0))*int_0;-2.0*rr/0.02^2*int_0;
v0_x=ti*k*ev/e/magnetic*int_0_dif/int_0*sin(theta);sin(atan(csy(q),csx(p)))
v0_y=-ti*k*ev/e/magnetic*int_0_dif/int_0*cos(theta);cos(atan(csy(q),csx(p)))
int_1=0.01*(1.0-cos(rr/0.05*!pi*2.0))*exp(-125.0*(rr-0.07/2.0/!pi*sin(!pi*2.0/0.07*rr)))*dcomplex(cos(m*theta+sita),sin(m*theta+sita))
;intp=0.01*dcomplex(exp(-(rr-pcoor)^2.0/pwidth^2.0)*cos(m*theta+sita),exp(-(rr-pcoor)^2.0/pwidth^2.0)*sin(m*theta+sita))
intp=0.01*dcomplex((1.0-cos(rr/0.05*!pi*2.0))*cos(m*theta+sita),(1.0-cos(rr/0.05*!pi*2.0))*sin(m*theta+sita))
;intp=dcomplex(cos(!pi/0.05*rr)*cos(m*theta+sita),cos(!pi/0.05*rr)*sin(m*theta+sita))
potp=real_part(k*te*ev/e*intp*dcomplex(cos(phi),sin(phi)))
;potp=smooth(potp,[8,8])
elec=-gradient(potp,/vector)
v_x=reform(elec(*,*,1))/magnetic*npts/0.1  ;the gradient function uses grid interval 1.0
v_y=-reform(elec(*,*,0))/magnetic*npts/0.1
;;v_x(48:51,48:51)=0.0
v_y(48:51,48:51)=0.0
index=where(rr gt radius)
for j=0,n_elements(index)-1 do begin
  index1=array_indices(rr,index(j))
  rr(index1(0),index1(1))=0.0
  int_0(index1(0),index1(1))=0.0
   v0_x(index1(0),index1(1))=0.0
   v0_y(index1(0),index1(1))=0.0
    v_x(index1(0),index1(1))=0.0
   v_y(index1(0),index1(1))=0.0
  int_1(index1(0),index1(1))=dcomplex(0.0 ,0.0)
  intp(index1(0),index1(1))=dcomplex(0.0 ,0.0)
 endfor 
 ind=where(abs(xp)le 0.05*radius)
 bind=max(ind)
 sind=min(ind)
 ;for i=0,npts-1 do begin
  ;v_y(sind:npts/2,i)=interpol(v_y(0:sind,i),findgen(sind+1),findgen(npts/2.0-sind+1)+sind)
  ;v_y(npts/2:bind,i)=interpol(v_y(bind:*,i),findgen(npts-bind)+bind,findgen(-npts/2.0+bind+1)+npts/2)
  ;v_x(sind:npts/2,i)=interpol(v_y(0:sind,i),findgen(sind+1),findgen(npts/2.0-sind+1)+sind)
 ; v_x(npts/2:bind,i)=interpol(v_y(bind:*,i),findgen(npts-bind)+bind,findgen(-npts/2.0+bind+1)+npts/2)
  ;endfor
restore,'shot364 intensity reconstruction profiles.save'
intcs=tomoresult.ics
intcs=mean(intcs,dimension=3)
intpcs=tomoresult.ipcs 
 
restore,'shot364 intensity and flow reconstruction profile.save'
flcsx=tomoresult1.flcsx
;flcsx=flow_csec_numx
flcsx=mean(flcsx,dimension=3)
flcsy=tomoresult1.flcsy
;flcsy=flow_csec_numy
flcsy=mean(flcsy,dimension=3)

v0_x=flcsx
v0_y=flcsy
int_0=intcs
int_1=intpcs

n=50000
;para=findgen(n)*2400.0/(n-1)-1200.0 ;para scale determines by when vector is [0,1.0]
para=findgen(n)*npts/0.04/(n-1)-npts/0.08
for i=0,pn-1 do begin 
vec=[(i-pn/2.0)*sz,f]
vec=vec/sqrt(total(vec^2))
x=vec(0)*para+center(0)
y=vec(1)*para+center(1)
dis=sqrt((x-npts/2.0)^2+(y-npts/2.0)^2)
ind=where(dis le npts/2.0)
para1=para(ind)
intn(i)=n_elements(ind)
x=vec(0)*para1+center(0)
y=vec(1)*para1+center(1)
;if (i eq 1)then stop
v_xl=interpolate(v_x,x,y,missing=0.0,CUBIC=-0.5)
v_yl=interpolate(v_y,x,y,missing=0.0,CUBIC=-0.5)
v0_xl=interpolate(v0_x,x,y,missing=0.0,CUBIC=-0.5)
v0_yl=interpolate(v0_y,x,y,missing=0.0,CUBIC=-0.5)
int_0l=interpolate(int_0,x,y,missing=0.0,CUBIC=-0.5)
int_1l=interpolate(real_part(int_1(*,*,1)),x,y,missing=0.0,CUBIC=-0.5)
v_l=v_xl*cos(atan(vec(1),vec(0)))+v_yl*sin(atan(vec(1),vec(0)))
v0_l=v0_xl*cos(atan(vec(1),vec(0)))+v0_yl*sin(atan(vec(1),vec(0)))
ind1=where(dis le 0.5*radius*npts/2.0/radius)
;if (n_elements(ind1) gt 1) then begin
;cvl=v_l(ind1)
;cvl=smooth(cvl,20)
;v_l(ind1)=0.02*cvl
;endif
intpro0(i)=total(int_0l)
intpro(i)=total(int_1l);/total(int_0l)

;flowpro(i)=total(v_l)
flowpro0(i)=total(v0_l*int_0l)/total(int_0l)
ch1(i)=total(int_1l*v0_l)/total(int_0l)
ch2(i)=-total(v0_l*int_0l)/total(int_0l)*total(int_1l)/total(int_0l);-total(real_part(int1)*v_l0)/total(int0)
ch3(i)=total(v_l*int_0l)/total(int_0l)
ch(i)=ch1(i)+ch2(i)
flowpro(i)=total((v_l+v0_l)*(int_0l+int_1l))/total(int_0l+int_1l)-flowpro0(i)
dispara(i)=(center(1)-npts/2.0)*cos(atan(vec(1),vec(0)))
;if (i eq 230)then stop
;!p.multi=[0,3,2]
;plot, int_0l,title='I_0 at view'
;plot,int_1l,title='I_1 at view'
;plot,v0_l,title='V_0 at wview'
;plot,v_l,title='V_1 at view'
;plot, int_0l*v0_l,title='I_0*V_0 at view'
;plot,int_1l*v0_l,title='I_1*V_0 at view'
;endif
endfor
;rcoor=findgen(pn)*2.0*radius/(pn-1)-radius
;ind2=where(abs(rcoor)lt 0.3*radius)
;xind=rcoor(ind2)
;d2=interpol(flowpro,rcoor,xind,/LSQUADRATIC)
;flowpro(ind2)=d2
stop
p=image(rebin(real_part(intp),1000,1000),findgen(1000)*0.1/999.0-0.05,findgen(1000)*0.1/999.0-0.05,axis_style=1,rgb_table=4,xtitle='X axis(m)',ytitle='Y axis(m)',title='Densitiy perturbation profile')
c1=colorbar(target=p,orientation=1,position=[0.955,0.25,0.985,0.75],title='Density perturbation(%)',textpos=0) 
g1=vector(rebin(v_x,20,20),rebin(v_y,20,20),rgb_table=4,auto_color=1,length_scale=2,xrange=[0,20],yrange=[0,20],title=' Flow perturbation profilws')
c1=colorbar(target=g1,orientation=1,position=[0.955,0.25,0.985,0.75],title='Velocity(m/s)',textpos=0)  
p1=plot(findgen(512),intpro/max(intpro),title='Normalized Density perturbation projection',xtitle='Camera pixel',ytitle='Density perturbation(%)')
p2=plot(findgen(512),flowpro,title='Flow perturbation projection',xtitle='Camera pixel',ytitle='Projected velocity(m/s)')
stop
!p.multi=[0,3,2]
!p.charsize=2
plot, xp,1.0-400*xp^2,xtitle='Radius(m)', xrange=[-0.05,0.05],yrange=[0.0,1.0],ytitle='Density distribuition',title='Background density distribution'
plot,findgen(512),flowpro0,xtitle='Camera pixel',ytitle='Flow integration(m/s)',title='Term 1'
plot,findgen(512),ch3,xtitle='Camera pixel',ytitle='Flow integration(m/s)',title='Term 4'
plot,findgen(512),ch1,xtitle='Camera pixel',ytitle='Flow integration(m/s)',title='Term 2'
plot,findgen(512),ch2,xtitle='Camera pixel',ytitle='Flow integration(m/s)',title='Term 3'
plot,findgen(512),ch,xtitle='Camera pixel',ytitle='Flow integration(m/s)',title='Term3+term2'
!p.multi=0
stop
p=plot(r,exp(-25.0*(r-0.07/2.0/!pi*sin(!pi*2.0/0.07*r))),xtitle='Radius(m)',ytitle='Density distribution(arb)',title='Densitiy profile',xrange=[0,0.05])
g1=vector(rebin(v0_x,20,20),rebin(v0_y,20,20),rgb_table=4,auto_color=1,length_scale=2,xrange=[0,20],yrange=[0,20],title='zero-order flow profilws crosssection')
c1=colorbar(target=g1,orientation=1,position=[0.955,0.25,0.985,0.75],title='Velocity(m/s)',textpos=0)  
p1=plot(findgen(512),intpro0/max(intpro0),title='Normalized zero-order density projection',xtitle='Camera pixel',ytitle='Intensity(arb)')
p2=plot(findgen(512),flowpro0,title='zero-order flow projection',xtitle='Camera pixel',ytitle='Projected velocity(m/s)')


stop
;--------------------------------------------------------------------------------------------------------

cs_int=make_array(100,100,/dcomplex)
cs_pot=make_array(100,100,/dcomplex)
csx=findgen(100)*0.1/99-0.05
csy=findgen(100)*0.1/99-0.05
e_x=make_array(100,100,/float)
e_y=make_array(100,100,/float)
v0_x=make_array(100,100,/float)
v0_y=make_array(100,100,/float)
vsx=make_array(100,100,/float)
vsy=make_array(100,100,/float)

x=range(-0.05,0.05,npts=100)
unit = replicate(1.,100)
xx = x#unit
yy = transpose(xx)
rr = (xx^2+yy^2)^0.5
theta=atan(yy,xx)
center=[0.0,1.0]
for p=0,99 do begin
  for q=0,99 do begin
    rv=rr(p,q)
    if ((rv gt 0.05) or (rv le 0.0001) ) then begin ;
    cs_int(p,q)=0.0 
   endif  else begin
int_0=50.0*exp(-rv^2/0.02)
int_0_dif=-50.0/0.02*2*rv*exp(-rv^2/0.02)
v0_x(p,q)=ti*k*ev/e/magnetic*int_0_dif/int_0*sin(theta(p,q));sin(atan(csy(q),csx(p)))
v0_y(p,q)=-ti*k*ev/e/magnetic*int_0_dif/int_0*cos(theta(p,q));cos(atan(csy(q),csx(p)))        
pertur=0.04*dcomplex(exp(-(rv-pcoor)^2.0/pwidth^2.0)*cos(m*theta(p,q)+sita),exp(-(rv-pcoor)^2.0/pwidth^2.0)*sin(m*theta(p,q)+sita))
cs_int(p,q)=pertur
cs_pot(p,q)=k*te*ev/e*cs_int(p,q)*dcomplex(cos(phi),sin(phi))
disp=-2*(rv-pcoor)/(pwidth^2)*cs_pot(p,q)  ;derivative of radiius
dissita=m*cs_pot(p,q)*dcomplex(0.0,1.0)  ;derivative of sita
e_x(p,q)=-(cos(theta(p,q))*real_part(disp)-1.0/rv*sin(theta(p,q))*real_part(dissita))
e_y(p,q)=-(sin(theta(p,q))*real_part(disp)+1.0/rv*cos(theta(p,q))*real_part(dissita))
vsx(p,q)=e_y(p,q)/magnetic
vsy(p,q)=-e_x(p,q)/magnetic
 endelse
 endfor
 endfor
rd=findgen(100)*0.05/99.0
;g=vector(rebin(vsx,20,20),rebin(vsy,20,20),rgb_table=4,auto_color=1,length_scale=2,xrange=[0,20],yrange=[0,20],title='Flow profilws crosssection')
;c=colorbar(target=g,orientation=1,position=[0.935,0.25,0.965,0.75])  
;p=image(rebin(real_part(cs_int),1000,1000),findgen(1000)*0.1/999.0-0.05,findgen(1000)*0.1/999.0-0.05,axis_style=1,rgb_table=4,xtitle='X axis(m)',ytitle='Y axis(m)',title='Densitiy perturbation profile')


for i=0,pn-1 do begin 
vec=[(i-pn/2.0)*sz,f]
vec=vec/sqrt(total(vec^2))
lefts=-1.5
rights=1.5
nlat=10.0
para=findgen(5000.0*nlat)*(rights-lefts)/(5000.0*nlat-1.0)+lefts  ;parameters
deltat=para(1)-para(0)
x=vec(0)*para+center(0)
y=vec(1)*para+center(1)
rsq=sqrt(x^2+y^2)
index=where(rsq^2 le radius^2)
intn(i)=n_elements(index)
para=para(index)
x=vec(0)*para+center(0)
y=vec(1)*para+center(1)
rsq=sqrt(x^2+y^2)
;evaluation the partial derivative by approximation
x1=shift(x,1)
y1=shift(y,1)
rsqx=sqrt(x1^2+y^2)
rsqy=sqrt(x^2+y1^2)

int0=2500.0*exp(-rsq^2/0.02)
int0_dif=-50/0.02*2.0*rsq*int0
v0x=-ti*k*ev/e/magnetic*50/0.02*2.0*rsq*sin(atan(y,x))
v0y=ti*k*ev/e/magnetic*50/0.02*2.0*rsq*cos(atan(y,x))
int1=100.0*exp(-(rsq-pcoor)^2/pwidth^2-rsq^2/0.02)*dcomplex(cos(m*atan(y,x)+sita),sin(m*atan(y,x)+sita))
intp=0.04*exp(-(rsq-pcoor)^2/pwidth^2)*dcomplex(cos(m*atan(y,x)+sita),sin(m*atan(y,x)+sita));:int1/int0
;intpx=0.04*exp(-(rsqx-pcoor)^2/pwidth^2)*dcomplex(cos(m*atan(y,x1)+sita),sin(m*atan(y,x1)+sita))
;intpy=0.04*exp(-(rsqy-pcoor)^2/pwidth^2)*dcomplex(cos(m*atan(y1,x)+sita),sin(m*atan(y1,x)+sita))
rsqn=where(rsq lt 0.0020)
rsqn1=where(rsq ge 0.0020)
rsq1=rsq(rsqn1)
intn1(i)=n_elements(rsqn)
if (intn1(i) ge 2) then intp(rsqn)=interpol(real_part(intp(rsqn1)),rsq1,rsq(rsqn),/QUADRATIC)
potp=k*te*ev/e*intp*dcomplex(cos(phi),sin(phi))
;potpx=k*te*ev/e*intpx*dcomplex(cos(phi),sin(phi))
;potpy=k*te*ev/e*intpy*dcomplex(cos(phi),sin(phi))
;if (vec(0) eq 0.0) then vec(0)=0.001
;potp_dx=(potpx-potp)/(vec(0)*deltat)
;potp_dy=(potpy-potp)/(vec(1)*deltat)
potp_dr=-2*(rsq-pcoor)/(pwidth^2)*potp
potp_dsita=real_part(m*potp*dcomplex(0.0,1.0))
v_x=-(sin(atan(y,x))*real_part(potp_dr)+1.0/rsq*cos(atan(y,x))*potp_dsita)/magnetic
v_y=(cos(atan(y,x))*real_part(potp_dr)-1.0/rsq*sin(atan(y,x))*potp_dsita)/magnetic
;v_x=-potp_dy
;v_y=potp_dx
v_l=v_x*cos(atan(vec(1),vec(0)))+v_y*sin(atan(vec(1),vec(0)))
v_l0=v0x*cos(atan(vec(1),vec(0)))+v0y*sin(atan(vec(1),vec(0)))
;if (i eq 256) then stop
intpro0(i)=total(int0)
intpro(i)=total(real_part(int1))/total(int0)
flowpro(i)=total(v_l*int0)/total(int0);total((v_l+v_l0)*(int0+int1))/total((int0+int1))
flowpro0(i)=total(v_l0*int0)/total(int0)
;flowpro(i)=flowpro0(i)*total(real_part(int1))/total(int0)-total(real_part(int1)*v_l0)/total(int0)+total(int0*v_l)/total(int0)
ch(i)=-total(real_part(int1)*v_l0)/total(int0);flowpro0(i)*total(real_part(int1))/total(int0);-total(real_part(int1)*v_l0)/total(int0)
endfor
;flowpro(256)=(flowpro(255)+flowpro(257))/2.0

;p=plot(rd,50.0*exp(-rd^2/0.02^2),xtitle='Radius(m)',ytitle='Density distribution(arb)',title='Densitiy profile')
;g1=vector(rebin(v0_x,20,20),rebin(v0_y,20,20),rgb_table=4,auto_color=1,length_scale=2,xrange=[0,20],yrange=[0,20],title='zero-order flow profilws crosssection')
;c1=colorbar(target=g1,orientation=1,position=[0.955,0.25,0.985,0.75],title='Velocity(m/s)',textpos=0)  
;p1=plot(findgen(512),intpro0,title='zero-order density projection',xtitle='Camera pixel',ytitle='Intensity(arb)')
;p2=plot(findgen(512),flowpro0,title='zero-order flow projection',xtitle='Camera pixel',ytitle='Projected velocity(m/s)')

stop

!p.multi=[0,2,2]
imgplot, real_part(cs_int),csx,csy,title='Crosssection of the intensity distribution',/cb
plot, rd, 0.04*exp(-(rd-pcoor)^2/pwidth^2),title='Intensity distribution',xtitle='Radius(m)',ytitle='Intensity'
plot, intpro,title='Integrated intensity',xtitle='camera pixel',ytitle='Intensity'
plot,real_part(flowpro),title='Integrated flow(arb)',xtitle='camera pixel',ytitle='Integrated flow(arb)'
d=fft(intpro)
d1=atan(d,/phase)

stop
end