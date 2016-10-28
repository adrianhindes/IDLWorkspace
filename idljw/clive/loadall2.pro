pro loadall2,sh,get=get
; if keyword_set(get) then begin
;     dum=findfile('*'+string(sh,format='(I0)')+'*',count=cnt)
;     if cnt eq 0 then begin
;         cd,current=curr
;         cd,'~/mse_data'
;         spawn,'rmget1 '+string(sh,format='(I0)')
;         cd,curr
;     endif else print,'file exists do nothing'
; endif
if sh ge 7930 then sh1=sh-3 else sh1=sh-1
if sh ge 7947 then sh1=sh
;r=7268;4;61;42;53;41
;r=7241
sm=4;2;4
;sh=7497;89;31
mdsplus=0
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



img=getimg(sh,pre='',index=0,sm=sm,info=info,/getinfo,mdsplus=mdsplus,flc=flc,/getflc,seg=seg)
nimg=info.num_images

sz=size(img,/dim)
imgs=fltarr(sz(0),sz(1),nimg)
for i=0,nimg-1 do begin
img=getimg(r,pre='',index=i,sm=sm,mdsplus=mdsplus,/rememb,seg=seg)
print,i,nimg
imgs(*,*,i)=img

endfor
bb:

;if seg eq 0 then ft=0.03333 else
; ft=info.frame_time *2
ft = 1/40.;1/30.
;tstart=-0.1
;tstart=0.5
tstart=-0.12
;tstart=0.
plot,totaldim(imgs,[1,1,0])
plot,(flc.flc1.t-flc.flc1.t(0))/ft,flc.flc1.v,col=2,/noer,xr=!x.crange
oplot,(flc.flc0.t-flc.flc0.t(0))/ft,flc.flc0.v,col=4
plot,(nbi1.t-tstart)/ft,nbi1.v,col=5,/noer,xr=!x.crange
plot,(nbi2.t-tstart)/ft,nbi2.v,col=6,/noer,xr=!x.crange
plot,(ip.t-tstart)/ft,-ip.v,col=7,/noer,xr=!x.crange


cursor,dx,dy,/down
i=round(dx)
imgplot,imgs(*,*,i),/cb,zr=[0,3e3]
cursor,dx,dy,/down
if !mouse.button ne 4 then goto,bb

aa:
;write_tiff,'~/mse_data/7241_180.tif',long(imgs(*,*,180)),/short
;write_tiff,'~/mse_data/7241_100.tif',long(imgs(*,*,100)),/short
end

