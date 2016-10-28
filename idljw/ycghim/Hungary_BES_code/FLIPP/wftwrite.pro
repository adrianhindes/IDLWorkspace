pro wftwrite,fname,data,tstart=tstart,sampletime=sampletime,title=title,user_notes=user_notes,$
						vertical_norm=vertical_norm,vertical_zero=vertical_zero,over=over

;***************** wftwrite.pro********************** S. Zoletnik *** 2.2.1998 ******************
; Program to write wft format files 
; See ftwread.pro
; /over: overwrite file if exists

if (not defined(data) or not defined(tstart) or not keyword_set(sampletime)) then begin
  print,'WFTWRITE.PRO Bad parameters'
  stop
endif

default,vertical_norm,1e-4
default,vertical_zero,-22096
maxsig=(32767l-vertical_zero)*vertical_norm
minsig=(-32767l-vertical_zero)*vertical_norm
data=data < maxsig
data=data > minsig       

case (!version.os) of
  'vms'    : sswap=0
  'ultrix' : sswap=0
  'OSF'    : sswap=0
  'sunos'  : sswap=1
  'AIX'    : sswap=1
  'hp-ux'  : sswap=1
  'linux'  : sswap=0
  'IRIX'   : sswap=1
  else  : stop,'Unknown !version.os:',!version.os
endcase

if (not keyword_set(over)) then begin
  openr,lun,fname,/get_lun,error=error
  if (error eq 0) then begin
    close,lun
    free_lun,lun
    print,'File '+fname+' exists!' 
    if (not ask('Overwrite?')) then return
  endif  
endif

openw,lun,fname,/get_lun

hfile = assoc(lun,bytarr(20))

header_size=1538
header=bytarr(1538)
header(0:19)=[51,0,50,0,49,0,48,0,49,53,51,56,0,32,32,32,32,32,32,32]
if (keyword_set(title)) then begin
  if (strlen(title) gt 80) then title=strmid(title,0,80)
  header(44:44+strlen(title)-1)=byte(title)
endif

w=str_sep(strcompress(systime()),' ')
year=strmid(w(4),2,2)
header(125:126)=byte(year)
month=strlowcase(w(1))
case month of
  'jan': month=1
  'feb': month=2
  'mar': month=3
  'apr': month=4
  'may': month=5
  'jun': month=6
  'jul': month=7
  'aug': month=8
  'sep': month=9
  'oct': month=10
  'nov': month=11
  'dec': month=12
endcase
if (month ge 10) then begin
  header(128)=byte('1')
  header(129)=byte(month mod 10) + byte('0')
endif else begin
  header(128)=byte(month)+byte('0')
endelse                                
day=fix(w(2))
if (day ge 10) then begin
  header(131)=byte(fix(day/10))+byte('0')
  header(132)=byte(day mod 10) + byte('0')
endif else begin
  header(131)=byte(day)+byte('0')
endelse
ww=str_sep(w(3),':')
hour=ww(0)
minute=ww(1)
second=ww(2)
tim=hour*3600000l+minute*60000l+second*1000l
tims=string(tim,format='(I12)')
header(134:145)=byte(tims)
            
data_count=n_elements(data)
ws=i2str(data_count)
header(146:146+strlen(ws)-1)=byte(ws)
if (strlen(ws) lt 12) then header(146+strlen(ws))=0
if (strlen(ws) lt 13) then header(146+strlen(ws)+1:157)=32
ws=i2str(vertical_zero)
header(158:158+strlen(ws)-1)=byte(ws)
if (strlen(ws) lt 12) then header(158+strlen(ws))=0
if (strlen(ws) lt 13) then header(158+strlen(ws)+1:169)=32
ws=string(vertical_norm,format='(E24.15)')
header(170:193)=byte(ws)
bytes_per_data_point=fix(string(header(658:660)))
bytes_per_data_point=2
header(658)=byte('2')
header(660)=32
ws=string(sampletime,format='(E24.15)')
header(1036:1059)=byte(ws)
ws=string(tstart,format='(E24.15)')
header(1060:1083)=byte(ws)
if (keyword_set(user_notes)) then begin
  if (strlen(user_notes) gt 128) then user_notes=strmid(user_notes,0,128)  
  header(312:312+strlen(user_notes)-1)=byte(user_notes)
endif

hfile(0)=header

data1=fix(data/vertical_norm+vertical_zero)
if(sswap) then byteorder,data1
ass_dat=assoc(lun,intarr(data_count),header_size)
ass_dat(0)=data1

close,lun
free_lun,lun
end
