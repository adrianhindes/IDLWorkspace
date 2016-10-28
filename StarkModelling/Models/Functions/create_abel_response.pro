pro create_Abel_response

path = 'C:\Users\adria\IDLWorkspace85\Default\StarkModelling\ForwardModel'
response_m_size = 200 ;in order to invert response matrix, dimensions must be square

  npts = 100000
  ; the array of steps along a given line
  line = (findgen(npts)-npts/2)/(npts/2)

  ; create the impact parameters for all measurement lines
  nlines = response_m_size
  impact_param = findgen(nlines)/float(nlines)

  ; create the radial zones or pixels for the unknown object
  ; keep everything within the unit circle
  nrad = response_m_size
  pix_rad = findgen(nrad)/float(nrad)

  response = fltarr(nlines, nrad)

  ; create the response matrix that represents the length of the ith line in the jth pixel
  for i = 0, nlines-1  do begin &$ ; cycle over the measurement lines

    line_radii = sqrt(impact_param[i]^2 + line^2)    &$ ; the radius of all points along the measurement chord

    for j = 1, nrad do begin  &$  ; cycle through radial zones

    if j eq nrad then begin
      intersect = where(line_radii gt pix_rad[j-1] and line_radii le 1, n_intersect)  &$     
    end else begin
      intersect = where(line_radii gt pix_rad[j-1] and line_radii lt pix_rad[j], n_intersect)  &$
    end
      ;^if point is between the radial zone of interest and the previous one, count it and add it to response
    response[i,j-1] = n_intersect  &$

  end  &$
end
response = response/float(npts)

;plot,response


width = 0.4
period = 0.2

function transform, obj, array_size, r=r
  
  response_m_size = array_size ;in order to invert response matrix, dimensions must be square
  npts = 10000
  ; the array of steps along a given line
  line = (findgen(npts)-npts/2)/(npts/2)

  ; create the impact parameters for all measurement lines
  nlines = response_m_size
  impact_param = findgen(nlines)/float(nlines)

  ; create the radial zones or pixels for the unknown object
  ; keep everything within the unit circle
  nrad = response_m_size
  pix_rad = findgen(nrad)/float(nrad)

  response = fltarr(nlines, nrad)

  ; create the response matrix that represents the length of the ith line in the jth pixel
  for i = 0, nlines-1  do begin &$ ; cycle over the measurement lines

    line_radii = sqrt(impact_param[i]^2 + line^2)    &$ ; the radius of all points along the measurement chord

    for j = 1, nrad do begin  &$  ; cycle through radial zones

    if j eq nrad then begin
    intersect = where(line_radii gt pix_rad[j-1] and line_radii le 1, n_intersect)  &$
    end else begin
    intersect = where(line_radii gt pix_rad[j-1] and line_radii lt pix_rad[j], n_intersect)  &$
    end
  ;^if point is between the radial zone of interest and the previous one, count it and add it to response
  response[i,j-1] = n_intersect  &$

  end  &$
end

response = response/float(npts) ;Use to do forward transform

inverted_response = invert(response,status) ;Use to do inverse transform

if keyword_set(r) then begin ;if doing reverse transform then do inversion
  
return, obj ## inverted_response

end else begin ;otherwise assume doing forward transform
  
return, obj ## response

end

end
wave_object = abs(sin(pix_rad/float(period)))



projection_gauss = gauss_object ## response

title='Projection of Gauss Object'
p = plot(projection_gauss,xtitle='Impact Parameter',ytitle='Brightness',title=title)
p.save, path+title+'.png',/transp


projection_wave = wave_object ## response

title = 'Projection of Wave Object'
p = plot(projection_wave,xtitle='Impact Parameter',ytitle='Brightness',title=title)
p.save, path+title+'.png',/transp


inverted_response = invert(response,status)

re_object_gauss = projection_gauss ## inverted_response
re_object_wave = projection_wave ## inverted_response

stop 
title='Gauss Object and Reconstruction'
pg = plot(pix_rad,gauss_object,'3',xtitle='Radial Zone',ytitle='Emissivity',title=title,name='Original')
pg2 = plot(pix_rad,re_object_gauss,'--r3',overplot=pg,name='Reconstruction')
l = legend(target=[pg,pg2],vertical_alignment=0)
pg2.save,path+title+'.png',/transp

title = 'Wave Object and Reconstruction'
pw = plot(pix_rad,wave_object,'3',xtitle='Radial Zone',ytitle='Emissivity',title=title,name='Original')
pw2 = plot(pix_rad,re_object_wave,'--r3',overplot=pw,name='Reconstruction')
l = legend(target=[pw,pw2],vertical_alignment=0)
pw2.save,path+title+'.png',/transp

;identityy = invert(response) ## response
;indentity_accuracy = (abs((total(identityy))- response_m_size))/response_m_size
;print,indentity_accuracy
;print,status
;Above lines written to check accuracy of response inversion
end