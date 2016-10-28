function add_poisson_noise_image, s, seed

; s is the image
; s is assumed to be in photon counts
sz=size(s) & nx=sz[1] ;get the number of elements in s
snoise=fltarr(nx) ;set the noise image to an array with same number of elements as the original image
for i=0,nx-1 do begin &$
  snoise[i]=randomu(seed, poisson=(fix(s[i])),/double)
end

return, snoise
end
