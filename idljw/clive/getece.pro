pro getch,i,v=v,t=t,freq=freq,g=g
nd=string(i,format='(I2.2)')
nam1='\ECE'+nd
;nam1='\ELECTRON::ECE'+nd+':CAL'
;nam1='\ELECTRON::ECE'+nd+':F00'

;nam2='\ELECTRON::ECE'+nd+':RPOS2ND'
nam2='\KSTAR::TOP.ELECTRON.ECE_HR:ECE'+nd+':FREQ'
nam3='\KSTAR::TOP.ELECTRON.ECE_HR:ECE'+nd+':GOOD'
d=cgetdata(nam1)
v=d.v
t=d.t
d2=cgetdata(nam2)
freq=d2.v

d3=cgetdata(nam3)
g=d3.v

;v=mdsvalue(nam1)
;t=mdsvalue('DIM_OF('+nam1+')')
;r=mdsvalue(nam2)

end

pro getchall,v=v,t=t,freq=freq,g=g
nch=72
common cbshot, shotc,dbc, isconnected

if shotc ge 9323 and shotc le 9327 then nch=48
ch=indgen(nch)+1
nch=n_elements(ch)
;sh=8019
for i=0,nch-1 do begin
    getch,ch(i),v=v1,t=t1,freq=freq1,g=g1
    if i eq 0 then begin
        nt=n_elements(t1)
        t=t1
        freq=fltarr(nch)
        g=freq
        v=fltarr(nt,nch)

    endif
    v(*,i)=v1
    freq(i)=freq1
    g(i)=g1
    print, 'done ch',i,'of',nch
endfor
end

pro getece, sh,res,t,v,tr=tr,alt=alt,timeres=timeres

common cbshot, shotc,dbc, isconnected

shotc=sh
;8093;7581;665;7935;8032;18;5950;6200;8019
dbc='kstar'

tab=[$
[11433, 2.0],$
[11434, 2.0],$
[10997, 2.7],$
[11003, 2.85],$
[11004, 3.15],$
[9323, 3.0],$
[9324, 3.0],$
[9326, 3.0],$
[9327, 3.0],$
[13355, 1.8],$
[13366,2.0],$
[13491,2.0],$
[13492,2.7],$
[13494,2.7]]

sh1=tab(0,*)
b1=tab(1,*)
;ii=value_locate(sh1,sh)
dum=min(abs(sh1-sh),ii)
if sh1(ii) ne sh then stop
bb=b1(ii)*1e4 ; to gauss




;mdsopen,'kstar',sh

getchall,v=v,t=t,freq=freq,g=g
;mdsdisconnect

dt=t(1)-t(0)
nt=n_elements(t)
default,timeres,10e-3
default, tr, minmax(t)
nsm=timeres/dt
ii=value_locate(t,[tr(0)-timeres,tr(1)+timeres])
ii=ii>0<(nt-1)
nch=n_elements(freq)
nt2=ceil( (tr(1)-tr(0))/timeres )
t2=findgen(nt2) * timeres + tr(0)
v2=findgen(nt2,nch)
for i=0,nch-1 do begin
   dum=smooth(v(ii(0):ii(1),i),nsm)
   v2(*,i)=interpol(dum,t(ii(0):ii(1)), t2)
endfor

   

;t2=congrid(t,1000)
;v2=congrid(v,1000,n_elements(freq))

;imgplot,v2,t2,-r,zr=[0,2000]

r2=1.8 * bb/(freq*1e9/2.8e6 / 2)
r3=1.8 * bb/(freq*1e9/2.8e6 / 3)
r1=1.8 * bb/(freq*1e9/2.8e6 / 1)
;; if keyword_set(tr) then begin
;;    idx=where(t2 ge tr(0)  and t2 le tr(1))
;;    t2=t2(idx)
;;    v2=v2(idx,*)
;; endif
bbt=bb/1e4
;if bbt ge 2.7 and bb le 3.2 then rr=r2
;if bbt eq 2.0 then begin
;ia=intspace(0,
ia=where(r2 ge 1.4 and r2 le 2.5)
ib=where(r3 ge 1.4 and r3 le 2.5)
;rr=[r2(ia),r3(ib)]
if ia(0) ne -1 then rr = n_elements(rr) ne 0 ? [rr,r2(ia)] : r2(ia)
if ib(0) ne -1 then rr = n_elements(rr) ne 0 ? [rr,r3(ib)] : r3(ib)


if ia(0) ne -1 then ix = n_elements(ix) ne 0 ? [ix,ia] : ia
if ib(0) ne -1 then ix = n_elements(ix) ne 0 ? [ix,ib] : ib


isrt=sort(rr)
rr=rr(isrt)

ix=ix(isrt)

bad=[27,40,39,59,6,64,65,66,67,68,69,70,71]
nch=n_elements(r1)
g=setcompl(findgen(nch),bad)
isub=where(g(ix) eq 1)
ix=ix(isub)
rr=rr(isub)

isub2=uniq(rr)
rr=rr(isub2)
ix=ix(isub2)


;stop
if keyword_set(alt) then res={ang:v2,t:t2,r1:-r2*100} else $
res={v:v2,t:t2,freq:freq,g:g,r1:r1,r2:r2,r3:r3,bb:bb,rr:rr,ix:ix}
end
pro tst11433
common ab, res,t,v
;getece,11433,res,t,v
plot,res.r2,res.v(600,*),psym=4,yr=[0,1e4]
oplot,res.r3,res.v(600,*),psym=4,col=2  
dum=min(res.r3,imin)
;stop
ns=10
plot,t,smooth(v(*,1),ns),xr=[6.2,6.6],yr=[0,10e3],xsty=1
oplot,t,smooth(v(*,imin-1),ns),col=2

;stop
npl=10
tr=[5,5.4]
;tr=[6.2,6.6]
;tr=[3.6,4.0]+0.2

iw=value_locate(t,tr(0))

rr=[res.r2(1),res.r3(intspace(47-1,47-npl))]
mkfig,'~/ecedatb.eps',xsize=18,ysize=12,font_size=8

plot,t,smooth(v(*,1),ns)-v(iw,1),xr=tr,yr=[-1e3,3e3],xsty=1,ysty=1,/nodata
for i=1,npl-1 do oplot,t,smooth(v(*,47-i),ns)-v(iw,47-i) + i*200,col=i
legend,string(rr),textcol=findgen(11)+1,box=0,/clear
endfig;,/jp,/gs
;stop

rr=[res.r2(1:npl)]
mkfig,'~/ecedat.eps',xsize=18,ysize=12,font_size=8

plot,t,smooth(v(*,1),ns)-v(iw,1),xr=tr,yr=[-1e3,5e3],xsty=1,ysty=1,/nodata
for i=1,npl-1 do if i ne 5 and i ne 6 then oplot,t,smooth(v(*,i),ns)-v(iw,i) + i*200,col=i
legend,string(rr),textcol=findgen(11)+1,box=0,/clear
endfig,/jp,/gs
stop
end

pro tst11434
getece,11434,res,t,v
plot,res.r2,res.v(600,*),psym=4,yr=[0,1e4]
oplot,res.r3,res.v(600,*),psym=4,col=2  
dum=min(res.r3,imin)
stop
ns=10
plot,t,smooth(v(*,1),ns),xr=[3.5,4.5],yr=[0,0e3]
oplot,t,smooth(v(*,imin-1),ns),col=2

end

pro tst11003
common ab, res,t,v
getece,11003,res,t,v
plot,res.r2,res.v(600,*),psym=4,yr=[0,1e4]
oplot,res.r3,res.v(600,*),psym=4,col=2  
dum=min(res.r3,imin)
;stop
ns=10
iw=value_locate(t,3.5)
mkfig,'~/ecedat.eps',xsize=18,ysize=12,font_size=8

plot,t,smooth(v(*,47),ns)-v(iw,47),xr=[4,4.5],yr=[0e3,4e3]
for i=1,10 do oplot,t,smooth(v(*,47-i),ns)-v(iw,47-i) + i*200,col=i+1
legend,string(res.r2(47-indgen(11))),textcol=findgen(11)+1,box=0
endfig,/gs,/jp
stop
end


pro tst11004
common ab, res,t,v
getece,11004,res,t,v
plot,res.r2,res.v(600,*),psym=4,yr=[0,1e4],xr=[1,3]
oplot,res.r1,res.v(600,*),psym=4,col=2  
dum=min(res.r3,imin)
;stop
ns=10*5
iw=value_locate(t,3.5)
mkfig,'~/ecedat.eps',xsize=18,ysize=12,font_size=8
plot,t,smooth(v(*,47),ns)-v(iw,47),xr=[4,4.5],yr=[-5e3,5e3]/5
for i=1,3 do oplot,t,smooth(v(*,47-i),ns)-v(iw,47-i) + i*200,col=i+1
legend,string(res.r2(47-indgen(11))),textcol=findgen(11)+1,box=0
endfig,/gs,/jp
stop
end

pro tst9323
common ab, res,t,v
;getece,9323,res,t,v
plot,res.r2,res.v(600,*),psym=4,yr=[0,1e4],xr=[1,3]
oplot,res.r3,res.v(600,*),psym=4,col=2  
oplot,res.r1,res.v(600,*),psym=4,col=3
dum=min(res.r3,imin)
;stop
ns=10
iw=value_locate(t,3.5)
mkfig,'~/ecedat.eps',xsize=12,ysize=12,font_size=10
plot,t,smooth(v(*,47),ns)-v(iw,47),xr=[4,4.5],yr=[-5e3,5e3]/2
for i=1,10 do oplot,t,smooth(v(*,47-i),ns)-v(iw,47-i) + i*200,col=i+1
legend,string(res.r2(47-indgen(11))),textcol=findgen(11)+1,box=1,/clear
endfig,/gs,/jp
stop
end



pro tst13355b
  common ab, res,t,v
  ;getece,13355,res,t,v,timeres=0.25e-3,tr=[2,3]
  plot,res.r2,res.v(600,*),psym=4,yr=[0,1e4],xr=[1,3]
  oplot,res.r3,res.v(600,*),psym=4,col=2
  oplot,res.r1,res.v(600,*),psym=4,col=3
  dum=min(res.r3,imin)
  stop
  ns=10
  ;tr=[3.9,4.3+0.4];[3.55,4.7]
  tr=[7.9,8.3];[6,11];[9.9,10.3]
  tr=[2,3]
  iw=value_locate(t,tr(0))
  ch0=47
  npl=35
  ;mkfig,'~/ecedat.eps',xsize=18,ysize=12,font_size=8
  ;goto,sk
  plot,t,smooth(v(*,47),ns)-v(iw,47),xr=tr,yr=[0e3,7e3],xsty=1
  for i=1,npl-1 do oplot,t,smooth(v(*,47-i),ns)-v(iw,47-i) + i*200,col=i+1
  legend,string(res.r2(47-indgen(npl))),textcol=findgen(npl)+1,box=1,/clear
  endfig,/gs,/jp


  cursor,dx,dy,/down

  cursor,dx2,dy,/down
  idx=value_locate(res.t,dx)
  idx2=value_locate(res.t,dx2)
  sk:
  ;idx=903 & idx2=904
  idx=544 & idx2=558-5
  print,res.t(1)-res.t(0),'is tes'


  plot,res.r2,res.v(idx,*),psym=4
  oplot,res.r2,res.v(idx2,*),psym=4,col=2
  ;stop
  plot,res.r2,res.v(idx,*)/res.v(idx2,*)-1,yr=[-.05,.05]*3,psym=4,xr=[1.7,2],xsty=1,ysty=1

  stop
end


pro tst13355
  common ab, res,t,v
  ;getece,13355,res,t,v,timeres=0.25e-3,tr=[2,3]
  ;getece,11433,res,t,v
  plot,res.r2,res.v(600,*),psym=4,yr=[0,1e4]
  oplot,res.r3,res.v(600,*),psym=4,col=2
  dum=min(res.r3,imin)
  ;stop
  ns=10
  plot,t,smooth(v(*,1),ns),xr=[2,3],yr=[0,10e3],xsty=1
  oplot,t,smooth(v(*,imin-1),ns),col=2

  ;stop
  npl=10
  tr=[2.2,2.4]
  ;tr=[6.2,6.6]
  ;tr=[3.6,4.0]+0.2

  iw=value_locate(t,tr(0))

  rr=[res.r2(1),res.r3(intspace(47-1,47-npl))]
  ;mkfig,'~/ecedatb.eps',xsize=18,ysize=12,font_size=8

  plot,t,smooth(v(*,1),ns)-v(iw,1),xr=tr,yr=[-1e3,3e3],xsty=1,ysty=1,/nodata,pos=posarr(1,2,0)
  for i=1,npl-1 do oplot,t,smooth(v(*,47-i),ns)-v(iw,47-i) + i*200,col=i
  legend,string(rr),textcol=findgen(11)+1,box=0,/clear
  endfig;,/jp,/gs
  ;stop

  mdsopen,'mse_2015_prc',13355
  y=mdsvalue('ANGLESLICE')
  t=mdsvalue('DIM_OF(ANGLESLICE,0)')
  r=mdsvalue('DIM_OF(ANGLESLICE,1)')
contourn2,y,t,-r,pos=posarr(/next),zr=[-20,20],/noer
stop  

  rr=[res.r2(1:npl)]
  ;mkfig,'~/ecedat.eps',xsize=18,ysize=12,font_size=8

  plot,t,smooth(v(*,1),ns)-v(iw,1),xr=tr,yr=[-1e3,5e3],xsty=1,ysty=1,/nodata
  for i=1,npl-1 do if i ne 5 and i ne 6 then oplot,t,smooth(v(*,i),ns)-v(iw,i) + i*200,col=i
  legend,string(rr),textcol=findgen(11)+1,box=0,/clear
  endfig,/jp,/gs
  stop
end

;tst11003;10997
;end
