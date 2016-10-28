pro bulgeclamps,ln,ang,title,lns0

p0=ln(0,*)
p1=ln(1,*)

vec=p1-p0

rad1=30.
rad2=48.

zhat = vec

xhat = crossp(zhat,[0,0,1.]) & xhat/=norm(xhat)
yhat=crossp(xhat,zhat)& yhat/=norm(yhat)
ang2=ang+50./480.
vd = cos(ang) * xhat + sin(ang) * yhat
vd2 = cos(ang2) * xhat + sin(ang2) * yhat
np=1
lns=fltarr(3,2,4)

lns(*,0,0)=vd*rad2+p0
lns(*,1,0)=vd*rad2+p1

lns(*,0,1)=vd*rad2+p0
lns(*,1,1)=vd2*rad2+p0

lns(*,0,2)=vd2*rad2+p0
lns(*,1,2)=vd2*rad2+p1

lns(*,0,3)=vd*rad2+p1
lns(*,1,3)=vd2*rad2+p1

lns=lns*10;cmtomm

if n_elements(lns0) eq 0 then lns0=lns else $
lns0=[[[lns]],[[lns0]]]

end

; for left coil coords of centre are



;  from point, X= 121.3262  Y=  -3.9502  Z=  -4.3000
;                to point, X= 120.8968  Y= -10.9370  Z=  -4.3000
ln=[[120.8968 , -10.9370,  -4.3000],[ 121.3262,  -3.9502,  -4.3000]]

;ln2=[[116.6739, -19.0064,   -11.5500],[115.3443, -25.8790, -11.5500]]
ln2=[[115.3443, -25.8790, -11.5500],[116.6739, -19.0064,   -11.5500]]



ln=transpose(ln)
ln2=transpose(ln2)

restore,file='~/rsphy/newwrl/h1aEshow.sav',/verb
bulgeclamps,ln,62*!dtor,'try1',lns

bulgeclamps,ln2,65*!dtor,'try1',lns

save,lns,fcb,file='~/rsphy/newwrl/h1aEbulgeshow.sav',/verb

;save,lns,file='~/rsphy/newwrl/bulge'+title+'show.sav',/verb
stop





;; next coil pts are

;;    from point, X= 115.3443  Y= -25.8790  Z= -11.5500
;;                 to point, X= 116.6739  Y= -19.0064  Z= -11.5500


end
