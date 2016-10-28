
;_____________________________________________________________________________
pro clean_data_cube, data, nmedian=nmedian, nstddev=nstddev
;+
; median filter the 3d data cube in the time direction
; Only change those pixels that deviate significantly from the background level
;-
sz=size(data) ; assumes time is the 3rd direction
n_im = sz[3]
nx = sz[1]
ny = sz[2]

for i=0, nx-1 do begin          ; filter one time series vector at a time
  for j = 0, ny-1 do begin
    data[i,j,*] = adaptive_median( reform(data[i,j,*]), nmedian=nmedian, nstddev=nstddev )
  end
  print,'Column '+strtrim(i,2)+' out of '+strtrim(nx,2)
end

end


