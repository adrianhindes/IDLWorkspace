@pr_prof2
;goto,ee

sh=[82823,intspace(82811,82819)]
sh=intspace(82135,82143)

sh=[intspace(82140,82141),82136]

sh=[79,78,77,73]+85900L


nsh=n_elements(sh)
rad=fltarr(nsh)
isat=fltarr(nsh)
vfl=fltarr(nsh)
vpl=fltarr(nsh)
lint=fltarr(nsh)
kh=lint
for i=0,nsh-1 do begin
readpatchpr,sh(i),str,data=data,file='BPP_FP_settings.csv'
rad(i)=str.bpprad
kh(i)=str.kh

endfor

idx=sort(kh)
sh=sh(idx)
rad=rad(idx)
kh=kh(idx)
pos=posarr(1,1,0)
;mkfig,'~/pr_spec2.eps',xsize=27,ysize=20,font_size=8
erase

ftrial=10e3&fw=2e3
;ftrial=35e3 &fw=15e3
mn=fltarr(nsh)
st=fltarr(nsh)
st2=st
mkfig,'~/cmode_kh.eps',xsize=13,ysize=10,font_size=11
colarr=[1,2,4]
for i=0,nsh-1 do begin
   mode='isat'
   doit,sh(i),ff=f,s1s=s1s,mode=mode,/just,st=st1,mn=mn1,val=val1;,dostop=i eq 3
   mn(i)=mn1
   st(i)=st1
;   stop
   if mode eq 'vfloat' then yr=[-6,2] else yr=[-14,-3]

s1s=abs(fft(val1))^2
nsm=5
s1s=smooth(s1s,nsm)
;s1s(0)=0
st2(i)=sqrt(total(s1s))
nn=n_elements(val1)
tt=findgen(nn)*1e-6
f=fft_t_to_f(tt)
yr=[-12,-6]
if i eq 0 then    plot,f/1e3,alog10(s1s),xr=[1000,100e3]/1e3,xtitle='Freq/kHz',ytitle='Log power',yr=yr,/xlog,thick=2 else oplot,f/1e3,alog10(s1s),col=colarr(i),thick=2

;if i eq 0 then    plot,f/1e3,(s1s),xr=[00,10000]/1e3,xtitle='Freq/kHz',ytitle=' power',yr=[0,.2e-4]/100 else oplot,f/1e3,(s1s),col=i+1
;   oplot,(ftrial-[1,1]*fw/2)/1e3,!y.crange,linesty=1,col=2
;   oplot,(ftrial+[1,1]*fw/2)/1e3,!y.crange,linesty=1,col=2
;   pos=posarr(/next)
;stop
endfor
legend,string(kh,format='(G0)'),textcol=colarr,/right,box=0
endfig,/gs,/jp
end
