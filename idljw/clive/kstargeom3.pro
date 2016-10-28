function rotd,th,ix
if ix eq 2 then begin&i1=0&i2=1&end
if ix eq 1 then begin&i1=0&i2=2&end
if ix eq 0 then begin&i1=1&i2=2&end
mat=identity(3)
mat(i1,i1)=cos(th)
mat(i1,i2)=sin(th)
mat(i2,i1)=-sin(th)
mat(i2,i2)=cos(th)
return,mat
end

;pro kstargeom1

;b0=[3445,-1378,0.]
;b1=[1487,-1440,0.]

ang=-24.3*!dtor
mat=[[cos(ang),sin(-ang),0],$
     [sin(ang),cos(ang),0],$
     [0,0,1]]

rt=1485.
pp=[1485,3399,0.] ; point through which both beams cross {mm->cm)
b0a=[rt,sqrt(-rt^2+2070.^2),0]
b1a=[rt,sqrt(-rt^2+1800.^2),0]
b0=mat # b0a
b1=mat # b1a

;b1=b0 + [0,0,100.]
;b0=[1440,-1487.,0] ; middle of field
;b1=[1013,-1487.,0] ; beam inner point near mag axis

p0=[-982.,2576,275]

zhat=b0-p0 & zhat/=norm(zhat)
xhattmp=b1-b0 & xhattmp/=norm(xhattmp)
yhat=crossp(zhat,xhattmp) & yhat/=norm(yhat)

xhat=crossp(zhat,yhat)

b12 = rotd(1*!dtor,2) # zhat


xhattmp2=b12 & xhattmp2/=norm(xhattmp2)
yhat2=crossp(zhat,xhattmp2) & yhat2/=norm(yhat2)

xhat2=crossp(zhat,yhat2)

print,'the roll is',acos(total(xhat2 * xhat))*!radeg

; reflect mirror
tht=22.5*!dtor+90*!dtor
;tht=24.3*!dtor+90*!dtor
p1 = p0+1000. * [cos(tht),sin(tht),0]

zhatr=p1-p0  & zhatr/=norm(zhatr)

mvec = (zhatr + (-zhat))/2
mvec/=norm(mvec)


ahat=b1-p0 & ahat/=norm(ahat)

;chat=b0+[0,0,1] - p0 & chat/=norm(chat)
;chat = crossp([0,0,1],zhat) &  chat = -crossp(chat,zhat) & chat/=norm(chat)
chatx = crossp([0,0,1],zhat) &  chatx/=norm(chatx)
chaty = crossp(chatx,zhat) &  chaty/=norm(chaty)


plot, [-2000,2000]*1.5,[-2000,2000]*1.5,/nodata,/iso
th=linspace(0,2*!pi,100) & oplot,1800*cos(th),1800*sin(th),col=2
plots,p0(0),p0(1),psym=4
oplot,[b0(0),b1(0)],[b0(1),b1(1)],col=3,psym=-4
l=-1000
oplot,b0(0)+[0,zhat(0)*l],b0(1)+[0,zhat(1)*l],col=4
oplot,b0(0)+[0,chaty(0)*l],b0(1)+[0,chaty(1)*l],col=5
oplot,b0(0)+[0,chatx(0)*l],b0(1)+[0,chatx(1)*l],col=6

plots,p1(0),p1(1),psym=4

oplot,[p0(0),p1(0)],[p0(1),p1(1)],col=4
;stop

bhat=b12 & bhat/=norm(bhat)

zhatr2 = zhat - 2 * (total(zhat*mvec)) * mvec

ahatr2 = ahat - 2 * (total(ahat*mvec)) * mvec

chatr2 = chat - 2 * (total(chat*mvec)) * mvec


bhatr2 = bhat - 2 * (total(bhat*mvec)) * mvec


print,zhatr2
print,ahatr2
print,bhatr2
bxhat =- crossp(zhatr,[0,0.,1.])

oplot,p1(0)+[0,bxhat(0)*l],p1(1)+[0,bxhat(1)*l],col=4
ahatr2_y=total(ahatr2 * [0,0,1.])
ahatr2_x=total(ahatr2 * bxhat)

print,ahatr2_x,ahatr2_x,'is beam coord'
print,'det plane angle=',atan(ahatr2_y,ahatr2_x)*!radeg
;;;

;chatr2_y=total(chatr2 * [0,0,1.])
;chatr2_x=total(chatr2 * bxhat)

;print,'vert efield becomes     =',atan(chatr2_y,chatr2_x)*!radeg

;print,'rel angle=',acos(total(zhat * zhatr))*!radeg

end



