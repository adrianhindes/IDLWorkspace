@sbshape
pro calcbsnew2,p0cm,cdir,ssum,prof2,ductdst,beam=bm,dstmin=dstmin,dstchord=dstchord,cutdown=cutdown

b0pos=[3445,-1378,0.]/1000.
B_xi= -178.186*!dtor
B_delta=90*!dtor
b0dir = ([cos(B_xi)*sin(B_delta), sin(B_xi)*sin(B_delta), cos(B_delta)])
b0dir=b0dir/norm(b0dir)

p0=p0cm*0.01

nch=n_elements(p0(0,*))

nl=31
larr=linspace(-.3,.3,nl) ; m
p=fltarr(3,nch,nl)

ra=fltarr(nch,nl)
za=fltarr(nch,nl)
dl=larr(1)-larr(0)
ssum=fltarr(nch)
initbeam,beam=bm,cutdown=cutdown
ductdst=fltarr(nch)
prof2=fltarr(nch,nl)
dstmin=fltarr(nch)
dstchord=fltarr(nch)
for i=0,nch-1 do begin
;epro solint, B0,Bv, C0, Cv,coord,coordb,a,b
    solint,b0pos,b0dir,p0(*,i),cdir(*,i),coord,coordb,a,b ; m
    ;b is distance from p0 and coord is position 
    dstmin(i)=sqrt(total( (coord-coordb)^2 ))

    ductdst(i)=a

    len=larr + b
    dstchord(i)=b
    prof=fltarr(nl)
    for j=0,nl-1 do begin
        p(*,i,j)=(p0(*,i) + len(j)*cdir(*,i)) ;m
        beama,reform(p(*,i,j)),s,dum ; m
        ssum(i)=ssum(i)+total(s)
        prof(j)=total(s)
;        if j mod 10 eq 0 then print,i,j
    endfor
    print,i,nch
    prof2(i,*)=prof
;    stop
endfor

;stop

end
