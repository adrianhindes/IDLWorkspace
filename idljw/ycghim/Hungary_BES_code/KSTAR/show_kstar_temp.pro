pro show_kstar_temp,shot,timerange=timerange,out_R=out_R,out_Te=out_Te,$
   noplot=noplot,errormess=errormess,store=store,verbose=verbose,$
   xrange=xrange,yrange=yrange,thick=thick,charsize=charsize,$
   noerase=noerase,nolegend=nolegend
;*************************************************************************
;  SHOW_KSTAR_ECE.PRO           S. Zoletnik   3.2.2012
;*************************************************************************
; Plots and returns the mean ECE temperature profile for a KSTAR shot
; in a timerange.
;
;
; INPUT:
;  shot: Shot number
;  timerange: Time range in seconds. The profile will be averaded
;  /noplot: DO not plot just return data
;  /store: Store data locally as in get_rawsignal
;  /verbose: Print progress infomation
; OUTPUT:
;  out_R: Major radius for measurement points
;  out_Te: Electron temperature on the R points in out_R
;  errormess: Error message or ''
;************************************************************************

nch = 48
errormess = ''
for i=0,nch-1 do begin
  if (keyword_set(verbose)) then begin
    print,'Channel '+i2str(i+1)+' of '+i2str(nch)
    wait,0.1
  endif
  get_rawsignal,shot,'KSTAR/\ECE'+i2str(i+1,digits=2)+':FOO',t,d,timerange=timerange,store=store,errormess=errormess
  if (errormess ne '') then return
  if (n_elements(out_te) lt 48) then begin
     out_te = fltarr(nch)
  endif
  out_te[i] = mean(d)
  get_rawsignal,shot,'KSTAR/\ECE'+i2str(i+1,digits=2)+':RPOS2ND',t,d,timerange=timerange,store=store,errormess=errormess,/no_time
  if (errormess ne '') then return
  if (n_elements(out_R) lt 48) then begin
     out_R = fltarr(nch)
  endif
  out_R[i] = mean(d)
endfor

if (not keyword_set(noplot)) then begin
  if (not keyword_set(noerase)) then erase
  if (not keyword_set(nolegend)) then time_legend,'show_kstar_temp.pro'
  default,yrange,[0,max(out_te)*1.05]
  plot,out_r,out_te,xtitle='R[m]',xstyle=1,xrange=xrange,yrange=yrange,ystyle=1,ytitle='T!De!N [keV]',$
    thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize
endif
end