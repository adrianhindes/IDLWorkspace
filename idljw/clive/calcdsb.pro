p0=[2753,-82,285.] ; window point
b0=[3399,-1485,0.] ; point through which both beams cross
bang=0  ; angle of main beam
bv=[-cos(bang),sin(bang),0]

bang2= -4*!dtor ; angle of secondary beam
bv2=[-cos(bang2),sin(bang2),0]



r0=1800.
r1=2300.
y0=b0(1)
x0=sqrt(r0^2 - y0^2)
y1=b0(1)
x1=sqrt(r1^2 - y1^2)

nth=11
ba=[x0,y0,0]
bb=[x1,y1,0]
b=fltarr(nth,3)
l=linspace(0,1,nth)
for i=0,nth-1 do b(i,*)= l(i) * ba + (1-l(i)) * bb ; create an arra b of points along first beam
r=sqrt(b(*,0)^2 + b(*,1)^2)
p02=transpose(p0 # replicate(1,nth))
pv=b-p02 ; get the pointing vector of those points
for i=0,nth-1 do pv(i,*) = pv(i,*) / sqrt(total(pv(i,*)^2))

dp1=total( (replicate(1,nth) # bv) * pv,2)
dp2=total( (replicate(1,nth) # bv2) * pv,2) ; dot products


echarge=1.6e-19
mi=2*1.67262158e-27;deuterium
clight=3e8

;en1=60e3
;en2=95e3
;
;en2=60e3
;en1=95e3;;
;
;en2=95e3
;en1=95e3

;en1=86e3
;en2=90e3

;en2=82e3
;en1=94e3

en1=90e3
en1=87e3

ds1=sqrt(2*echarge*en1 / (mi)) / clight * 656. * dp1 + 656.1 ; doppler shift

ds2=sqrt(2*echarge*en2 / (mi)) / clight * 656. * dp2 + 656.1

plot,r,ds1,/yno,yr=[658,663],ysty=1,title=string(en1,en2,format='("beam1:",G0," beam2:",G0)'),thick=3,xtitle='R on beam1'
oplot,r,ds2,col=2,thick=3
legend,['beam1(horiz one)','beam2 (outboard one)','cwlshifted','50pc','10pc','1pc'],textcol=[1,2,3,4,5,6],/right


pvc=pv(nth/2,*) ; centre point
pv2=pv


ang=atan(pvc(1),pvc(0))
rmat=[[cos(ang),sin(ang),0],[-sin(ang),cos(ang),0],[0,0,1]] ; rotation matrix
pv2r=pv2
for i=0,nth-1 do begin
pv2r(i,*)=rmat ## pv2(i,*)
endfor
theta=atan(pv2r(*,1),pv2r(*,0)) ; angles wrt central ray
;demag = 400./80. * 135. / 300.
demag = 400./80. * 105. / 300. ; demag according to front lenses

thetatilt=-2*!dtor ; tilt of lens
thetad=theta/demag - thetatilt ; angle on filter
;plot,r,theta 
;oplot,r,theta/demag,col=2


ref=2.0
blueshift=656*(1-SQRT(ref^2-SIN(thetad)^2)/ref);  blue shift of filter

cwl=661.09

oplot,r,cwl+r*0,col=3,linesty=2
;oplot,r,cwl-blueshift,col=4
;retall


fwhm=1.9
fw10pc=2.64
fw1pc=3.85
a=[0,fwhm,fw10pc,fw1pc]
sg=[-1,1]
for i=0,1 do begin
    for j=0,3 do begin
        oplot,r,-blueshift+ (cwl+sg(i) * a(j)/2 ),col=j+3
    endfor
endfor


end


