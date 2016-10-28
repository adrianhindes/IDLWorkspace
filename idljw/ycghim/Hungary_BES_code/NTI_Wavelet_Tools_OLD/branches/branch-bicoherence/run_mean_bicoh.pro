pro run_mean_bicoh,bmeans=bmeans,bdevs=bdevs

sigma = 0.1*(dindgen(10)+1)
bmeans = 0*dindgen(10)
bdevs = 0*dindgen(10)

for i=0L,9 do begin
 mean_bicoh,sigma(i),500,hann=hann,deviation=deviation,bmean=bmean,bdev=bdev
 bmeans(i) = bmean
 bdevs(i) = bdev
endfor

end
