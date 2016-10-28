pro endfig,pr=pr,jp=jp,gs=gs,del=del,png=png
if !d.name eq 'WIN' then return
if !d.name eq 'X' then return

if !d.name eq 'PS' then device,/close
if !version.os eq 'Win32' then set_plot,'WIN' else set_plot,'X'
!p.font=-1
if keyword_set(pr) then spawn,'lpr -Pprl_helen ~/idl.ps'
tek_color
!p.color=1
!p.background=0

common cb,fnameb
if keyword_set(jp) then begin
    fname=fnameb
    pos=strpos(fnameb,'~')
    if pos ne -1 then begin
        spl0=strmid(fnameb,0,pos)
        spl1=strmid(fnameb,pos+1,255)

        fname=spl0+getenv('HOME')+spl1
    endif
    fnamej=strmid(fname,0,strpos(fname,'.eps'))+'.jpg'

    if !version.os ne 'Win32' then begin
        spw='/usr/bin/gs -sDEVICE=jpeg -sOutputFile='+fnamej+' -dNOPAUSE -dBATCH -dSAFEr -dJPEGQ=85 -r300 -dEPSCrop -dTextAlphaBits=4 -dGraphicsAlphaBits=4 '+fname
;        stop
;        print,spw
        spawn,spw
    endif else begin
            spw='C:\gs\gs8.60\bin\gswin32.exe -IC:\gs\gs7.00\lib;C:\gs\fonts -sDEVICE=jpeg -sOutputFile='+fnamej+' -dNOPAUSE -dBATCH -dSAFEr -dJPEGQ=85 -r300 -dEPSCrop -dTextAlphaBits=4 -dGraphicsAlphaBits=4 '+fname
print,spw

        endelse



    endif

if keyword_set(png) then begin
    fname=fnameb
    pos=strpos(fnameb,'~')
    if pos ne -1 then begin
        spl0=strmid(fnameb,0,pos)
        spl1=strmid(fnameb,pos+1,255)

        fname=spl0+getenv('HOME')+spl1
    endif
    fnamej=strmid(fname,0,strpos(fname,'.eps'))+'.png'

    if !version.os ne 'Win32' then begin
        spw='/usr/bin/gs -sDEVICE=png16m -sOutputFile='+fnamej+' -dNOPAUSE -dBATCH -dSAFEr -r300 -dEPSCrop -dTextAlphaBits=4 -dGraphicsAlphaBits=4 '+fname
;        stop
;        print,spw
        spawn,spw
    endif else begin
;            spw='C:\gs\gs8.60\bin\gswin32.exe -IC:\gs\gs7.00\lib;C:\gs\fonts -sDEVICE=jpeg -sOutputFile='+fnamej+' -dNOPAUSE -dBATCH -dSAFEr -dJPEGQ=85 -r300 -dEPSCrop -dTextAlphaBits=4 -dGraphicsAlphaBits=4 '+fname
print,spw

        endelse
 endif


if keyword_set(gs) then begin
    fname=fnameb
    pos=strpos(fnameb,'~')
    if pos ne -1 then begin
        spl0=strmid(fnameb,0,pos)
        spl1=strmid(fnameb,pos+1,255)

        fname=spl0+getenv('HOME')+spl1
    endif
spawn,'hostname',hostname
if hostname ne 'prl63'  then  spawn,'/usr/bin/gv '+string(fname)+' &' else $
   spawn,'/usr/bin/evince '+string(fname)+' &'

endif


if keyword_set(del) then begin
    spawn,'rm '+fnameb
endif
    
end

  
