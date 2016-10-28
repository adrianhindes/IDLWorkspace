function istag, strct, tag,loc=loc
on_error,2
tags=tag_names(strct)

ntags=n_elements(tags)
for i=0,ntags-1 do if tags(i) eq strupcase(tag) then begin
    loc=i
    return, 1
    endif


return, 0

end
function create_structarr, nam, val
n=n_elements(nam)
for i=0,n-1 do begin
   nam2=STRJOIN(STRSPLIT(nam(i),':', /EXTRACT))
   if i eq 0 then str=create_struct(nam2,val(i)) else str=create_struct(str,nam2,val(i))
endfor

return,str
end



FUNCTION xml_to_struct2::Init

common cbbxx, rlevel, rvalue
max_lev=100
rlevel=0
rvalue=ptrarr(max_lev)
   RETURN, self->IDLffxmlsax::Init()
END



PRO xml_to_struct2::characters, data
;   self.charBuffer = self.charBuffer + data
common cbbxx, rlevel, rvalue
if ptr_valid(rvalue(rlevel)) then begin
   dum=create_struct(*rvalue(rlevel),'data',data)
   ptr_free,rvalue(rlevel)
   rvalue(rlevel)=ptr_new(dum)
endif else rvalue(rlevel)=ptr_new(create_struct('data',data))

;print,data
END

PRO xml_to_struct2::startElement, URI, local, strName, attrName, attrValue

common cbbxx, rlevel, rvalue
rlevel++
;print,'start ',strname,rlevel
if n_elements(attrname) ne 0 then begin
   n=n_elements(attrname)
;   for i=0,n-1 do print,'attr ',attrname(i),'=',attrvalue(i)
   dum=create_structarr(attrname,attrvalue)
;help,dum
   rvalue(rlevel)=ptr_new(dum)
;   print, attrname
;   print,attrvalue
endif

END


PRO xml_to_struct2::EndElement, URI, Local, strName
common cbbxx, rlevel, rvalue

common cbyy, dupindex
;if ptr_valid(rvalue(rlevel)) eq 0 then rvalue(rlevel)=ptr_new(
;print,'end ',strname,rlevel
rlevel--
if  ptr_valid(rvalue(rlevel+1)) eq 1 then begin
   if ptr_valid(rvalue(rlevel)) then begin
      idx=where(strupcase(strname) eq tag_names(*rvalue(rlevel)),count)
      if idx(0) eq -1 then begin
         strnametmp = strname 
         dupindex = 0
      endif else begin
         dupindex=dupindex+1
         strnametmp=strname + string(dupindex,format='(I0)')
      endelse

      dum=create_struct(*rvalue(rlevel),strnametmp,*rvalue(rlevel+1)) 
   endif else $
      dum=create_struct(strname,*rvalue(rlevel+1)) 

   ptr_free,rvalue(rlevel+1)
   rvalue(rlevel+1)=ptr_new()
   if ptr_valid(rvalue(rlevel)) then ptr_free,rvalue(rlevel)
   rvalue(rlevel)=ptr_new(dum)
endif




END


FUNCTION xml_to_struct2::GetArray

;print,'called getarray'

common cbbxx, rlevel, rvalue
;stop
;      RETURN, -1 
return, *rvalue(0)
END


PRO xml_to_struct2__define
   void = {xml_to_struct2, $u
            INHERITS IDLffXMLSAX ,pstr:ptr_new() }

END


;help,dum.speformat.datahistories.datahistory.origin.experiment.devices.cameras.camera.intensifier.gain

pro getd,lun,pt,tp,var,rep=rep
point_lun,lun,pt
if tp eq 'double' then var=0.d0
if tp eq 'float' then var=0.0
if tp eq 'char' then var=0B
if tp eq 'byte' then var=0B
if tp eq 'word' then var=0
if tp eq 'u64' then var=(ULON64ARR(1))(0)
if keyword_set(rep) then var=replicate(var,rep)

readu,lun,var
end

pro read_spe, fil, lam, t,d,texp=texp,str=str,fac=fac,$
              xdim=xdim,xml=xml,viewxml=viewxml
;default,texp,0.

;fil='~/sdata/mast5.SPE'
;res=read_tiff(fil,r,g,b,image_index=1,/verbose,geotif=gtf)
openr,lun,fil,/get_lun
getd,lun,10,'float',texp0
texp=texp0*1000
;print,'exposure time=',texp,'ms'
point_lun,lun,42 & if n_elements(xdim) eq 0 then begin
    xdim=0 & readu, lun,xdim
 endif

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


getd,lun,122,'float',gatedelay
print,'gate delay is ',gatedelay


;7.8e-3 - 4096 * 0.9e-6 = 4.1136ms

readouttime_s=readouttime * 1e-3
vertshift=(readouttime_s - 4.1136e-3)/4096
vertshiftus=vertshift*1e6


;stop

default,fac,1
ix=findgen(xdim)*fac
;print,'x6'
lam=fltarr(xdim)
for i=0,polynom_order do lam=lam + polynom_coeff(i) * ix^i

;print,xdim,ydim,dtype,nfr
if file_header_ver lt 3 then begin
   if dtype eq 3 then d=uintarr(xdim,ydim,nfr)
   if dtype eq 0 then d=fltarr(xdim,ydim,nfr)
   if dtype eq 1 then d=lonarr(xdim,ydim,nfr)
   xmloffset=0 & xmlstr=''
endif else begin
   getd,lun,678,'u64',xmloffset
   sz=(fstat(lun)).size
   point_lun,lun,xmloffset
   nn=sz-xmloffset
   xmlstr=bytarr(nn)
   readu,lun,xmlstr
   xmlstr=string(xmlstr)
   openw,lun2,'~/footer.xml',/get_lun
   printf,lun2,xmlstr
   close,lun2 & free_lun,lun2
   if keyword_set(viewxml) then spawn,'firefox ~/footer.xml&'
   
   xmlObj = OBJ_NEW('xml_to_struct2')
   xmlObj->ParseFile, xmlstr,/xml_string
   xml = xmlObj->GetArray()
   OBJ_DESTROY, xmlObj


;; sstart='<Wavelength>'; xml:space="preserve">'
;; send  ='</Wavelength>'

;; pos0=strpos(xmlstr,sstart)
;; if pos0 eq -1 then begin
;;    sstart='<Wavelength xml:space="preserve">'
;;    pos0=strpos(xmlstr,sstart)
;; endif
;; pos1=pos0+strlen(sstart)
;; pos2=strpos(strmid(xmlstr,pos1,999999),send)+pos1

   xdim=fix(xml.speformat.dataformat.datablock.datablock.width) ;fix(widstr)
   lam=findgen(xdim)

;0 = 32f (4 bytes);
;1 = 32s (4 bytes;);
;2 = 16s (2 bytes);
;3 = 16u (2 bytes)
;8 = 32u (4 bytes)

blen=4L
if dtype eq 2 or dtype eq 3 then blen=2L

   stride=long(xml.speformat.dataformat.datablock.stride)
   if stride eq long(xdim)*long(ydim)*blen then begin
      if dtype eq 0 then d=fltarr(xdim,ydim,nfr)
      if dtype eq 1 then d=lonarr(xdim,ydim,nfr)
      if dtype eq 2 then d=intarr(xdim,ydim,nfr)
      if dtype eq 3 then d=uintarr(xdim,ydim,nfr)
      if dtype eq 8 then d=ulonarr(xdim,ydim,nfr)
   endif else begin
      print,' there is a meta data per frame'
      if dtype eq 0 then d=fltarr(stride/blen,nfr)
      if dtype eq 1 then d=lonarr(stride/blen,nfr)
      if dtype eq 2 then d=intarr(stride/blen,nfr)
      if dtype eq 3 then d=uintarr(stride/blen,nfr)
      if dtype eq 8 then d=ulonarr(stride/blen,nfr)
   endelse
;64u XML Offset 678 Starting location of the XML footer
   

   if istag(xml.speformat.calibrations,'wavelengthmapping')  then begin
   lamtxt=xml.speformat.calibrations.wavelengthmapping.wavelength.data
   spl=strsplit(lamtxt,',',/extr)
   lam=float(spl)
endif

;; pos0a=strpos(xmlstr,'DataBlock')
;; pos0b=pos0a+strpos(strmid(xmlstr,pos0a,9999999),'width="')+strlen('width="')
;; pos0c=pos0b+strpos(strmid(xmlstr,pos0b,9999999),'"')
;; widstr=strmid(xmlstr,pos0b,pos0c-pos0b)


   ;; if dtype eq 0 then d=fltarr(xdim,ydim,nfr)
   ;; if dtype eq 1 then d=lonarr(xdim,ydim,nfr)
   ;; if dtype eq 2 then d=intarr(xdim,ydim,nfr)
   ;; if dtype eq 3 then d=uintarr(xdim,ydim,nfr)
   ;; if dtype eq 8 then d=ulonarr(xdim,ydim,nfr)


   avgain = float(xml.speformat.datahistories.datahistory.origin.experiment.devices.cameras.camera.intensifier.gain.data)
   gain = xml.speformat.datahistories.datahistory.origin.experiment.devices.cameras.camera.adc.analoggain.data

   texp0 = float(xml.speformat.datahistories.datahistory.origin.experiment.devices.cameras.camera.intensifier.gating.repetitivegate.pulse.width)/1e9 

   gatedelay = float(xml.speformat.datahistories.datahistory.origin.experiment.devices.cameras.camera.intensifier.gating.repetitivegate.pulse.delay)/1e9 

endelse


point_lun,lun,4100
readu,lun,d

close,lun
free_lun,lun

if file_header_ver ge 3 then  $
   if stride ne long(xdim)*long(ydim)*blen then begin
      d=reform(d(0:long(xdim)*long(ydim)-1,*),xdim,ydim,nfr)
      print,'reformed because of stride'
   endif




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
     vertshiftus:vertshiftus,$
     gatedelay:gatedelay,$
    xmloffset:xmloffset,$
    xmlstr:xmlstr}

if      file_header_ver ge 3 then begin
   str=create_struct(str,$
                     'flipvertically',$
xml.speformat.datahistories.datahistory.origin.experiment.devices.cameras.camera.experiment.onlinecorrections.orientationcorrection.flipvertically.data,$
                     'fliphorizontally',$
xml.speformat.datahistories.datahistory.origin.experiment.devices.cameras.camera.experiment.onlinecorrections.orientationcorrection.fliphorizontally.data,$
                    'triggersource',$
xml.speformat.datahistories.datahistory.origin.experiment.devices.cameras.camera.hardwareio.trigger.source.data)
   if istag(xml.speformat.datahistories.datahistory.origin.experiment.devices,'spectrometers') then $
      str=create_struct(str,$
                        'grating',$
                        xml.speformat.datahistories.datahistory.origin.experiment.devices.spectrometers.spectrometer.grating.selected.data,$
                        'cwl',xml.speformat.datahistories.datahistory.origin.experiment.devices.spectrometers.spectrometer.grating.centerwavelength.data)
                     

endif


print,'hello';122 float is delay
end



;print,'a'
;read_spe,'/home/cam112/greg/7_24_2013/hydrogenLampHBeta/Heroic_100Frames_3p5ms/2013 July 26 12_54_30-raw.spe',l,t,d
;read_spe,'~/prjf/xsadata/md_27890.SPE'

;end

