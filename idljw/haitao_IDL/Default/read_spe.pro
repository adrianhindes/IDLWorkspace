pro convnum,txt
btxt=byte(txt)
nb=n_elements(btxt)
isnum=1
for i=0,nb-1 do begin
    if not ( (btxt(i) ge byte('0') and btxt(i) le byte('9')) or btxt(i) eq byte('.') or btxt(i) eq byte(' ') or btxt(i) eq byte('-') ) then isnum=0
endfor
;or btxt(i) eq byte('(') or btxt(i) eq byte(')') or btxt(i) eq byte(',')
if isnum eq 0 then return
spl=strsplit(txt,' ',/extr)
nspl=n_elements(spl)
num=float(spl)
if nspl eq 1 then num=num(0)
;stop
txt=num
end




pro modtn, str, tag
tn=tag_names(str)
nt=n_elements(tn)
found=0
for i=0,nt-1 do if strupcase(tn(i)) eq strupcase(tag) then found=1
if found eq 0 then return
num=1
for i=0,nt-1 do begin
    spl=strsplit(tn(i),'_',/extr)
    thisnum=0
    if n_elements(spl) eq 2 and strupcase(spl(0)) eq strupcase(tag) then thisnum=fix(spl(1))
    if strupcase(spl(0)) eq strupcase(tag) then num=max([num,thisnum])
endfor
tag2=tag+'_'+string(num+1,format='(I0)')
tag=tag2
end


function create_struct2,str,tag,val
if n_elements(str) eq 0 then str2=create_struct(tag,val) else begin

    tagp=tag
    modtn, str, tagp
    if strpos(tagp,':') ne -1 then begin
       spl=strsplit(tagp,':',/extract)
       tagp=strjoin(spl)
    endif
    tn=tag_names(str)
    dum=where(tn eq strupcase(tagp))
    if dum(0) eq -1 then str2=create_struct(str,tagp,val)
endelse

return,str2
end


pro dowalk, walk,str,nonav=nonav
;on_error,3
common cb, lev
print,'lev=',lev
i=0
res=walk->GetCurrentNode()
a:
     print,'class:', obj_class(res)
 if obj_class(res) eq '' then goto,en
 if obj_class(res) eq 'IDLFFXMLDOMTEXT' then  begin
     txt=res->GetData()
     if n_elements(txt) eq 0 then txt=''
     txt=strjoin(strsplit(txt,string(byte(10)),/extr),' ')
     txt=strtrim(txt,2)
     if txt ne '' then begin
         convnum,txt
;         print, 'val',txt 
         str=create_struct2(str, 'val',txt)
;         stop
     endif
 endif
 if obj_class(res) eq 'IDLFFXMLDOMELEMENT' then begin
     tagname=res->GetTagName()
     print,'element tagname: ',tagname
;    if tagname eq 'DataBlock' then stop

     if not keyword_set(nonav) then res=walk->FirstChild()
      if OBJ_VALID(res) eq 1 then begin
        print,obj_class(res)  
;       stop
        lev=lev+1
        if n_elements(strsub) ne 0 then dum=temporary(strsub)
        if not keyword_set(nonav) then begin
            dowalk,walk,strsub
            lev=lev-1
            res=walk->ParentNode()
            print,lev,'after'  
        endif
      endif else res=walk->GetCurrentNode()
;     stop
     attr=res->GetAttributes()
     nattr=attr->GetLength()
     for j=0,nattr-1 do begin
         iattr=attr->Item(j)
         nmattr=iattr->GetName()
         valattr=iattr->GetValue()
         convnum,valattr
         print,'attr#',j,'name:',nmattr,'val:',valattr
         strsub=create_struct2(strsub,nmattr,valattr)
    endfor
;     if nattr ne 0 then stop


     str=create_struct2(str,tagname,strsub)
 endif
res=walk->NextSibling()
goto,a
en:
end

pro xmlt, string, str,nonav=nonav
common cb, lev
lev=0
oDocument = obj_new('IDLffXMLDOMDocument')
oDocument->Load,string=string;filename=fn;'/home/cmichael/ems/21541m4c/idam.xml';,/EXCLUDE_IGNORABLE_WHITESPACE,validation_mode=1

walk=oDocument->CreateTreeWalker( oDocument)
res=walk->FirstChild()
if n_elements(str) ne 0 then dum=temporary(str)
dowalk,walk,str,nonav=nonav
end

; xmlt,'res/21896a/ffbasis.xml',s   ,/nonav
; xmlt,'res/21896a/idam.xml',s   
;end


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
              xdim=xdim
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
;0 = 32f (4 bytes);
;1 = 32s (4 bytes;);
;2 = 16s (2 bytes);
;3 = 16u (2 bytes)
;8 = 32u (4 bytes)
   if dtype eq 0 then d=fltarr(xdim,ydim,nfr)
   if dtype eq 1 then d=lonarr(xdim,ydim,nfr)
   if dtype eq 2 then d=intarr(xdim,ydim,nfr)
   if dtype eq 3 then d=uintarr(xdim,ydim,nfr)
   if dtype eq 8 then d=ulonarr(xdim,ydim,nfr)
;64u XML Offset 678 Starting location of the XML footer
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


;   oDocument = obj_new('IDLffXMLDOMDocument')
;   oDocument->Load,string=xmlstr ;filename=fn;'/home/cmichael/ems/21541m4c/idam.xml';,/EXCLUDE_IGNORABLE_WHITESPAC;E,validation_mode=1;

;walk=oDocument->CreateTreeWalker( oDocument)
;res=walk->FirstChild()

;   print,xmlstr
;   xmlt, xmlstr,xml

;sstart='<Wavelength xml:space="preserve">'
sstart='<Wavelength>'; xml:space="preserve">'
send  ='</Wavelength>'

pos0=strpos(xmlstr,sstart)
if pos0 eq -1 then begin
   sstart='<Wavelength xml:space="preserve">'
   pos0=strpos(xmlstr,sstart)
endif
pos1=pos0+strlen(sstart)
pos2=strpos(strmid(xmlstr,pos1,999999),send)+pos1
lamtxt=strmid(xmlstr,pos1,pos2-pos1)
spl=strsplit(lamtxt,',',/extr)
lam=float(spl)
pos0a=strpos(xmlstr,'DataBlock')
pos0b=pos0a+strpos(strmid(xmlstr,pos0a,9999999),'width="')+strlen('width="')
pos0c=pos0b+strpos(strmid(xmlstr,pos0b,9999999),'"')
widstr=strmid(xmlstr,pos0b,pos0c-pos0b)
xdim=fix(widstr)

   if dtype eq 0 then d=fltarr(xdim,ydim,nfr)
   if dtype eq 1 then d=lonarr(xdim,ydim,nfr)
   if dtype eq 2 then d=intarr(xdim,ydim,nfr)
   if dtype eq 3 then d=uintarr(xdim,ydim,nfr)
   if dtype eq 8 then d=ulonarr(xdim,ydim,nfr)

if xdim ne n_elements(lam) then begin
   pos0a=strpos(xmlstr,'SensorMapping')
   pos0b=pos0a+strpos(strmid(xmlstr,pos0a,9999999),'x="')+strlen('x="')
   pos0c=pos0b+strpos(strmid(xmlstr,pos0b,9999999),'"')
   xstartstr=strmid(xmlstr,pos0b,pos0c-pos0b)
   xstart=fix(xstartstr)
   lam=lam(xstart:*)

endif


endelse


point_lun,lun,4100
readu,lun,d

close,lun
free_lun,lun


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
print,'hello';122 float is delay
end



;print,'a'
;read_spe,'/home/cam112/greg/7_24_2013/hydrogenLampHBeta/Heroic_100Frames_3p5ms/2013 July 26 12_54_30-raw.spe',l,t,d
;read_spe,'~/prjf/xsadata/md_27890.SPE'

;end

