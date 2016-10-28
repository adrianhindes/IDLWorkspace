@pr_prof2
;goto,ee

sh=[82823,intspace(82811,82819)]
nsh=n_elements(sh)
rad=fltarr(nsh)
isat=fltarr(nsh)
vfl=fltarr(nsh)
vpl=fltarr(nsh)
lint=fltarr(nsh)
for i=0,nsh-1 do begin
readpatchpr,sh(i),str,data=data,file='BPP_FP_settings.csv'
rad(i)=str.bpprad

endfor

idx=sort(rad)
sh=sh(idx)
rad=rad(idx)
pos=posarr(3,3,0)
;mkfig,'~/pr_spec2.eps',xsize=27,ysize=20,font_size=8
erase

ftrial=10e3&fw=2e3
;ftrial=35e3 &fw=15e3
for i=1,nsh-1 do begin
   mode='isat'
   doit,sh(i),ff=f,s1s=s1s,mode=mode,/just;,dostop=i eq 3
   if mode eq 'vfloat' then yr=[-6,2] else yr=[-14,-3]
   plot,f/1e3,alog10(s1s),title='R='+string(rad(i),format='(G0)'),xr=[100,500e3]/1e3,/noer,pos=pos,xtitle='Freq/kHz',ytitle='Log power',yr=yr,/xlog
;   oplot,(ftrial-[1,1]*fw/2)/1e3,!y.crange,linesty=1,col=2
;   oplot,(ftrial+[1,1]*fw/2)/1e3,!y.crange,linesty=1,col=2
   pos=posarr(/next)
;stop
endfor
endfig,/gs,/jp
end
