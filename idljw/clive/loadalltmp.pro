xr=[0,6]
goto,bb
;pro
;loadall,sh,get=get,xr=xr,mdsplus=mdsplus,pre=pre,zr=zr,centpix=centpix,yoffs=yoffs,sm=sm

sh=7897
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
if getflc eq 1 then ft=info.frame_time


;tstart=0.
sz=size(imgs,/dim)

topls=totaldim(imgs,[1,1,0])/sz(0)/sz(1) ;average


topl=imgs(sz(0)/2,sz(1)/2,*)
default,yoffs,fix( (10./4.) * 2/sm)
topl2=imgs(sz(0)/2,sz(1)/2+yoffs,*)


pk=92
dc=fltarr(sz(2))
ac=dc
ph=ac
for i=0,sz(2)-1 do begin
ss=fft(imgs(400,*,i))
dc(i)=ss(0)
ac(i)=abs(ss(pk))
ph(i)=atan2(ss(pk))
endfor
tell=abs(ph(1:sz(2)-1)-ph(0:sz(2)-2))
tell=[0,tell]
iidx=findgen(sz(2))

idx=where( ((dc gt 800) or (iidx ge 140 and iidx le 160)) and (tell lt 0.5) )

tbase=iidx*ft+tstart


plot,tbase,dc,xr=xr
oplot,tbase(idx),dc(idx),psym=4
plot,tbase,tell,xr=xr,col=2,/noer
oplot,tbase(idx),tell(idx),col=2,psym=4


for i=0,sz(2)-1 do begin
    dum=where(idx eq i)
    if dum(0) ne -1 then iidx(i:*)=iidx(i:*)+1
endfor

tbase=iidx*ft+tstart

a=''&read,'',a
;retall


plot,tbase,topls,xr=xr,psym=10
oplot,tbase,topls,psym=4

plot,tbase,topl,xr=xr,psym=10,/noer
oplot,tbase,topl,psym=4

voff=(!y.crange(1)-!y.crange(0))/4.
oplot,tbase,topl2-voff,psym=10,col=3
oplot,tbase,topl2-voff,psym=4,col=3

plot,tbase,tell,xr=xr,psym=-4,/noer,col=4



;if keyword_set(centpix) then oplot,topl2,psym=4,col=3
;plot,totaldim(imgs,[1,1,0]),xr=xr,/noer




if size(nbi1.v,/type) ne 7 then plot,nbi1.t,nbi1.v,col=5,/noer,xr=!x.crange
if size(nbi2.v,/type) ne 7 then plot,nbi2.t,nbi2.v,col=6,/noer,xr=!x.crange
plot,ip.t,-ip.v,col=7,/noer,xr=!x.crange


;cursor,dx,dy,/down
;i=round(dx)
;print,'clicked on',i
;imgplot,imgs(*,*,i),/cb,zr=zr
;cursor,dx,dy,/down
;if !mouse.button ne 4 then goto,bb

aa:
;write_tiff,'~/mse_data/7241_180.tif',long(imgs(*,*,180)),/short
;write_tiff,'~/mse_data/7241_100.tif',long(imgs(*,*,100)),/short

;;save,iidx,file='~/idl/lf_7897.sav',/verb


stop
end

