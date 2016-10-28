pro animate_seg_node, tree, shotno, node, min=min, max=max, wait=wait, bin=bin, scale=scale, _extra=_extra

default, wait, .1
default, bin, 1
default, scale, 1

n_im = query_seg_images( tree, shotno, node )
print,'Number of seg images:', n_im

mdsopen, tree, shotno

for i=0, n_im-1 do begin
  u = get_image_seg( node, i )
  tv, bytscl(scale*rebinb(u.images, bin), min=min, max=max, _extra=_extra)
  wait, wait
end

mdsclose

end

