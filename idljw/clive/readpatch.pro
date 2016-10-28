
pro readpatch,sh,str,db=db,getinfo=getinfo,getflc=getflc,nfr=nfr
;path='/projects/diagnostics/MAST/FIDA/fidaidl/settings/'
common cbba, actover,pasover
 
;if !version.os ne 'win32' then begin
;   spawn,'hostname',hostname
;   if hostname eq 'prl75' then nfr=1000
;endif

default,db,'k'


path=getenv('HOME')+'/idl/clive/settings/'
readtextc,path+'log_shot.csv',data,nskip=1

isstr=size(sh,/type) eq 7
if isstr then begin

endif

db1=data[1,*]
idx=where(db1 eq db)
data=data[*,idx] ;; select only certain databse entries


shl = longtrap(data[0,*],err=err)

;stop
if isstr eq 0 then begin
    wg=where(err eq 0) & shl=shl(wg) & data=data(*,wg)
    idx = where( (shl le sh),count)
    if count eq 0 then begin
        print,'error'
        stop
        return
    endif
endif else begin
    wg=where(err eq 1) & shl=data(0,wg) & data=data(*,wg)
    nn=n_elements(shl)
    tvar=intarr(nn)
    for i=0,nn-1 do tvar(i)=strpos(sh,shl(i))
    idx = where(tvar ne -1)
    if n_elements(idx) gt 1 then begin
        print,'error more than one match'
        stop
    endif
    if idx(0) eq -1 then begin
        print,'error2'
        stop
    endif
endelse



; the relevant record is the one with the highest shotnumber that is lower than or equal to the desired shotnumber.
idx = idx(n_elements(idx)-1)    ; row number

i=2
camera=data(i++,idx)
camangle=float(data(i++,idx))
flencam=float(data(i++,idx))
rotate=fix(data(i++,idx))
spe=fix(data(i++,idx))
tif=fix(data(i++,idx))


tifrec=fix(data(i++,idx))
tifpre=data(i++,idx)
tdms=fix(data(i++,idx))
tdmspre=data(i++,idx)
tdmspost=data(i++,idx)
path=data(i++,idx)

if !version.os ne 'Win32' then spawn,'hostname',host else host='blah'
if host eq 'scucomp2.anu.edu.au' and strpos(path,'~/rsphy') ne -1 then path='~'+strmid(path,7,1000)
if host eq 'ikstar.nfri.re.kr' and path eq '/data/kstar/MSE_2014_DATA' then path='/home/users/art112/jScope/configurations'

if !version.os eq 'Win32' then begin
   if getenv('COMPUTERNAME') eq '2D-MSE2' then begin
      if db eq 'k' then begin
         bpath=byte(path)
         bpath(0)=byte('D')
         path=string(bpath)
      ENDIF
   endif
endif

tree=data(i++,idx)
mdsplusnode=data(i++,idx)
mdsplusseg=fix(data(i++,idx))

flc0t0=fix(data(i++,idx))
flc0per=fix(data(i++,idx))
flc0mark=fix(data(i++,idx))
flc1t0=fix(data(i++,idx))
flc1per=fix(data(i++,idx))
flc1mark=fix(data(i++,idx))
cellno=data(i++,idx)
t0=float(data(i++,idx))
t0proper=t0
dt=float(data(i++,idx))
tstampavail=fix(data(i++,idx))
roil=fix(data(i++,idx))
roir=fix(data(i++,idx))
roib=fix(data(i++,idx))
roit=fix(data(i++,idx))
binx=fix(data(i++,idx))
biny=fix(data(i++,idx))
xbin=fix(data(i++,idx))
polariser=float(data(i++,idx))
calno=data(i++,idx)
calfile=data(i++,idx)
calfilebg=data(i++,idx)
lambdanm=float(data(i++,idx))

mapping=data(i++,idx)
comment=data(i++,idx)

;tstampavail=0

if tstampavail eq 1 then begin
   home=gettstorepath()
   name=db ne 'k' ? 'imgs'+db  : 'imgs'
   fn=string(home,sh,name,format='(A,I0,"_",A,".hdf")')
   dum=file_search(fn,count=cnt)
   if cnt ne 0 then begin
;    stop
      hdfrestoreext,fn,dum
      print,'restored from',fn
      imgs=dum.imgs
      nimg=n_elements(dum.imgs(*,0))
      ts=dblarr(nimg)
      cc=lonarr(nimg)
      for i=0,nimg-1 do begin
         bcd=imgs(i,5:*)
         gettstamp, bcd, s1,c1
         ts(i)=s1
         cc(i)=c1
      endfor
      ts-=ts(0)
      xxxdt=(ts(1:*)-ts(0:*))
      mdt=median(xxxdt)

      
   endif

endif




pixsizemm = camera eq 'pimax3' ? 12.8e-3 : camera eq 'cascade512' ? 16e-3 : 6.5e-3

readmapping,mapping, mapstr

if rotate eq 0 then camangle*=-1
flc0endt=32767
flc0endstate=0
flc0invert=0

if flc0t0 eq -9999 then begin
   readflc0,sh,flc0t0,flc0per,flc0mark,flc0invert,flc0endt,flc0endstate,db=db
endif
if t0 eq 999 then begin
   readtiming,sh,t0proper,dt,db=db
   readnskip,sh,nskip,db=db

   t0 = t0proper + nskip * dt
endif else nskip=0


pathtmp=path eq '_' ? getenv(tree+'_path') : path
if strpos(pathtmp,';') ne -1 then begin
  path2=strsplit(pathtmp,';',/extract)
  for i=0,n_elements(path2)-1 do begin
    dum=file_search(path2(i)+'/*'+string(sh,format='(I0)')+'*',count=cnt)
    if cnt ne 0 then begin
        path1=path2(i)
        PRINT,'FOUND IN PATH ',path1
        break
    endif
  endfor
  if n_elements(path1) eq 0 then path1=path2(0)
endif else path1=pathtmp


str={sh:sh,$
camera:camera,$
camangle:camangle,$
flencam:flencam,$
rotate:rotate,$
spe:spe,$
tif:tif,$
tifrec:tifrec,$
tifpre:tifpre eq '_' ? '' : tifpre,$
tdms:tdms,$
tdmspre:tdmspre eq '_' ? '' : tdmspre,$
tdmspost:tdmspost eq '_' ? '' : tdmspost,$


path:path1,$
tree:tree,$
;path:path,$
mdsplusnode:mdsplusnode,$
mdsplusseg:mdsplusseg,$
flc0mark:flc0mark,$
flc0t0:flc0t0,$
flc0per:flc0per,$
flc0invert:flc0invert,$
flc0endt:flc0endt,$
flc0endstate:flc0endstate,$
flc1mark:flc1mark,$
flc1t0:flc1t0,$
flc1per:flc1per,$
cellno:cellno,$
t0:t0,$
t0proper:t0proper,$
nskip:nskip,$
dt:dt,$
tstampavail:tstampavail,$
roil:roil,$
roir:roir,$
roib:roib,$
roit:roit,$
binx:binx*xbin,$
biny:biny*xbin,$
xbin:xbin,$
polariser:polariser,$
calno:calno,$
calfile:calfile,$
calfilebg:calfilebg,$
lambdanm:lambdanm,$
mapping:mapping,$
comment:comment,$
mapstr:mapstr,$
pixsizemm:pixsizemm}


if str.t0 eq -999 then getdbtiming, str
;if tif eq '1' and keyword_set(nfr) eq 0 then begin

;sh ne 99996 and sh ne 99997 and db ne 'h1tor' and db ne 'h1up' then begin
;   ivec=getframearray(str)
;endif  else begin
   nfr=3000
   ivec=findgen(nfr)
;endelse
;if db eq 'h1up' then ivec=[0]
 

if tstampavail eq 1 and n_elements(cc) ne 0 then begin
   ivec = cc - 1; 0 is first
endif




str=create_struct(str,'ivec',ivec)



i0=(getcamdims(str)  )/2.
cent=([(i0(0) - (str.roil-1)), (i0(1)-(str.roib-1))]*1.0) / $
  (1.0*[str.roir - str.roil+1,str.roit-str.roib+1])

str.mapstr(12:13) = cent ;; put new centre according to roi!!!!

if (keyword_set(getinfo) or keyword_set(getflc) or str.flc0per mod 1000 eq 999) and not keyword_set(nfr) then begin
   dum=getimgnew(sh,-1,db=db,info=info,/getinfo,str=str,/noloadstr)
   if str.tif eq '1' then info.num_images=max([info.num_images,max(ivec)+1])
   str=create_struct(str,'nfr',info.num_images,'info',info)
endif

if keyword_set(nfr) then  str=create_struct(str,'nfr',nfr)

if keyword_set(getflc) or str.flc0per mod 1000 eq 999 then begin
   getflcinfo,str,info
   str=create_struct(str,'pinfoflc',info)
endif



;; if flc0t0 eq -9998 then begin
;;   flc0mark=fix(mdsvaluestr(str,strupcase(pre+'.MSE.FLC.FLC__00:MARK'),/flat))
;;   flc0space=fix(mdsvaluestr(str,strupcase(pre+'.MSE.FLC.FLC__00:SPACE'),/flat))
;;   flc0invert=(mdsvalue(str,strupcase(pre+'.MSE.FLC.FLC__00:INVERT'),/flat)) eq 'True'
;; endif

end

