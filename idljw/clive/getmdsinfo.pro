pro getmdsinfo

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
            
            
