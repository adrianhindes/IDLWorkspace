function getimgnew, sh,fr,twant=twant,str=str,info=info,getinfo=getinfo,nostop=nostop,noloadstr=noloadstr,roi=roi,nodeoverride=nodeoverride,db=db, noread=noread,filtertype=filtertype,copy_tdms=copy_tdms
common cbrgetimgnew2, shr, imarr,t,flc0,flc1,str2
common cbshot, shotc,dbc, isconnected
default,filtertype,'none'
if not keyword_set(noloadstr) then readpatch,sh,str,db=db
err=0

if keyword_set(twant) then begin
    fr=floor((twant-str.t0)/str.dt)
    print,'deriving fr=',fr,'from twant=',twant
endif



if str.spe eq 1 then begin
    fmt='(I0)'                  ; fmt='(I3.3)'  else
    if size(sh,/type) ne 7 then begin
        snum=string(sh,format=fmt)
        fil=str.path+'/'+str.tifpre+snum
    endif else fil=str.path+'/'+sh
    filspe=file_search(fil+'.SPE',/fold_case)
        if n_elements(shr) ne 0 then if sh eq shr and not keyword_set(nodeoverride) then begin
            goto,afspe
         endif
    read_spe,filspe,l,t,imarr,str=str2
    afspe:
    im=imarr(*,*,fr)
    shr=sh
    info=create_struct(str2,'num_images',n_elements(imarr(0,0,*)))
    goto,aff
 endif

if str.tif ne 0 then begin
    fmt='(I0)'                  ; fmt='(I3.3)'  else
    if size(sh,/type) ne 7 then begin
        snum=string(sh,format=fmt)
        fil=str.path+'/'+str.tifpre+snum
    endif else fil=str.path+'/'+sh
    filtif=file_search(fil+'.tif',/fold_case)
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

        if str.tif eq 2 and strmid(str.cellno,0,4) eq 'msea'  then begin ;and str.tree ne 'mse_2013'

            mpath=str.tree+'_path'
            tmp=getenv(mpath)
            if str.path ne tmp then begin
                setenv,mpath+'='+str.path
                pth=1
            endif else pth=0

            mdsopen,str.tree,sh

            pre='\'+str.tree+'::top'
            flc0=mdsvalue2(pre+'.DAQ.DATA:FLC_0',/quiet)
            flc1=mdsvalue2(pre+'.DAQ.DATA:FLC_1',/quiet)
            flc0.t+=str.t0
            flc1.t+=str.t0
            mdsclose
            if pth eq 1 then begin
                setenv,mpath+'='+tmp
            endif

            info=create_struct(info,'flc0',flc0,'flc1',flc1)
         endif
    endif

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

             mpath=str.tree+'_path'
             tmp=getenv(mpath)
             if str.path ne tmp then begin
                 setenv,mpath+'='+str.path
                 pth=1
             endif else pth=0
            if n_elements(isconnected) gt 0 then if isconnected eq 1 then begin
               mdsdisconnect
               isconnected=0
            endif
            pre='\'+str.tree+'::top'
            mdsopen,str.tree,sh;;
            nfr=mdsvalue(strupcase(pre+'.PCO_CAMERA.SETTINGS.TIMING:NUM_IMAGES'))
            nx=2560
            ny=2160
            mdsclose
            if pth eq 1 then begin
               setenv,mpath+'='+tmp
            endif
         endif


       tdms_get_image,data=im,ifr=fr,path='',file=filtdms,nx=nx,ny=ny,nfr=nfr,bug=((sh lt 9050) and (db eq 'k')),copy_tdms=copy_tdms
;       nfr=80
    endif else begin
       nfr=280
       nx=2560
       ny=2160
       im=uintarr(nx,ny)
    endelse



    if keyword_set(getinfo) then begin
       sz=size(im,/dim)*[str.binx,str.biny]/str.xbin
       roitmp=[str.roil,str.roir,str.roib,str.roit]
       szroi=[roitmp(1)-roitmp(0),roitmp(3)-roitmp(2)]+1
       if product(sz eq szroi) eq 0 then begin
          print,'error: full sz of im (considering binning) is',sz,'while sz from roi is ',szroi
          err=1
       endif
       info={nx:nx,ny:ny,num_images:nfr}
;;; need to add more when found out file is ok
       if strmid(str.cellno,0,4) eq 'cxrs' then begin
               stat1a=intarr(nfr)
               stat1=[[stat1a],[stat1a]]
               info=create_struct(info,'stat1',stat1)
          ;;;
       endif

       if strmid(str.cellno,0,3) eq 'mse' then begin
          ;;;

             mpath=str.tree+'_path'
             tmp=getenv(mpath)
             if str.path ne tmp then begin
                 setenv,mpath+'='+str.path
                 pth=1
             endif else pth=0
            if n_elements(isconnected) gt 0 then if isconnected eq 1 then begin
               mdsdisconnect
               isconnected=0
            endif
 ;           stop

            pre='\'+str.tree+'::top'
;            dbc=str.tree
;            shotc=sh
;            flc0=cgetdata(strupcase(pre+'.DAQ.WAVEFORMS:FLC_0'))
;            flc1=cgetdata(strupcase(pre+'.DAQ.WAVEFORMS:FLC_1'))
            mdsopen,str.tree,sh;;

            flc0=mdsvalue2(strupcase(pre+'.DAQ.WAVEFORMS:FLC_0'),/quiet)
            flc1=mdsvalue2(strupcase(pre+'.DAQ.WAVEFORMS:FLC_1'),/quiet)
            if n_elements(flc0.t) lt 10 then begin
               flc0={t:'*',v:'*'}
            endif
            if size(flc0.t,/type) ne 7 then flc0.t+=str.t0proper
            if size(flc0.t,/type) ne 7 then             flc1.t+=str.t0proper


            flc0mark=fix(mdsvalue(strupcase(pre+'.MSE.FLC.FLC__00:MARK'),/quiet))
            flc0space=fix(mdsvalue(strupcase(pre+'.MSE.FLC.FLC__00:SPACE'),/quiet))
            flc0invert=(mdsvalue(strupcase(pre+'.MSE.FLC.FLC__00:INVERT'),/quiet)) eq 'True'

            flc0per_orig=str.flc0per

            if (str.flc0per eq 999) or (str.flc0per eq 9999) then begin
               str.flc0per=flc0mark+flc0space
               str.flc0mark=flc0mark
;               str.flc0t0=0
               str.flc0invert=flc0invert
            endif


            ifr=indgen(nfr)

;999 makes it interpolate signa, 9999 makes it hard coded on db values
            if size(flc0.t,/type) eq 7 or flc0per_orig ne 999 then begin
               ifr2=ifr+str.nskip
               stat1=[[((ifr2 - str.flc0t0) mod str.flc0per) / (str.flc0mark eq 0 ? str.flc0per/2 : str.flc0mark)], [((ifr2-str.flc1t0) mod str.flc1per) / (str.flc1mark eq 0 ? str.flc1per/2 : str.flc1mark)]]
               idx=where(ifr gt str.flc0endt)

               if str.flc0invert eq 1 then stat1=1-stat1
               if idx(0) ne -1 then stat1(idx,*) = str.flc0endstate

            endif else begin
               tfr=str.t0+str.dt*ifr+ str.dt * 0.1
               if (min(tfr) lt min(flc0.t)) or $
                  (max(tfr) gt max(flc0.t)) then begin
                  print,'warning extrapolatinon of flc signal required'
;               stop
               endif
               flc0i1=interpol(flc0.v,flc0.t,tfr)
;           plot,flc0.t,flc0.v,xr=[0,2]
               stat1a=1-fix((flc0i1+5)/10.)
;            oplot,tfr,stat1a,psym=4,col=2
               stat1=[[stat1a],[stat1a*0]]
            endelse



            if pth eq 1 then begin
                setenv,mpath+'='+tmp
            endif



            info=create_struct(info,'flc0',flc0,'flc1',flc1,'flc0mark',flc0mark,'flc0space',flc0space,'flc0invert',flc0invert,'stat1',stat1)
            
            
;            stop
       endif

    endif
    goto,aff
endif



;;;if str.tif eq 0 then begin
mdsplusseg=str.mdsplusseg
if keyword_set(nodeoverride) then mdsplusseg=0

    if mdsplusseg eq 0 then begin
        if n_elements(shr) ne 0 then if sh eq shr and not keyword_set(nodeoverride) then begin
            goto,af
        endif
        mpath=str.tree+'_path'
        tmp=getenv(mpath)
        if str.path ne tmp then begin
            setenv,mpath+'='+str.path
            pth=1
        endif else pth=0
;        stop

        if n_elements(isconnected) ne 0 then if isconnected eq 1 then mdsdisconnect
        mdsopen,str.tree,sh
        if keyword_set(nodeoverride) then tvar=nodeoverride else tvar=str.mdsplusnode
        imarr=mdsvalue(tvar)
        t=mdsvalue('DIM_OF('+tvar+',2)')

        if keyword_set(getinfo) and strmid(str.cellno,0,4) eq 'msea'  then begin ;and str.tree ne 'mse_2013'
            pre='\'+str.tree+'::top'
            flc0=mdsvalue2(pre+'.DAQ.DATA:FLC_0',/quiet)
            flc1=mdsvalue2(pre+'.DAQ.DATA:FLC_1',/quiet)
            flc0.t+=str.t0
            flc1.t+=str.t0
        endif
        if pth eq 1 then begin
            setenv,mpath+'='+tmp
        endif

        shr=sh
        af:
        im=imarr(*,*,fr)



        if keyword_set(getinfo) then begin
            dt=t(1)-t(0)

            info={num_images:n_elements(imarr(0,0,*)),dt:dt}

            if strmid(str.cellno,0,4) eq 'msea' then info=create_struct(info,'flc0',flc0,'flc1',flc1)
            if info.dt ne str.dt then begin
                print,'error: dt from mdsplus and log dont match: mdsplus=',info.dt,' and log=',str.dt
;                err=1
            endif


        endif
    endif else begin
        if keyword_set(nodeoverride) then tvar=nodeoverride else tvar=str.mdsplusnode

        mpath=str.tree+'_path'
        tmp=getenv(mpath)
        if str.path ne tmp then begin
           setenv,mpath+'='+str.path
           pth=1
        endif else pth=0

        mdsopen,str.tree,sh
        tmp=get_image_seg(tvar,fr)
        mdsclose
        im=tmp.images
        if pth eq 1 then begin
           setenv,mpath+'='+tmp
        endif

    endelse

;;endif




;if err eq 1 and not keyword_set(nostop) then stop


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

;if filtertype

return,im
end

