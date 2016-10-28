fil='Cal_09102012_1'
filblack='Cal_09102012_1_black'
filout='~/mse_data/Cal_09102012_1_sumd.tif'
nn=100

fil='edge_cal'
filblack='edge_cal_black'
filout='~/mse_data/edge_cal_sumd.tif'
nn=100

;fil='run148'
;filblack='run149'
;filout='~/kstartestimages/run148_sumd.tif'
;nn=1

fil='cal_532'
filblack='cal_532_black'
filout='~/mse_data/cal_532_sumd.tif'
nn=24

for i=0,nn-1 do begin
tmp=1.*getimg(0,pre=fil,/nonum,index=i,/getinfo,info=info)
if i eq 0 then a=tmp else a=a+tmp
endfor
for i=0,nn-1 do begin
tmp=1.*getimg(0,pre=filblack,/nonum,index=i)
if i eq 0 then a0=tmp else a0=a0+tmp
endfor
a/=100.
a0/=100.

f=(a-a0)>0
f=f/max(f) * 65535
write_tiff,filout,long(f),/verbose,/short

a=read_tiff(filout)
imgplot,a
end
