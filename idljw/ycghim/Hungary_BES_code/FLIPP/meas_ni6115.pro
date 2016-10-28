pro meas_ni6115, nomeas=nomeas, shot=shot, tstart=tstart, tlength=tlength, fsample=fsample, $
 nchannel=nchannel, gain=gain, testmode=testmode, errmess=errmess, coupling=coupling

;default, dir, 'c:\jet\measure\'   ; directory of ni6115_shot.exe
default, dir, 'c:\work\AUG\'
; collect config
;default, tstart, 0
;default, tlength,1
;default, fsample, 1    ; MHZ
;default, nchannel, 1
;default, gain, 50   ; 1 2 4 20 50
;default, test, 'test'
;default, shot, 'ni-6115'
;default, coupling, 0
; error handling

filen=i2str(shot)+i2str(nchannel)

; ALWAYS DC COUPLING
coupling = 1


  if coupling eq 0 then begin

     coupling='AC'

  endif else begin

     if coupling eq 1 then begin

        coupling = 'DC'

        endif else begin

          print, 'Illegal coupling parameter'
          stop

        endelse

  endelse

; meas

if ~keyword_set(nomeas) then begin

  if testmode eq 'yes' then begin

      teststring='test'

   endif else begin

      teststring = ''

   endelse

cmd = dir+'measure\ni6115_shot.exe '+string(tstart)+' '+string(tlength)+' '+string(fsample)+$
' '+i2str(nchannel)+' '+i2str(gain)+' '+coupling+' '+dir+'data\'+i2str(shot)+'\'+i2str(shot)+'ch'+i2str(nchannel)+ ' '+teststring

spawn, cmd, resp

wait, 2
; errror handlig resp
print, 'Measurement done'
if (resp[0] ne 'Measurement configuration:') then begin
  errmess = resp[0];
  return
endif else begin
  errmess = ''
  return
endelse

endif else begin

errmess='No measurement made'

endelse


end