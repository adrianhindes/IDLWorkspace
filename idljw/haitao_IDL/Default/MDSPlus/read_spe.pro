pro getd,lun,pt,tp,var,rep=rep
point_lun,lun,pt
if tp eq 'double' then var=0.d0
if tp eq 'float' then var=0.0
if tp eq 'char' then var=0B
if tp eq 'byte' then var=0B
if tp eq 'word' then var=0
if keyword_set(rep) then var=replicate(var,rep)

readu,lun,var
end

pro read_spe, fil, lam, t,d,texp=texp,str=str,fac=fac
;default,texp,0.

;fil='~/sdata/mast5.SPE'
;res=read_tiff(fil,r,g,b,image_index=1,/verbose,geotif=gtf)
openr,lun,fil,/get_lun
getd,lun,10,'float',texp0
texp=texp0*1000
;print,'exposure time=',texp,'ms'
point_lun,lun,42 & xdim=0 & readu, lun,xdim
point_lun,lun,656 & ydim=0 & readu, lun,ydim
point_lun,lun,108 & dtype=0B & readu, lun,dtype
point_lun,lun,1446 & nfr=0L & readu, lun,nfr
;0,1,2,3:float,long,short,unsignedshoft

getd,lun,3000,'double',offset
getd,lun,3008,'double',factor
getd,lun,3100,'char',polynom_unit
getd,lun,3101,'char',polynom_order
getd,lun,3102,'char',calib_count
getd,lun,3103,'double',pixel_position,rep=10
getd,lun,3183,'double',calib_value,rep=10
getd,lun,3263,'double',polynom_coeff,rep=6
getd,lun,3321,'char',clab,rep=81 & clab=string(clab)
getd,lun,672,'float',readouttime
t=findgen(nfr) * (readouttime+texp)
;print,'readout time=',readouttime,'ms'



getd,lun,198,'word',gain  ;& print,'gain',gain
getd,lun,36,'float',temp  ;& print,'temp',p1
;getd,lun,46,'float',delaytime ; & print,'delaytime',p1
getd,lun,4096,'word',avgain  ;& print,'pigain',p1
;getd,lun,4092,'word',p1  & print,'angain',p1

getd,lun,622,'word',specmirrorpos1
getd,lun,624,'word',specmirrorpos2

specslitpos=fltarr(4)
for j=0,3 do begin getd,lun,626+4*j,'float',tmp & specslitpos(j)=tmp&end

getd,lun,650,'float',specgrooves

getd,lun,676,'word',trig_tim_opt
getd,lun,724,'word',kin_trig_mode
getd,lun,1428,'float',clkspd_us
getd,lun,1480,'word',readoutmode
getd,lun,1482,'word',kwindowsize
getd,lun,1484,'word',kclkspd

getd,lun,4,'word',amphicaplownoise
getd,lun,8,'word',timingmode
getd,lun,10,'float',alt_exp
getd,lun,1992,'file_header_ver',file_header_ver


;7.8e-3 - 4096 * 0.9e-6 = 4.1136ms

readouttime_s=readouttime * 1e-3
vertshift=(readouttime_s - 4.1136e-3)/4096
vertshiftus=vertshift*1e6


;stop

str={readouttime:readouttime,$
     gain:gain,$
     avgain:avgain,$
     temp:temp,$
     readoutmode:readoutmode,$
     texp:texp0,$
     kindowsize:kwindowsize,$
     kclkspd:kclkspd,$
     kin_trig_mode:kin_trig_mode,$
     trig_tim_opt:trig_tim_opt,$
     clkspd_us:clkspd_us,$
     amphicaplownoise:amphicaplownoise,$
     timingmode:timingmode,$
     alt_exp:alt_exp,$
     file_header_ver:file_header_ver,$
     specslitpos1:specslitpos(0),$
     specslitpos2:specslitpos(1),$
     vertshiftus:vertshiftus}
default,fac,1
ix=findgen(xdim)*fac
print,'x6'
lam=fltarr(xdim)
for i=0,polynom_order do lam=lam + polynom_coeff(i) * ix^i

;print,xdim,ydim,dtype,nfr

if dtype eq 3 then d=uintarr(xdim,ydim,nfr)
if dtype eq 1 then d=fltarr(xdim,ydim,nfr)

point_lun,lun,4100
readu,lun,d

close,lun
free_lun,lun
stop
end

;read_spe,'~/prjf/xsadata/md_27890.SPE'

;end
