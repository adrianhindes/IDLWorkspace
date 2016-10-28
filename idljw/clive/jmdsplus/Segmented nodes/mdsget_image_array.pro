pro mdsget_image_array, tree, shotno, node, start=start, finish=finish

  mdsopen, tree, shotno, status=status
   if not status then begin
    print, 'cannot open '+tree+' at shot '+strtrim(shotno,2)
    return
  end

  max_images = query_seg_images( tree, shotno, node )
  u = get_image_seg(node, 0)
  default, start, 0
  default, finish, max_images-1
  type = type(u.image)

  case type of
  images = 
  
  if n_images ne -1 then begin
   
  sz = size(images)
  if sz[0] eq 2 then n_im = 1 else if sz[0] eq 3 then n_im=sz[3] else stop,'Images are incorrect size'
  
  mdsclose, tree, shotno

return, {image:images, time: time, nx:sz[1], ny:sz[2], n_im: n_im}

end

