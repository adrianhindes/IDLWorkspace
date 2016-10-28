pro put_image_array, tree, shotno, node, images, times, clean=clean, minpath = minpath
  
  mdstcl,'edit '+tree+' /shot='+strtrim(shotno, 2), status=status
  
  if not status then begin
    print, 'cannot open '+tree+' at shot '+strtrim(shotno,2)
    return
  end
  
; make the node if it does not exist
  if keyword_set(minpath) then begin
    find_or_create_node, minpath
    find_or_create_node, node
  end else begin
    find_or_create_node, node
  end
  
  sz = size(images)
  if sz[0] eq 2 then n_im = 1 else if sz[0] eq 3 then n_im=sz[3] else stop,'Images are incorrect size'
  n_images=n_elements(images(0,0,*))
  for i  = 0, n_images-1 do put_image_seg, node, images[*,*,i], times[i]
  
  mdstcl,'write'
  mdsclose, tree, shotno

if keyword_set(clean) then mdsclean, tree, shotno

end

