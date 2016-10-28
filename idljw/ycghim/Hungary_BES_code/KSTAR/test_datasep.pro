pro test_datasep

bits=14
channel_masks = [255,0,0,0]

load_apd_data,/no_crc,/stream,data=ds,errormess=e,file='APD_meas',channel_mask=channel_masks,bits=bits,samplecount=90000
load_apd_data,/no_crc,data=d,errormess=e,file='APD_meas',channel_mask=channel_masks,bits=bits,samplecount=90000

for i=0,7 do print,total(ds[1,*]-d[1,*])
stop
end

