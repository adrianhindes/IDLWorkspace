pro contour_pmt_data, shotno


y = read_pmt_channel( shotno, 0, time=time)
sz = size(y, /dim)
data = fltarr(sz[0], 16)
data[*,0] = y
; read in the scale factors
scale = replicate(1,16)

for i = 1, 15 do data[*,i] = read_pmt_channel( shotno, i) * scale[i]

device, decompose = 0
loadct, 15
tvscl, rebin(data, 510, 160)

data_reduced = rebin(data, 5100, 16)
contour, data_reduced, n_level=20, /fill

end

