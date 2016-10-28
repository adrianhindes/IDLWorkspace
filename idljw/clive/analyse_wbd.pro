;dum=read_ascii('~/a.txt',delim=' ')
dum=read_ascii('~/c.txt',delim=' ')
dum=read_ascii('~/f2.txt',delim=' ')
x=dum.(0)
;ind=[0,5,10]
nl=6
ind=findgen(nl) * 5;[0,5,10,15]
en=x(*,ind+1) 
aen=abs(en)
lam=x(*,ind+0)
pcent= x(*,ind+2)
ptotal=x(*,ind+3)
corr=x(*,ind+4); *0. + randomu(sd,4,6)

;idx=sort(en(

;; ord=transpose([$
;; [0,1,2],$
;; [1,-1,-3],$
;; [1,0,-1],$
;; [0,0,0]])
ord=fltarr(4,nl)

;ord(3,*)=ord(3,*)+[0,-4,-6]
pos=posarr(2,4,0)
parsave=fltarr(2,nl)
a=1
m=3L
nn=(2*m+1)^6
csave=fltarr(nn)
j0save=csave
j1save=csave
j2save=csave
j3save=csave
j4save=csave
j5save=csave

sl=csave
off=csave

en2=en*0
en2f=en*0
for ii=0,3 do begin
   ord(ii,*)=round(en(ii,*)-en(ii,0)*0)*0.
   kk=0L
   for j0=-m,m do for j1=-m,m do for j2=-m,m do for j3=-m,m do for j4=-m,m do for j5=-m,m do begin
      ordc=[j0,j1,j2,j3,j4,j5]
      j0save(kk)=j0
      j1save(kk)=j1
      j2save(kk)=j2
      j3save(kk)=j3
      j4save(kk)=j4
      j5save(kk)=j5
      
      par=linfit(en(ii,*),ptotal(ii,*)+ordc,yfit=yfit,chisqr=c)
      sl(kk)=par(1)
      off(kk)=par(0)
;      print,kk
;      print,ordc
;      print,c
;      print,par

      csave(kk)=c
      kk=kk+1
   endfor
   idx=where(sl*0 eq 0)
   dum=min(csave(idx),imin) & imin=idx(imin)
   ordc=[j0save(imin),j1save(imin),j2save(imin),j3save(imin),j4save(imin),j5save(imin)]*1
   ord(ii,*)=ord(ii,*)*0+ordc
   par=linfit(en(ii,*),ptotal(ii,*)+ord(ii,*),yfit=yfit,chisqr=c)

;   ord(ii,*)-=round(par(0))
;   par=linfit(en(ii,*),ptotal(ii,*)+ord(ii,*),yfit=yfit,chisqr=c)

   en2(ii,*)=a*en(ii,*)+corr(ii,*)+ord(ii,*)
   en2f(ii,*)=yfit
   ords=ord & ords(ii,*)=ords(ii,sort(ords(ii,*)))
   plot,aen(ii,*),ptotal(ii,*)+ord(ii,*),pos=pos,noer=ii gt 0,title=string(ii,c,ords(ii,0),ords(ii,1),ords(ii,2),ords(ii,3),ords(ii,4),ords(ii,5),$
                                                                                   format='(I0," ",G0," ",5(I0," "),I0)'),/yno,psym=4
print,par
parsave(*,ii)=par
oplot,aen(ii,*),yfit,col=2

;plot,en(ii,*),ptotal(ii,*),title=ii,pos=pos,psym=4,noer=ii gt 0



pos=posarr(/next,/quiet)

   plot,aen(ii,*),ptotal(ii,*)+ord(ii,*) - yfit,pos=pos,/noer,psym=4
pos=posarr(/next,/quiet)

;stop
endfor

print,en2-en2f


save,parsave,file='~/c_analysed.sav',/verb

end
