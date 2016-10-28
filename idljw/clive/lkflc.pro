pro doone,sh
forward_function getflc
cd,'~/mse_data'
spawn,'rmget1c mse_'+string(sh,format='(I0)')
stop
mdsopen,'mse',sh
flc=getflc()
freq=freqof(flc.flc1.t,flc.flc1.v,/plot,xr=[0,100],/ylog)
mdsclose
end
doone,7882
end
