function read_MSE_2013_images, shotno, time, i0=i0, timebase = timebase, $
        status=status, brightness=brightness

; get the data  
  s = read_mse_process_settings(shotno)

; get the timebase
  tb = read_segmented_images_timebase(s.tree, shotno, '.demod:theta', status=status)
  if not status then begin
    print,'There are no demodulated images'
    return, -1
  end
; this is the true timebase - corrected for skip errors etc
  tb = correct_timebase(tb, s)

  if keyword_Set(timebase) then return, tb

; select the index range
  case n_elements(time) of
  
    0:
    1:  begin
          index = ((where(tb ge time))[0])>0
        end
    2:  begin
          index = where(tb ge time[0] and tb le time[1])
        end
    else:
  
  end
  
  if keyword_Set(i0) or keyword_Set(brightness) then begin
    
    print,'Reading MSE_2013 intensity images ...'
    data = read_segmented_images(s.tree, shotno, '.demod:i0', index )
  
  end else begin
    
    data = read_segmented_images(s.tree, shotno, '.demod:theta0', index, status=status )
    print,'Reading MSE_2013 theta images ...'
  
    if not status then begin
      Print, 'Wait while LUT is applied to demod images ...'
      MSE_apply_LUT, shotno
      data = read_segmented_images(s.tree, shotno, '.demod:theta0', index, status=status )
    end
    
  end
  
  ; correct the timebase for offsets
  tb = data.time
  data.time = correct_timebase(tb, s)
    
  return, data
  
end
  
