pro probe_fluc,sh,xr=xr,fr=fr,zrm=zrm,zri=zri,df=df,dt=dt,nohan=nohan,minc=minc,chan=chan
default,chan,'isat'
default,dt,3e-3
default,df,3e3
default,fr,[0,500e3]
default,zrm,[-7,-2]
default,zri,[-10,-2]
default,xr,[0,.05]

mdsopen,'h1data',sh
if chan eq 'isat' then num =4
if chan eq 'vfloat' then num=3
if chan eq 'vplas' then num=2
if n_elements(num) gt 0 then $
   cur=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_'+string(num,format='(I0)'),/nozero) $
else begin
   if chan eq 'temp' then begin
      vfl=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_3',/nozero) 
      vpl=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_4',/nozero) 
      cur=vfl & cur.v = vfl.v-vpl.v
   endif
   if chan eq 'isatfork' then begin
      cur=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_09:INPUT_6',/nozero)
   endif
   if chan eq 'vfloatfork' then begin
      cur=mdsvalue2('\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_09:INPUT_3',/nozero)
   endif

endelse


mirn=mdsvalue2('\H1DATA::TOP.MIRNOV.ACQ132_7:INPUT_01',/nozero)

   
;rf=mdsvalue2('\H1DATA::TOP.RF:P_RF_NET',/nozero)
ihel=mdsvalue2('\h1data::top.operations:magnetsupply:prog_i_sec',/nozero)
imain=mdsvalue2('\h1data::top.operations:magnetsupply:prog_i_main',/nozero)

rf={t:mirn.t,v: interpol(ihel.v,ihel.t,mirn.t) /  interpol(imain.v,imain.t,mirn.t)}




plot,cur.t,cur.v,pos=posarr(2,3,0),title=chan+' #'+string(sh,format='(I0)'),xsty=1,xr=xr,/yno

spectdata2,interpol(cur.v,cur.t,mirn.t),ps,t1,f1,t0=min(mirn.t),fdig=1/(mirn.t(1)-mirn.t(0)),dt=dt,nohan=nohan,df=df
imgplot,alog10(ps),t1,f1,pos=posarr(/next),/noer,title='ps '+chan,xr=!x.crange,xsty=1,/cb,zr=zri,yr=fr

plot,mirn.t,mirn.v,/noer,pos=posarr(/next),title='mirn',xr=!x.crange,xsty=1

spectdata2,mirn.v,ps2,t2,f2,t0=min(mirn.t),fdig=1/(mirn.t(1)-mirn.t(0)),dt=dt,nohan=nohan,df=df
imgplot,alog10(ps2),t2,f2,pos=posarr(/next),/noer,title='ps mirn',xr=!x.crange,xsty=1,/cb,zr=zrm,yr=fr

plot,rf.t,rf.v,/noer,pos=posarr(/next),xr=!x.crange,xsty=1,title='rf',/yno

spectdata2c,mirn.v,interpol(cur.v,cur.t,mirn.t),cc,t3,f3,t0=min(mirn.t),fdig=1/(mirn.t(1)-mirn.t(0)),dt=dt,nohan=nohan,df=df

cc=cc/sqrt(ps*ps2)
default,minc,0.4
idx=where(abs(cc) lt minc)
if idx(0) ne -1 then cc(idx)=0
imgplot,(abs(cc)),t2,f2,pos=posarr(/next),/noer,title='cc '+chan+' mirn',xr=!x.crange,xsty=1,/cb,yr=fr,zr=[minc,1]
stop



;stop
end
;probe_fluc,81752,xr=[0,.1],minc=1e-2,chan='vplas'
;end
