pro loadall,sh,get=get,xr=xr,mdsplus=mdsplus,pre=pre,zr=zr,centpix=centpix,yoffs=yoffs,sm=sm,dummycam=dummycam
; if keyword_set(get) then begin
;     dum=findfile('*'+string(sh,format='(I0)')+'*',count=cnt)
;     if cnt eq 0 then begin
;         cd,current=curr
;         cd,'~/mse_data'
;         spawn,'rmget1 '+string(sh,format='(I0)')
;         cd,curr
;     endif else print,'file exists do nothing'
; endif
;if sh lt 
default,zr,[0,3e3]


if sh ge 8000 then noflc=1 else noflc=0

if sh ge 7930 then sh1=sh-3 else sh1=sh-1
if sh ge 7947 then sh1=sh

sh1=sh
;r=7268;4;61;42;53;41
;r=7241
default,sm,2;4;2;4
;sh=7497;89;31
default,mdsplus,0
seg=0

r=sh
spawn,'hostname',hostname
if hostname eq 'ikstar.nfri.re.kr' then begin
   dum=file_search('~/mse_data/mse_'+string(sh,format='(I0)')+'.datafile',count=cnt)
   if cnt eq 0 then begin
      cd,current=curr
      cd,'~/mse_data'
      if sh lt 7890 then suf='c' else suf=''
;      spawn,'./rmget1'+suf+' '+string(sh,format='(I0)')
      cd,curr
   endif





endif else begin
 mdsconnect,'172.17.250.100:8005'
endelse

mdsopen,'kstar',sh1
;nbi=mdsvalue('\NB1_PB1')
;tnbi=mdsvalue('DIM_OF(\NB1_PB1)')
nbi1=cgetdata('\NB11_I0')
nbi2=cgetdata('\NB12_I0')

ip=cgetdata('\PCRC03')

if hostname ne 'ikstar.nfri.re.kr' then mdsdisconnect


if noflc eq 1 then getflc=0 else getflc=1
img=getimg(sh,pre='',index=0,sm=sm,info=info,/getinfo,mdsplus=mdsplus,flc=flc,getflc=getflc,seg=seg)
nimg=info.num_images


sz=size(img,/dim)
imgs=fltarr(sz(0),sz(1),nimg)
default,pre,''
for i=0,nimg-1 do begin
img=getimg(r,pre=pre,index=i,sm=sm,mdsplus=mdsplus,/rememb,seg=seg)
print,i,nimg
imgs(*,*,i)=img

endfor
bb:
gettim,sh=sh,ft=ft,tstart=tstart
if getflc eq 1 and not keyword_set(dummycam) then ft=info.frame_time 


;tstart=0.
sz=size(imgs,/dim)

topls=totaldim(imgs,[1,1,0])/sz(0)/sz(1) ;average


topl=imgs(sz(0)/2,sz(1)/2,*)
default,yoffs,fix( (10./4.) * 2/sm)
topl2=imgs(sz(0)/2,sz(1)/2+yoffs,*)


; pk=92
; dc=fltarr(sz(2))
; ac=dc
; ph=ac
; for i=0,sz(2)-1 do begin
; ss=fft(imgs(400,*,i))
; dc(i)=ss(0)
; ac(i)=abs(ss(pk))
; ph(i)=atan2(ss(pk))
; endfor
; tell=abs(ph(1:sz(2)-1)-ph(0:sz(2)-2))
tell=topl2*0.



plot,topls,xr=xr,psym=10
oplot,topls,psym=4

plot,topl,xr=xr,psym=10,/noer
oplot,topl,psym=4

voff=(!y.crange(1)-!y.crange(0))/4.
oplot,topl2-voff,psym=10,col=3
oplot,topl2-voff,psym=4,col=3

plot,tell,xr=xr,psym=-4,/noer,col=4



;if keyword_set(centpix) then oplot,topl2,psym=4,col=3
;plot,totaldim(imgs,[1,1,0]),xr=xr,/noer




if noflc eq 0 then begin
    plot,(flc.flc1.t-flc.flc1.t(0))/ft,flc.flc1.v,col=2,/noer,xr=!x.crange
    oplot,(flc.flc0.t-flc.flc0.t(0))/ft,flc.flc0.v,col=4
endif
if size(nbi1.v,/type) ne 7 then if n_elements(nbi1.t) gt 1 then plot,(nbi1.t-tstart)/ft,nbi1.v,col=5,/noer,xr=!x.crange
if size(nbi2.v,/type) ne 7 then if n_elements(nbi2.t) gt 1 then plot,(nbi2.t-tstart)/ft,nbi2.v,col=6,/noer,xr=!x.crange
plot,(ip.t-tstart)/ft,-ip.v,col=7,/noer,xr=!x.crange


cursor,dx,dy,/down
i=round(dx)
print,'clicked on',i
imgplot,imgs(*,*,i),/cb,zr=zr
cursor,dx,dy,/down
if !mouse.button ne 4 then goto,bb

aa:
;write_tiff,'~/mse_data/7241_180.tif',long(imgs(*,*,180)),/short
;write_tiff,'~/mse_data/7241_100.tif',long(imgs(*,*,100)),/short

stop
end

