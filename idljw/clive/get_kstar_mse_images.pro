function get_kstar_mse_images, shotno, nx, ny, n_im, tree=tree, snap=snap, cal=cal, time=time, camera=camera

  default, tree, 'mse'
  cam = get_kstar_camera_specifications( shotno, tree=tree )
  camera = cam.name
  
  case cam.name of &$
  'Pixelfly_USB': imagepath = 'pixelfly' &$
  'Pixelfly_QE': imagepath = 'pixelfly_qe' &$

  'Pike_F145B': imagepath = 'pike' &$
  else: imagepath = cam.name &$
  end 
 
  mdsopen, tree, shotno 
    if keyword_Set(cal) then begin
      im = mdsvalue('.mse:cal_images')
      time = mdsvalue("dim_of(.mse:cal_images,2)")
    end else if keyword_Set(snap) then begin
      im = mdsvalue(imagepath+':snapshot')
    end else begin
        im=mdsvalue('.pco_camera:images')
        time = mdsvalue('dim_of(.pco_camera:images,2)')

        doit=0
        if n_elements(im) gt 0 then if im eq '*' then doit=1
        if n_elements(im) eq 0 then doit=1

        if doit eq 1 then begin
            im = mdsvalue(imagepath+':images')

            time = mdsvalue("dim_of("+imagepath+':images'+",2)")
        endif else print,'got from pco_camera'
    end
  mdsclose

  sz = size(im)
  if sz[0] eq 3 then begin
    nx=sz[1] & ny=sz[2] & n_im=sz[3]
  end else begin
    nx=sz[1] & ny=sz[2] & n_im=1
  end
  

  if strupcase(camera) eq 'PIXELFLY_QE' then begin
    if n_im gt 1 then begin 
      for i=0, n_im-1 do im[*,*,i]=temporary(rotate(im[*,*,i],7)) 
    end else im=temporary(rotate(im,7)) 
  end

  return, float(im)
  
end
