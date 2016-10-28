pro corr_zscale,shot,channels,data_source=data_source,chan_prefix=chan_prefix,$
                 chan_postfix=chan_postfix,zscale=zscale,ztitle=ztitle,errormess=errormess,$
                 deflection=deflection

; ****************** corr_zscale.pro ************************* S. Zoletnik  23.02.2007 ****
; Return spatial scale and title of z axis for channels depending on data source
;
; INPUT:
;   shot: shot number
;   channels: list of channels (number or string). Will be converted to string by get_rawsignal
;   data_source: data source in get_rawsignal
;   chan_prefix, chan_postfix: parts of channel names (see get_rawsignal)
;   deflection: The vertical deflection of the beam from the equatorial plane [cm]
;                (Deflection is assumed to be parallel)
; OUTPUT:
;   zscale: The Z values of the channels
;   ztitle: The title for plotting the z axis
; *************************************************************************************

default,data_source,fix(local_default('data_source',/silent))
default,deflection,0.

if (not defined(channels)) then begin
  errormess = 'Channels are not set. (Error in corr_zscale.pro)'
  if (not defined(silent)) then print,errormess
  return
endif

errormess = ''

;   MAST
if (data_source eq 23) then begin
   known_ch = strarr(8)
   BES_R = [(1403.20+1412.64)/2, (1364.86+1374.37)/2, (1326.02+1335.77)/2, (1286.75+1296.51)/2, $
         (1246.91+1256.91)/2, (1206.54+1216.73)/2, (1165.92+1176.15)/2, (1124.72+1134.93)/2]
   known_ch_z = BES_R/1000
   for i=1,8 do begin
     known_ch[i-1] = 'MAST/xbs_channel_'+i2str(i)
   endfor
   zscale = fltarr(n_elements(channels))
   ztitle = 'R [m]'
   for i=0,n_elements(channels)-1 do begin
     ch = channels(i)
     get_rawsignal,shot,ch,data_source=23,chan_prefix=chan_prefix,chan_postfix=chan_postfix,/nodata
     ind = where(ch eq known_ch)
     ; If this channel is unknown then returning the index as scale and ??? as title
     if (ind[0] lt 0) then begin
       zscale = findgen(n_elements(channels))+1
       ztitle = '???'
       return
     endif
     zscale[i] = known_ch_z[ind[0]]
   endfor
   return
endif ; end of MAST

;   TEXTOR
if (data_source eq 25) then begin
   known_ch = strarr(16)
   load_config_parameter,shot,'Optics','MirrorPosition',data_source=25,output_struct=s,$
         datapath=datapath,errormess=errormess,/silent
   if (errormess ne '') then begin
     print,'Cannot determine mirror position. Assuming OUTER.'
     mirror = 'OUTER'
   endif else begin
     if (s.value eq 'OUTER position') then begin
        mirror = 'OUTER'
     endif else begin
        if (s.value eq 'INNER position') then begin
          mirror = 'INNER'
        endif else begin
          print,'Unknown mirror position in config file:'+s.value+'. Assuming OUTER.'
          mirror = 'OUTER'
        endelse
     endelse
   endelse
   ; The returned values are r relative to the vessel center
   if (mirror eq 'OUTER') then begin
     ; These R values are coming from Zemax optics calculation.
     ; The calibration rod measurements indicate about 7-8 mm deeper look (smaller R)
     known_ch_z = ([2110.9,2120.7,2130.4,2140.0,2149.5,2159.1,2168.4,2177.4,2186.4,2195.5,2204.3,2212.7,2221.1,2229.8,2238.0,2245.7]-1750)/10.
     angles = [51.91,52.53,53.15,53.78,54.40,55.04,55.68,56.30,56.93,57.58,58.21,58.83,59.45,60.10,60.73,61.32]
   endif else begin
     ; These R values are coming from Zemax optics calculation.
     ; The calibration rod measurements indicate about 15 mm deeper look (smaller R)
     known_ch_z = ([2039.8,2052.7,2065.5,2078.1,2090.4,2102.7,2114.6,2126.1,2137.4,2148.7,2159.5,2169.8,2179.8,2190.2,2199.8,2208.6]-1750)/10.
     angles = [44.79,45.48,46.22,46.86,47.56,48.27,48.98,49.67,50.36,51.08,51.77,52.44,53.11,53.81,54.48,55.10]
   endelse
   for i=1,16 do begin
     known_ch[i-1] = 'BES-'+i2str(i)
   endfor
   zscale = fltarr(n_elements(channels))
   obs_angle = fltarr(n_elements(channels))

   ztitle = 'r [cm]'
   for i=0,n_elements(channels)-1 do begin
     ch = channels(i)
     ;get_rawsignal,shot,ch,data_source=25,chan_prefix=chan_prefix,chan_postfix=chan_postfix,/nodata
     ind = where(ch eq known_ch)
     ; If this channel is unknown then returning the index as scale and ??? as title
     if (ind[0] lt 0) then begin
       zscale = findgen(n_elements(channels))+1
       ztitle = '???'
       return
     endif
     zscale[i] = known_ch_z[ind[0]]
     obs_angle[i] = angles[ind[0]]
   endfor

   if (deflection ne 0) then begin
     zscale = sqrt((zscale + deflection/tan(obs_angle/180.*!pi))^2 + deflection^2)
   endif
   return
endif ; end of TEXTOR

; If these channels are not numbers returning the index as scale and ??? as title
if is_string(channels) then begin
   zscale = findgen(n_elements(channels))+1
   ztitle = '???'
   return
 endif

beam_coordinates,shot,beam_RR,beam_ZZ,zscale,data_source=data_source
zscale = zscale[channels-1]
ztitle = 'Z [cm]'
return

end
