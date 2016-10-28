pro gettim, sh=sh,tstart=tstart,ft=ft,folder=folder,type=type,iidx=iidx,wid=wid


if sh le 8010 then begin ; approx
    ft=0.05

    if sh ge 7897 then ft = 0.02
    if sh ge 7957 then ft=0.025

    tstart=-0.1 ; ok for most of sensicam

    if sh ge 7957 then tstart=-0.12 ;else tstart=0.5



    if sh le 7828 then begin
        folder='~/idl/clive/nleonw/kmse_7345'  ; sensicam
        wid=1392
    endif else  begin
        folder='~/idl/clive/nleonw/kmse_7891'
        wid=1600
    endelse

    

    type='flc'

    if sh eq 7897 then begin
        restore,file='~/idl/lf_7897.sav',/verb ; gets iidx
    endif
endif

if sh gt 8010 then begin
    wid=1600

;if seg eq 0 then ft=0.03333 else
; ft=info.frame_time *2
    ft = 1/40.                  ;1/30.
    if sh eq 8060 then ft = 1/125. * 2.
    if sh eq 8061 then ft=1/100.
    if sh ge 8062 then ft = 1/125.
    
;ft=1/20.
;tstart=-0.1
;tstart=0.5
;tstart=-0.12
    tstart=-0.1 + 0.5 *ft       ; shift by half a time stpe
    if sh ge 8047 then tstart=-0.095 + 0.5*ft
    if sh ge 8049 then tstart=-0.09 + 0.5*ft
    
    folder='~/idl/clive/nleonw/kmse_8012'
    type='spath'
endif

end

