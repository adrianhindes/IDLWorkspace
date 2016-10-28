;dum=read_ascii('~/a.txt',delim=' ')
;dum=read_ascii('~/c.txt',delim=' ')
;dum=read_ascii('~/f.txt',delim=' ')
;dum=read_ascii('~/h.txt',delim=' ')
;dum=read_ascii('~/i.txt',delim=' ')
;dum=read_ascii('~/j.txt',delim=' ');cold wed
dum=read_ascii('~/k.txt',delim=' ');hot wed ;ng
;dum=read_ascii('~/l.txt',delim=' ');cold thur g


;dum=read_ascii('~/m.txt',delim=' ');hot thur
;dum=read_ascii('~/n.txt',delim=' ');med temp thur full sys
;dum=read_ascii('~/o2.txt',delim=' '); o and o2 dadaset fri morn
;dum=read_ascii('~/p2.txt',delim=' ') ; p is good with he
rememb=1
x=dum.(0)
;ind=[0,5,10]
nl=7
ind=findgen(nl) * 5;[0,5,10,15]
en=x(*,ind+1) 
lam=x(*,ind+0)
pcent= x(*,ind+2)
ptotal=x(*,ind+3)
corr=x(*,ind+4); *0. + randomu(sd,4,6)


;ptotal(*,6)=ptotal(*,3)
;en(*,6)=en(*,3)
;lam(*,6)=lam(*,3)

;ptotal(*,4)=ptotal(*,3)
;en(*,4)=en(*,3)
;lam(*,4)=lam(*,3)

aen=en;abs(en)


;idx=sort(en(

;; ord=transpose([$
;; [0,1,2],$
;; [1,-1,-3],$
;; [1,0,-1],$
;; [0,0,0]])


if rememb eq 0 then ord=fltarr(4,nl)

;ord(3,*)=ord(3,*)+[0,-4,-6]
pos=posarr(2,4,0)
if rememb eq 0 then parsave=fltarr(2,nl)
a=1
m=1L
nslope=81
nn=(2*m+1)^7 * nslope
csave=fltarr(nn)
j0save=csave
j1save=csave
j2save=csave
j3save=csave
j4save=csave
j5save=csave
j6save=csave

slrng=[-0.2,0.2]*10
base_slope=linspace(slrng(0),slrng(1),nslope)

sl=csave
off=csave

en2=en*0
en2f=en*0
for ii=0,3 do begin
;   ord(ii,*)=round(en(ii,*)-en(ii,0)*0)*0.
   kk=0L
   for jslope=0,nslope-1 do begin
      guess1=(aen(ii,*)-aen(ii,nl/2)) * base_slope(jslope)
      ford=fix(guess1)
;      print,'ford=',ford,'for slope is ',base_slope(jslope)

      for j0=-m,m do for j1=-m,m do for j2=-m,m do for j3=-m,m do for j4=-m,m do for j5=-m,m do for j6=-m,m do begin
         ordc1=[j0,j1,j2,j3,j4,j5,j6]
         ordc=ordc1 + ford
         j0save(kk)=ordc(0)
         j1save(kk)=ordc(1)
         j2save(kk)=ordc(2)
         j3save(kk)=ordc(3)
         j4save(kk)=ordc(4)
         j5save(kk)=ordc(5)
         j6save(kk)=ordc(6)
         merr=replicate(1,7)
;         if ii eq 3 then merr(4)=1e9
         par=linfit(aen(ii,*),ptotal(ii,*)+ordc,yfit=yfit,chisqr=c,measure_errors=merr)
         sl(kk)=par(1)
         off(kk)=par(0)
;      print,kk
;      print,ordc
;      print,c
;      print,par
         
         csave(kk)=c
         kk=kk+1
      endfor
   endfor

   idx=lindgen(n_elements(csave))
   dum=min(csave(idx),imin) & imin=idx(imin)
   ordc=[j0save(imin),j1save(imin),j2save(imin),j3save(imin),j4save(imin),j5save(imin),j6save(imin)]*1


   if rememb eq 0 then ord(ii,*)=ord(ii,*)*0+ordc


;stop
;   if ii eq 3 then $
;      ord(ii,*)=[-5,-4,-3,-1,0,0,2]+[0.5,0.5,0.5,-0,0,0,0]

;   if ii eq 2 then $
;      ord(ii,*)=[ 4, 3, 2, 1,0,0,-1]

;   if ii eq 0 then $
;      ord(ii,*)=[-2,-1,0,0,0,0,1]
         merr=replicate(1,7)
;         if ii eq 3 then merr(4)=1e9

   par=linfit(en(ii,*),ptotal(ii,*)+ord(ii,*),yfit=yfit,chisqr=c,measure_errors=merr)

;   ord(ii,*)-=round(par(0))
   par=linfit(en(ii,*),ptotal(ii,*)+ord(ii,*),yfit=yfit,chisqr=c)

   en2(ii,*)=a*en(ii,*)+corr(ii,*)+ord(ii,*)
   en2f(ii,*)=yfit
   ords=ord ;& ords(ii,*)=ords(ii,sort(ords(ii,*)))
   ss=1;en(ii,0)/aen(ii,0)
   plot,aen(ii,*),ss*(ptotal(ii,*)+ord(ii,*)),pos=pos,noer=ii gt 0,title=string(ii,c,ords(ii,0),ords(ii,1),ords(ii,2),ords(ii,3),ords(ii,4),ords(ii,5),ords(ii,6), format='(I0," ",G0," ",6(I0," "),I0)'),/yno,psym=4
print,par
if rememb eq 0 then parsave(*,ii)=par else yfit=parsave(0,ii)+parsave(1,ii)*aen(ii,*)


oplot,aen(ii,*),yfit*ss,col=2

;plot,en(ii,*),ptotal(ii,*),title=ii,pos=pos,psym=4,noer=ii gt 0



pos=posarr(/next,/quiet)

   plot,aen(ii,*),ss*(ptotal(ii,*)+ord(ii,*) - yfit),pos=pos,/noer,psym=4
pos=posarr(/next,/quiet)
;  4.57400e-07
;  4.65100e-07
;  4.75700e-07
;  4.87200e-07
;  4.87200e-07
;  5.00900e-07
;  4.87200e-07
ltrue=[457.93,$;8.98,$
       465.79,$
       476.48,$
       487.98,$
       496.51,$
;       487.98,$
       501.71,$
;       487.98]*1e-9
       514.53]*1e-9
;plot,aen(ii,*),(lam(ii,*)-ltrue)*1e9-0.5,psym=4,pos=posarr(/next),/noer

;stop

endfor

;'print,en2-en2f


save,parsave,file='~/c_analysed.sav',/verb

end
