pro show_ztprofile,shot,chan_prefix=chan_prefix,chan_postfix=chan_postfix,channels=channels,$
  errormes=errormess,zscale=zscale,timerange=timerange

;***********************************************************************************
;* SHOW_ZTPROFILE.PRO                                    S. Zoletnik 2009          *
;***********************************************************************************
;* Plots a 2D (time-space) figure of a series of signals.                          *
;* INPUT:                                                                          *
;*   shot: shot number                                                             *
;*   channels: The list of channels to use. This can be either an array of strings *
;*             or numbers. Numbers will be converted to strings. The full signal   *
;*             names are composed as: <chan_prefix><channels[i]><chan_postfix>     *
;*   chan_prefix: The first part of the signal names (string)                      *
;*   chan_postfix: The last part of the signal names (string)                      *
;*   zscale: The spatial coordiantes for the signals.                              *
;*   timerange: The timerange to process                                           *
;* OUTPUT:                                                                         *
;*   errormess: Error message or ''                                                *
;***********************************************************************************


default,chan_prefix,'cache/110553_BES-'
default,chan_postfix,'_td'
default,channels,indgen(12)+2
default,timerange,[1,3]

errormess = ''

nch = n_elements(channels)
default,zscale,findgen(nch)+1

for i=0,nch-1 do begin
  get_rawsignal,shot,chan_prefix+strcompress(string(channels[i]),/remove_all)+chan_postfix,t,d,errormess=errormess,trange=timerange
  if (errormess ne '') then return

  if (i eq 0) then begin
     default,timerange,[min(t),max(t)]
     ind = where((t ge timerange[0]) and (t le timerange[1]))
     if (ind[0] lt 0) then begin
       errromess = 'No data in requested time window.'
       return
     endif
     t_common = t[ind]
     d = d[ind]
     d2 = fltarr(n_elements(d),nch)
  endif
  ind = where((t ge timerange[0]) and (t le timerange[1]))
  if (ind[0] lt 0) then begin
     errromess = 'No data in requested time window.'
     return
  endif
  t = t[ind]
  d = d[ind]
  if (n_elements(d) ne (size(d2))[1]) then begin
    errormess = 'Signal length are different.'
    return
  endif
  if (n_elements(t) ne n_elements(t_common)) then begin
    errormess = 'Signal length are different.'
    return
  endif
  ind = where(abs(t-t_common) gt (t_common[1]-t_common[0])*0.5)
  if (ind[0] ge 0) then begin
    errormess = 'Incompatible timevetors.'
    return
  endif

  d2[*,i] = d
endfor


contour,d2,t_common,zscale,/fill
stop

end