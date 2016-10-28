shot=13567
restore,file='~/idl/pm2.sav'
pmain=ptr_new(pm2)

	spectra1 = getspectra(shot, pm=pmain, /doadc, /rad, sum=sum, error=error, _extra=extra)

;d=*spectra1.pspectra(0)
for i=0,109 do begin
    !p.multi=[0,5,1]
    for j=0,4 do begin
        contourn2,(*spectra1.pspectra(j))(*,*,i),/cb,zr=[0,$
                           max(*spectra1.pspectra(j))],title=i
    endfor
;    cursor,dx,dy,/down
    wait,0.2
endfor




;dat=getrcc(13567)
;d=dat.data;;

;nt=n_elements(dat.timestamps)

;for i=0,nt-1 do begin
;    contourn2,d(*,*,i),/cb,zr=[0,max(d)],title=i
;    cursor,dx,dy,/down
;    wait,0.2
;endfor


end
