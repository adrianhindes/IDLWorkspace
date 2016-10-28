function read_segmented_images_timebase, tree, shotno, node, status=status

nframe = query_seg_images( tree, shotno, node, status=status )
if nframe le 0 then return, -1

index = indgen(nframe)
time = fltarr(nframe)

mdsopen, tree, shotno
 
  if nframe eq 1 then begin
  
    time = long64((mdsvalue('GetSegmentLimits(' + node + ', $)', index, status=status))[0])
     
  end else begin
    
    for i = 0, n_elements(index)-1 do time[i] = long64((mdsvalue('GetSegmentLimits(' + node + ', $)', index[i]))[0])
  
  end

mdsclose


; Times are stored in us - return the time in seconds
 return, time/1e6

end

