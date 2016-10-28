function get_image_seg, node, index
;+
; retrieve image from a node segment
; assumes one image per segment
; timestamps must be greater than 0.  Supplied timestamps are relative to t0=0
; before storage, timestamps are converted to microseconds with an arbitrary offset of 1000s to ensure positivity
; timestamp = long(time*1e6 + 1e9)
;
;-

  default, index, 0
  images = mdsvalue('GetSegment('+ node +', $)', index[0], status=status)

  if not status then return,-1

  sz = size(images)
  case sz[0] of
  0: return, -1
  1: return, -1
  2: n_im = 1
  3: n_im = sz[3]
  else: stop
  end

  nx = sz[1] & ny=sz[2]
  frames = indgen(n_im)
  nframe = n_elements(index)

  if nframe eq 1 then begin

    timestamps = mdsvalue('GetSegmentLimits(' + node + ', $)', index)
    time = float(timestamps[0])/1e6

  end else begin

    images = fltarr(nx, ny, nframe)
    time = fltarr(nframe)
    for i = 0, n_elements(index)-1 do begin
      idx = index[i]
      images[*,*,i] = mdsvalue('GetSegment('+ node +', $)', idx, status=status)
      timestamps = long64(mdsvalue('GetSegmentLimits(' + node + ', $)', idx))
      time[i] = float(timestamps[0])/1e6 ;convert to seconds
    end
  end

 return, {images:images, time: time, nx:nx, ny:ny, n_images: nframe}


end
