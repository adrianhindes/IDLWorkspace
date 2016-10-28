function response, nimpacts, nrad
  npts = 1000
  ; the array of steps along a given line
  line = (findgen(npts)-npts/2)/(npts/2)

  ; create the impact parameters for all measurement lines
  impact_param = findgen(nimpacts)/float(nimpacts)

  ; create the radial zones or pixels for the unknown object
  ; keep everything within the unit circle
  pix_rad = findgen(nrad)/float(nrad)

  response = fltarr(nimpacts, nrad)

  ; create the response matrix that represents the length of the ith line in the jth pixel
  for i = 0, nimpacts-1  do begin &$ ; cycle over the measurement lines

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

return, response/float(npts)

end