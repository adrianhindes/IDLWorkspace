;________________________________________________________________
function get_kstar_camera_specifications, shotno, tree=tree
default, tree, 'mse'

mdsopen, tree, shotno
camname = mdsvalue('.config.camera_selct')
mdsclose
camname = (strsplit(camname,"'",/extr))[0]

; coordinates of fiducial marks are as given in KSTAR Fiducials powerpoint document

case strupcase(camname) of 
  'SENSICAM':  cam = {name: camname, $
                      origin: [-1090, 2617., 305.]/1000., $
                      nx:1376, $
                      ny: 1040, $
                      camera_pix_size: 6.45e-6}
  'PIXELFLY QE':  cam = {name: 'Pixelfly_QE', $   ; change the name here to make it compatible with tree node names
                      origin: [-1198.3, 2657.7, 322]/1000., $
                      nx:1392, $
                      ny: 1024, $
                      camera_pix_size: 6.45e-6} 
  'PIXELFLY USB':  cam = {name: 'Pixelfly_USB', $   ; change the name here to make it compatible with tree node names
                      origin: [-1198.3, 2657.7, 322]/1000., $
                      nx:1392, $
                      ny: 1024, $
                      camera_pix_size: 6.45e-6} 
  'PIKE F145B':  cam = {name: 'Pike_F145B', $   ; change the name here to make it compatible with tree node names
                      origin: [-1198.3, 2657.7, 322]/1000., $
                      nx:1388, $
                      ny: 1038, $
                      camera_pix_size: 6.45e-6} 
  else: stop,'Unrecognized camera'
end

;origin: [2914, 90, 322]/1000.,  coords wrt centreline of viewport as provided by Mark
;t=112.5*!dtor
;print,cos(t)*2914.-sin(t)*90                      
;print,sin(t)*2914.+cos(t)*90                      

return, cam

end
