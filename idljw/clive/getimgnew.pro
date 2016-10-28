function getimgnew, sh,fr1,twant=twant,str=str,info=info,getinfo=getinfo,nostop=nostop,noloadstr=noloadstr,roi=roi,db=db, noread=noread,copy_tdms=copy_tdms,noxbin=noxbin, nosubindex=nosubindex,getflc=getflc,doseq=doseq,dotmedian=dotmedian,filter=filter
common cbrgetimgnew2, shr,dbr, imarr,t,flc0,flc1,str2,angstep,theta0,flipper
common cbshot, shotc,dbc, isconnected


if n_elements(fr1) gt 1 then begin
   n=n_elements(fr1)
   for i=0,n-1 do begin
      print, 'getting image',i,'out of ',n
      dum=getimgnew( sh,fr1(i),twant=twant,str=str,info=info,getinfo=getinfo,nostop=nostop,noloadstr=noloadstr,roi=roi,db=db, noread=noread,copy_tdms=copy_tdms,noxbin=noxbin, nosubindex=nosubindex,getflc=getflc)
      if i eq 0 then begin
         dums=dum*1.0
         sz=size(dum,/dim)
         seq=fltarr(sz(0),sz(1),n)
         seq(*,*,0)=dum
      endif else begin
         dums=dums+dum*1.0
         seq(*,*,i)=dum
      endelse
   endfor
   if keyword_set(dotmedian) then begin
      for i=0,sz(0)-1 do for j=0,sz(1)-1 do seq(i,j,*)=adaptive_median(reform(seq(i,j,*)))
   endif
   if keyword_set(doseq) then return,seq else    return,dums
endif




if not keyword_set(noloadstr) then readpatch,sh,str,db=db,getflc=getflc
err=0
if keyword_set(noxbin) then begin
   str.binx = str.binx/str.xbin
   str.biny = str.biny/str.xbin
   str.xbin = 1
endif

if n_elements(twant) then begin
    fr1=floor((twant-str.t0)/str.dt)
    print,'deriving fr=',fr1,'from twant=',twant
endif

;fr=value_locate(str.ivec,fr1) ; for reduced frames
print,'nosubindex=',keyword_set(nosubindex)
if fr1 ne -1 and not keyword_set(nosubindex) then begin
   dum=where(str.ivec eq fr1,cnt)
   fr=dum(0)
   if cnt eq 0 then begin
      print,'frame not availbale filling witn nans!'
;      stop
      nx=str.roir - str.roil + 1
      ny=str.roit - str.roib + 1
      nx = nx / str.binx
      ny = ny / str.biny
      d=fltarr(nx,ny) + !values.f_nan
     return,d
   endif
endif else fr=fr1



if keyword_set(filter) then begin

common cbfilter, sh1, seq1,frarr
im=seq1(*,*,value_locate(frarr,fr))
goto,aff
endif



if fr ne fr1 then print,'dedured frame to be newly ',fr,'not ',fr1


if str.spe eq 1 then begin
    fmt='(I0)'                  ; fmt='(I3.3)'  else
    if size(sh,/type) ne 7 then begin
        snum=string(sh,format=fmt)
        fil=str.path+'/'+str.tifpre+snum
    endif else fil=str.path+'/'+sh
    filspe=file_search(fil+'.SPE',/fold_case)

    if n_elements(shr) ne 0 then begin
       if size(shr,/type) eq size(sh,/type) then begin
          if sh eq shr and db eq dbr then  goto,afspe
       endif
    endif
    read_spe,filspe,l,t,imarr,str=str2
    afspe:
    im=imarr(*,*,fr>0)
    shr=sh
    dbr=db
    info=create_struct(str2,'num_images',n_elements(imarr(0,0,*)))
    goto,aff
 endif

if str.tif eq 1 then begin
    fmt='(I0)'                  ; fmt='(I3.3)'  else
    if size(sh,/type) ne 7 then begin
        snum=string(sh,format=fmt)
        fil=str.path+'/'+str.tifpre+snum
    endif else fil=str.path+'/'+sh
    filtif=file_search(fil+'.tif',/fold_case)
    if fr ge 0 then im=read_tiff(filtif,/verb,image_index=fr)
    if keyword_set(getinfo) then begin
        dum=query_tiff(filtif,info)
        if str.tifrec ne 0 then begin

            info=create_struct(info,'tif',getrecnew(fil+'.rec'))
            roitmp=[str.roil,str.roir,str.roib,str.roit]
            if product(info.tif.roi eq roitmp) ne 1 then begin
                print,'error: tif roi is'
                print,info.tif.roi
                print,'log roi is'
                print,roitmp
                err=1
            endif
            if info.tif.bin(0) ne str.binx/str.xbin then begin
                print,'error: tif bin is ',info.tif.bin(0),'log bin is ',str.binx
                err=1
            endif
            if info.tif.cam2 ne str.camera then begin
                print,'error: tif camera is',info.tif.cam2,'log camera is',str.camera
                err=1
            endif
            sz=size(im,/dim)*[str.binx,str.biny]/str.xbin
            szroi=[info.tif.roi(1)-info.tif.roi(0),info.tif.roi(3)-info.tif.roi(2)]+1
            if product(sz eq szroi) eq 0 then begin
                print,'error: full sz of im (considering binning) is',sz,'while sz from roi is ',szroi
                err=1
            endif
            tmp=(info.tif.expdel(0)+info.tif.expdel(1))*1e-3 / str.dt
            if tmp lt 0.8 or tmp gt 1.0001 then begin
                print,' likely timing error: tif exposure is',info.tif.expdel(0)*1e-3, 'while log interfrme time is ',str.dt
                err=1
             endif
         endif
        
     endif
    goto,aff

 endif


if str.tif eq 2 then begin

   if n_elements(shr) ne 0 then if sh eq shr and db eq dbr then  goto,afpco

   shr=sh
   dbr=db



    fmt='(I0)'                  ; fmt='(I3.3)'  else
    if size(sh,/type) ne 7 then begin
        snum=string(sh,format=fmt)
        fil=str.path+'/'+str.tifpre+snum
    endif else fil=str.path+'/'+sh
    filtif=file_search(fil+'.dat',/fold_case)
    if fr ge 0 then begin
       read_mydatapco,imarr,path=str.path+'/',shotno=sh,angstep=angstep,theta0=theta0,flipper=flipper
    endif
    afpco:
    im=imarr(*,*,fr1)
    info={nfr:n_elements(imarr(0,0,*)),angstep:angstep,theta0:theta0,flipper:flipper}
    goto,aff
 endif


if str.tif eq 1 then begin

im=read_tiff(filtif,/verb,image_index=fr)
    if keyword_set(getinfo) then begin
        dum=query_tiff(filtif,info)
        if str.tifrec ne 0 then begin

            info=create_struct(info,'tif',getrecnew(fil+'.rec'))
            roitmp=[str.roil,str.roir,str.roib,str.roit]
            if product(info.tif.roi eq roitmp) ne 1 then begin
                print,'error: tif roi is'
                print,info.tif.roi
                print,'log roi is'
                print,roitmp
                err=1
            endif
            if info.tif.bin(0) ne str.binx/str.xbin then begin
                print,'error: tif bin is ',info.tif.bin(0),'log bin is ',str.binx
                err=1
            endif
            if info.tif.cam2 ne str.camera then begin
                print,'error: tif camera is',info.tif.cam2,'log camera is',str.camera
                err=1
            endif
            sz=size(im,/dim)*[str.binx,str.biny]/str.xbin
            szroi=[info.tif.roi(1)-info.tif.roi(0),info.tif.roi(3)-info.tif.roi(2)]+1
            if product(sz eq szroi) eq 0 then begin
                print,'error: full sz of im (considering binning) is',sz,'while sz from roi is ',szroi
                err=1
            endif
            tmp=(info.tif.expdel(0)+info.tif.expdel(1))*1e-3 / str.dt
            if tmp lt 0.8 or tmp gt 1.0001 then begin
                print,' likely timing error: tif exposure is',info.tif.expdel(0)*1e-3, 'while log interfrme time is ',str.dt
                err=1
             endif
         endif
        
     endif
    goto,aff

 endif



if str.tdms ne 0 then begin
    fmt='(I0)'                  ; fmt='(I3.3)'  else
    if size(sh,/type) ne 7 then begin
        snum=string(sh,format=fmt)
        fil=str.path+'/'+str.tdmspre+snum+str.tdmspost
    endif else fil=str.path+'/'+sh
    filtdms=fil+'.TDMS'
    if not keyword_set(noread) then begin

       if sh lt 9050 and db eq 'k' then begin
          nfr=mdsvaluestr(str,'.PCO_CAMERA.SETTINGS.TIMING:NUM_IMAGES',/flat,/open,/close)
          nx=2560
          ny=2160
       endif
       tdms_get_image,data=im,ifr=fr,path='',file=filtdms,nx=nx,ny=ny,nfr=nfr,bug=((sh lt 9050) and (db eq 'k')),copy_tdms=copy_tdms ; if neg fr then is ok
       nfr=fix(nfr)
       nx=fix(nx)
       ny=fix(ny)
;       nfr=80
    endif else begin
       nfr=280
       nx=2560
       ny=2160
       im=uintarr(nx,ny)
    endelse



    if keyword_set(getinfo) then begin
       sz=[nx,ny]*[str.binx,str.biny]/str.xbin
       roitmp=[str.roil,str.roir,str.roib,str.roit]
       szroi=[roitmp(1)-roitmp(0),roitmp(3)-roitmp(2)]+1
       if product(sz eq szroi) eq 0 then begin
          print,'error: full sz of im (considering binning) is',sz,'while sz from roi is ',szroi
          err=1
       endif
       info={nx:nx,ny:ny,num_images:nfr}
;;; need to add more when found out file is ok
       
;            stop
    endif

goto,aff
endif




mdsplusseg=str.mdsplusseg

if mdsplusseg eq 0 then begin
   if n_elements(shr) ne 0 then if sh eq shr and db eq dbr then  goto,af

   imarr=mdsvaluestr(str,str.mdsplusnode,/flat,/open,/close)
   shr=sh
   dbr=db

   af:
   im=imarr(*,*,fr>0)

   if keyword_set(getinfo) then begin
      sz=size(imarr,/dim)
      info={num_images:n_elements(imarr(0,0,*)),nx:sz(0),ny:sz(1)}
;;added extras...

      theta0=mdsvaluestr(str,'\MSE_2015::TOP.MSE.ROTATOR:START',/flat,/open)
      dtheta=mdsvaluestr(str,'\MSE_2015::TOP.MSE.ROTATOR:STEP',/flat,/close)
      ash=reform([0,1] # replicate(1,info.num_images/2),info.num_images)
      info=create_struct(info,'theta0',theta0,'angstep',dtheta,'flipper',ash)
   endif

   goto,aff

endif else begin
   
   dum=mdsvaluestr(str,/nodata,/open)
   tmp=get_image_seg(str.mdsplusnode,fr>0)
   
   im=tmp.images

   if keyword_set(getinfo) then begin
      sz=size(tmp.images,/dim)
      dum1=mdsvalue('GetNumSegments('+str.mdsplusnode+')')
      info={num_images:dum1,nx:sz(0),ny:sz(1)}

;;added extras...

;      theta0=mdsvaluestr(str,'\MSE_2015::TOP.MSE.ROTATOR:START',/flat,/open)
;      dtheta=mdsvaluestr(str,'\MSE_2015::TOP.MSE.ROTATOR:STEP',/flat,/close)
;      ash=reform([0,1] # replicate(1,info.num_images/2),info.num_images)
;      info=create_struct(info,'theta0',theta0,'angstep',dtheta,'flipper',ash)

   endif

endelse



aff:

if n_elements(im) eq 0 then return,0
im=rotate(im,str.rotate)
if str.xbin ne 1 then begin
    sz=size(im,/dim)
    im=rebin(im,sz(0)/str.xbin,sz(1)/str.xbin)
    print,'resized it'
endif

if keyword_set(roi) then begin
    roit=roi-1
    im=im(roit(0):roit(1),roit(2):roit(3))
    print,'changed roi to ',roi
    str.roil=roi(0)
    str.roir=roi(1)
    str.roib=roi(2)
    str.roit=roi(3)
endif


;im=adaptive_median(im)
return,im
end

