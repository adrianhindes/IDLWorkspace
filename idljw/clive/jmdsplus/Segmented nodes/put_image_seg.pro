pro put_image_seg, node, image, time
;+ 
; put image to a node segment
; NOTE: This is assumed to be part of a sequence of writes to the node and assumes one image per segment
;
; time must be given in units of seconds
;
;-
  if n_elements(time) eq 0 then tm = 0 else tm = time
  dummy = mdsvalue( 'PutRow('+node+',1,$,$)',ulong64(tm*1e6), image, status=status )
  if not status then print,"Error executing mdsvalue( 'PutRow('+node+',1,$,$)',ulong64(time*1e6), image, status=status )"

end
  