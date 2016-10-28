function read_segmented_images, tree, shotno, node, index, long=long, $
    all=all, bin=bin, transpose = transpose, status=status

n_im = query_seg_images( tree, shotno, node, status = status )
if n_im le 0 then return, -1

if n_elements(index) eq 0 then index = indgen(n_im)
if keyword_set(all) then index = indgen(n_im)

mdsopen, tree, shotno

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
  if keyword_Set(bin) then begin
    nx = nx/bin & ny=ny/bin
  end
  if keyword_Set(transpose) then begin & n0 = nx & nx = ny & ny = n0 & end
  
  frames = indgen(n_im)
  nframe = n_elements(index)
 
  if nframe eq 1 then begin
  
    time = long64((mdsvalue('GetSegmentLimits(' + node + ', $)', index))[0])
     
  end else begin
    
    n_images = mdsvalue('GetNumSegments('+node+')', status=status, /quiet)
    ok = where(index le (n_images-1) )
    if ok[0] eq -1 then return, -1
    index = index[ok]  & nframe = n_elements(index) 
    images = fltarr(nx, ny, nframe)
    time = fltarr(nframe)
    for i = 0, n_elements(index)-1 do begin
      idx = index[i]
      im0 = rebinb(mdsvalue('GetSegment('+ node +', $)', idx, status=status), bin)
      if keyword_Set(transpose) then im0 = transpose(im0)
      images[*,*,i] = im0
      time[i] = long64((mdsvalue('GetSegmentLimits(' + node + ', $)', idx))[0])
    end
  
  end

mdsclose

; Times are stored in us - return the time in seconds
 return, {images:images, time: time/1e6, nx:nx, ny:ny, n_images: nframe, indices: index}
  
end

