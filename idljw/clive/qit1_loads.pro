;lshift=[0.0599365, 0.0374756, 0.0149536, 0, 0, 0, 0.00744629,
;0.0224609, 0.0449829, 0.0674438]

pro qit1_loads,sh,ifr,xr=xr
restore,file='~/idl/clive/shot_spectrometer_mapping_29_oct_2013_template.sav' 
dat=read_ascii('~/idl/clive/shot_spectrometer_mapping_29_oct_2013.csv',template=templ)
idx=where(sh eq dat.(1))
if idx(0) eq -1 then return
fil=(dat.(0))(idx)
read_spe,'~/greg/'+fil,l,t,d
l=reverse(l)
if median(l) ge 600 and median(l) le 700 then lshift=[-8, -5, -2, 0, 0, 0, -1, -3, -6, -9];660
if median(l) ge 400 and median(l) le 550 then lshift=[-3, -2, -1, 0, 0, 0, -1, -2, -3, -4];540

;lshift(0)=lshift(1)
;lshift(9)=lshift(8)
nch=10
nt=n_elements(t)
for i=0,nch-1 do begin
for j=0,nt-1 do begin
   d(*,i,j)=shift(d(*,i,j),-lshift(i))
endfor
endfor
d=float(d)
dback=d(*,*,0) * 0
for i=7,10 do dback+=d(*,*,i)
dback/=4
for i=0,nt-1 do begin
   d(*,*,i)-=dback
endfor
if ifr eq -1 then dsel=totaldim(d,[0,0,1]) else dsel=d(*,*,ifr)
for i=0,nch-1 do begin
;   dsel(*,i)=median(dsel(*,i),5)
endfor

plotm,l,dsel>1,xr=xr,xsty=1,/ylog
read,'nlines',nlines
meth=''
read,'method (sum or max)',meth
lleft=fltarr(nlines)
lright=fltarr(nlines)
for i=0,nlines-1 do begin
   print,'click left side line ',i
   cursor,dx,dy,/down
   oplot,dx*[1,1],10^!y.crange,col=3
   lleft(i)=dx
   print,'click right side line ',i
   cursor,dx,dy,/down
   oplot,dx*[1,1],10^!y.crange,col=4
   lright(i)=dx
endfor

inten=fltarr(nlines,nch)
for i=0,nlines-1 do begin
   for j=0,nch-1 do begin
      inten(i,j)=meth eq 'sum' ? total(dsel(value_locate(l,lright(i)):value_locate(l,lleft(i)),j)) : max(dsel(value_locate(l,lright(i)):value_locate(l,lleft(i)),j))
   endfor
endfor
donorm=0
read,'normalize? (1=yes)',donorm
if donorm eq 1 then begin
   for i=0,nch-1 do begin
      inten(*,i)=inten(*,i)/total(inten(*,i))
   endfor
endif


plotm,transpose(inten),xtitle='ch #'
lam=(lleft+lright)/2

legend,string(lam),textcol=indgen(nlines)+1,/right

stop


end




;qit1_loads,81131,5

;end
