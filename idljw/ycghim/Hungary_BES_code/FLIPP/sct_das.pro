function real6to4, sixbytes
  ;Needed real number conversion from 6-byte pascal type to "4-byte" format IDL type
  sign        = (sixbytes(5) ge 128)
  sixbytes(5) = sixbytes(5)-128*sign
  exponent    = sixbytes(0)
  mantisa     = float(sixbytes(5))*2.^32 + float(sixbytes(4))*2.^24 + float(sixbytes(3))*2.^16 + $
                float(sixbytes(2))*2.^8  + float(sixbytes(1))
  real4       = (1.+mantisa/2.^39)*(-1.)^sign*2.^(exponent-129)
  return, real4
end

function word2, twobytes
  ;Needed word=2 bytes integer conversion to IDL integer
  integer2 = twobytes(1)*2.^8 + twobytes(0)
  return, integer2
end

function sct_das, shot_no, dev, chan, PATH = path, DECOMPRESS=decompress, CLEAN=clean, RATE=rate, SCT_TIME = sct_time

if not(keyword_set(path)) then  path = ''
cd,CURRENT=current_dir           ; & print,current_dir
shot_no_str = strcompress(string(shot_no),/remove_all)

if dev eq 'sct' then file = path+'ch'+strcompress(string(chan),/remove_all)+'0000.sct'
if dev eq 'tct' then begin
  board   = strcompress(string(chan / 10),/remove_all)
  channel = strcompress(string(chan - 10*(chan / 10)),/remove_all)
  if !version.os eq 'linux' then begin
    file = path+'B'+board+'C'+channel+'.SCT'
  endif else begin
    file = path+'b'+board+'c'+channel+'.sct'
  endelse
endif

if keyword_set(decompress) then begin
  openw,unit,path+'sct_DAS.bat', /get_lun
  if keyword_set(path) then begin
    printf,unit, strmid(path,0,2)
    printf,unit, 'cd '+path
  endif
  printf,unit,'del ch??0000.sct'
  printf,unit,'del b?c?.sct'
  stovky   = fix(shot_no/100)+1
  location = strcompress(GETENV('DAS_DAT')+string(stovky)+'\'+string(shot_no)+'.jpd', /remove_all)
  printf,unit, getenv('ARJ_DIR')+'arj.exe x -y ' + location + ' ' + 'ch??0000.sct'
  printf,unit, getenv('ARJ_DIR')+'arj.exe x -y ' + location + ' ' + 'b?c?.sct'
  close,unit   &   free_lun,unit
  spawn, path+'sct_DAS.bat'     ;  &  PRINT,path+'sct_DAS.bat'

  if path ne '' then print, "Data from Tectra1 & 2, #"+shot_no_str+' (files ch??0000.sct and b?c?.sct) are decompressed in the directory '+path $
    else print, "Data from Tectra1 & 2 - #"+shot_no_str+' (files ch??0000.sct and b?c?.sct) are decompressed in the current working directory ('+current_dir+')'
endif else begin
  if path ne '' then print, "Previously decompressed data in the directory "+path+" are used!!! SHOT NUMBER IS NOT VERIFIED!!!" $
    else print, "Previously decompressed data in the current working directory ("+current_dir+") are used!!! SHOT NUMBER IS NOT VERIFIED!!!"
endelse
print, "#"+shot_no_str+'    ', dev, chan           ;   &   stop

datain2 = {card:0B, xmin:0L, xmax:0L, xstep:make_array(6,/byte,value=0B), xun:make_array(7,/string,value=' '),$
                    ymin:0L, ymax:0L, ystep:make_array(6,/byte,value=0B), yun:make_array(7,/string,value=' '),$
                    coupl:0B, uplevel:make_array(2,/byte,value=0B), lolevel:make_array(2,/byte,value=0B),$
                    counter:make_array(2,/byte,value=0B), triggerch:0B,version:make_array(6,/string,value=' '),$
                    triggerfl:make_array(13,/string,value=' '), datatype:0B, triggersw:make_array(2,/byte,value=0B),$
                    busconf:0L, maxblocks:0L, masterclk:0B, segments:0L, trgsrcpattern:0L,$
                    upmask:make_array(2,/byte,value=0B), lomask:make_array(2,/byte,value=0B),$
                    unused:make_array(2,/byte,value=0B)}

err = 0
openr, sct_unit, file, /get_lun, error=err
if err ne 0 then $
  if keyword_set(decompress) then print, dev,chan,': NOT AN ACTIVE CHANNEL IN #'+strcompress(string(shot_no),/remove_all) $
  else if path ne '' then print, dev,chan,': DECOMPRESSED DATA ARE NOT AVAILABLE IN THE DIRECTORY '+path $
       else print,dev,chan,': DECOMPRESSED DATA ARE NOT AVAILABLE IN THE CURRENT WORKING DIRECTORY ('+current_dir+')' $
else begin
  readu, sct_unit, datain2
  close, sct_unit      &    free_lun, sct_unit

  datain = {card:0B, xmin:0L, xmax:0L, xstep:make_array(6,/byte,value=0B), xun:make_array(7,/string,value=' '),$
                     ymin:0L, ymax:0L, ystep:make_array(6,/byte,value=0B), yun:make_array(7,/string,value=' '),$
                     coupl:0B, uplevel:make_array(2,/byte,value=0B),lolevel:make_array(2,/byte,value=0B),$
                     counter:make_array(2,/byte,value=0B), triggerch:0B,version:make_array(6,/string,value=' '),$
                     triggerfl:make_array(13,/string,value=' '), datatype:0B,triggersw:make_array(2,/byte,value=0B),$
                     busconf:0L, maxblocks:0L, masterclk:0B, segments:0L, trgsrcpattern:0L,$
                     upmask:make_array(2,/byte,value=0B), lomask:make_array(2,/byte,value=0B),$
                     unused:make_array(2,/byte,value=0B),$
                     points:make_array(2,datain2.xmax-datain2.xmin+1,/byte,value=0B)}


  openr, sct_unit, file, /get_lun
  readu, sct_unit, datain
  close, sct_unit      &    free_lun, sct_unit

  data = {card:datain.card, xmin:datain.xmin, xmax:datain.xmax, xstep:real6to4(datain.xstep), xun:datain.xun(1:6),$
                            ymin:datain.ymin, ymax:datain.ymax, ystep:real6to4(datain.ystep), yun:datain.yun(1:6),$
                            coupl:datain.coupl, uplevel:word2(datain.uplevel), lolevel:word2(datain.lolevel),$
                            counter:word2(datain.counter), triggerch:datain.triggerch, version:datain.version(1:5),$
                            triggerfl:datain.triggerfl(1:12), datatype:datain.datatype, triggersw:word2(datain.triggersw),$
                            busconf:datain.busconf, maxblocks:datain.maxblocks, masterclk:datain.masterclk,$
                                                      segments:datain.segments, trgsrcpattern:datain.trgsrcpattern,$
                            upmask:word2(datain.upmask), lomask:word2(datain.lomask),$
                            unused:datain.unused, points:make_array(datain.xmax-datain.xmin+1,/float,value=0.)}


  ;print, 'Board type:'   , data.card
  print,'X-min:',data.xmin,  '    ;        X-max:',data.xmax,  '    ;        X-step:',data.xstep  ;&  print,'X-unit:',data.xun
  ;print,'Y-min:',data.ymin  &  print,'Y-max:',data.ymax  &  print,'Y-step:',data.ystep  &  print,'Y-unit:',data.yun
  ;print, 'Coupling type:', data.coupl &  print,'Up level:', data.uplevel         &  print,'Lo lovel:',data.lolevel
  ;print, 'Counter:',data.counter      &  print,'Trigger channel:',data.triggerch &  print,'Version number:',data.version
  ;print, 'Name of the trigger file for FFT normalization factor N:',data.triggerfl
  ;print, 'Data types:', data.datatype &  print,'Trigger switch:',data.triggersw
  ;print, 'Bus config:', data.busconf  &  print, 'Max blocks:', data.maxblocks    &  print, 'Master Clk:', data.masterclk
  ;print, 'Number of segments:', data.segments      &      print, 'Trg Src Pattern:', data.trgsrcpattern
  ;print, 'Up Mask:', data.upmask      &  print, 'Lo Mask:', data.lomask          &  print, 'Unused 2 bytes:', data.unused

  if dev eq 'tct' then begin
    data.points(*)=float(data.ystep)*(float(datain.points(0,*))+256.*float(datain.points(1,*))+float(data.ymin))
  ;  data = data.points
  endif
  if dev eq 'sct' then begin
    if keyword_set(sct_time) then begin
      ;;;;;;;;; print, '!!! WARNING: MIND THE POSSIBILITY OF A TIME SHIFT !!!' ;;;;;;;
	  sct_time_shift=0
	  if data.xstep eq 1.0e-6 then begin
	    if chan eq 17 then sct_time_shift=sct_time_shift-1
	    if chan eq 18 then sct_time_shift=sct_time_shift-1
	    if chan eq 27 then sct_time_shift=sct_time_shift-1
	    if chan eq 28 then sct_time_shift=sct_time_shift-1
	    if chan eq 37 then sct_time_shift=sct_time_shift-1
	    if chan eq 38 then sct_time_shift=sct_time_shift-1
	    if chan eq 47 then sct_time_shift=sct_time_shift-1
	    if chan eq 48 then sct_time_shift=sct_time_shift-1
	  endif
	  if data.xstep eq 2.0e-6 then begin
	    if chan le 19 then sct_time_shift=sct_time_shift+2
	  endif
	  if data.xstep le 1.0e-6 then begin
		if chan le 19 then sct_time_shift=sct_time_shift+3
	  endif
	  if data.xmin eq 2 then sct_time_shift=sct_time_shift+1
	  if data.xmin eq 6 then sct_time_shift=sct_time_shift-1
	  if (data.xmin eq 9) and (data.xstep ne 2.0e-7) then sct_time_shift=sct_time_shift-3
	  data.xmin =data.xmin + sct_time_shift
	  data.xmax =data.xmax + sct_time_shift
	endif else begin
      ;;;;;;;;; print, '!!! CAUTION: UNCORRECTLY SHIFTED IN TIME !!!' ;;;;;;;;;;;;;;
      if data.xmin eq 9 then begin
	    data.xmin =data.xmin -3
	    data.xmax =data.xmax -3
      endif
    endelse

    dataxmin = data.xmin        ; - data.xmin + 1
    sct_vs_tct_shift = 5        ; trigger is recognized 5 samples earlier on sct than on tct device
    							; (tested for 1 mus, 2 mus, and 5 mus sampling, channels 11, 21, 31, 41)
    if data.xmax lt n_elements(data.points) then dataxmax = data.xmax $       ; - data.xmin + 1
      else dataxmax = n_elements(data.points)
    data.points(dataxmin - 1 + sct_vs_tct_shift : dataxmax - 1) = $    ;dataxmin-1:dataxmax-1
      float(data.ystep)*(float(datain.points(0,0:dataxmax-dataxmin - sct_vs_tct_shift))    $
      + 256.*float(datain.points(1,0:dataxmax-dataxmin - sct_vs_tct_shift))+float(data.ymin))

    ;data.points(*) = $
    ;  float(data.ystep)*(float(datain.points(0,*))+256.*float(datain.points(1,*))+float(data.ymin))
  endif

  rate = data.xstep     ; rate [s]
  print,'rate = ',rate

  if keyword_set(clean) then begin
    spawn, 'del '+path+'sct_DAS.bat'
    spawn, 'del '+path+'ch??0000.sct'
    spawn, 'del '+path+'b?c?.sct'
  endif
endelse

return, data.points
end
