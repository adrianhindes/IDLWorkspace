pro gethelrnew, sh,temp,doplot=doplot
;read_spe,'~/share/greg/ipad_1000ms_717nm.spe',l,t,d
read_spe,'~/share/greg/ipad_500ms_portwin_wed.spe',l,t,d
factor1=totaldim(d(512,*,50:70),[0,0,1])/21.
factor1/=max(factor1)
factor=rebin(factor1,20)
read_spe,'~/share/greg/shaun_'+string(sh,format='(I0)')+'.spe',l,t,d & lc0=[706,728.,726.]

l=reverse(l)

tarr=-22 + findgen(11) * 11.


;stop
iframe=2
iframe0=0


wid=2.
nl=n_elements(lc0)
nch=20
sig=fltarr(nch,nl)
for i=0,nl-1 do begin
   ix=where(l ge lc0(i)-wid/2 and l le lc0(i)+wid/2)
   sig(*,i) = total(d(ix,*,iframe),1) - total(d(ix,*,iframe0),1)
   sig(*,i) = sig(*,i) / factor
   if i ge 1 then sig(*,i)=sig(*,i)*10
endfor
sig(*,1) = sig(*,1)-sig(*,2)
sig(*,2)=0.
sig(*,1) = sig(*,1) / 0.6 ;; boost 728 for lower sensitivity

rat=sig(*,1)/sig(*,0) / 10.

rat1=rat(8)

temp=interpol([10.,50.],[.15,.35],rat1)
if keyword_set(doplot) then begin
   plotm,sig>0,title=string(sh)
   plot,sig(*,1)/sig(*,0),yr=[0,3],/noer,col=6

stop
endif


end
