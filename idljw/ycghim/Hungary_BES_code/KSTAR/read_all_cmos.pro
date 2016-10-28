function read_all_cmos,shot, bit8=bit8

datapath = '~/Measurement/CMOS_130801/'
spawn,'ls '+datapath+i2str(shot),ls

n_img = n_elements(ls)

for i=0,n_img-1 do begin
  print,i,n_img
  openr,unit,datapath+i2str(shot)+'/'+ls[i],/get_lun,error=e
  if (e ne 0) then begin
  print,'Error reading file.'
  stop
  return,0
endif  
if keyword_set(bit8) then begin
   d=assoc(unit,bytarr(1312,1082))
endif else begin
   d=assoc(unit,intarr(1312,1082))
endelse
im = d[0]
if (i eq 0) then begin
  imgs = intarr(n_img,(size(im))[1],(size(im))[2])
endif
imgs[i,*,*] = im
tvscl,im  
close,unit & free_lun,unit
endfor

return,imgs
end
