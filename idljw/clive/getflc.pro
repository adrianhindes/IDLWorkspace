function getflc

flc={flc0:cgetdata('.DAQ.DATA:FLC_0'),flc1:cgetdata('.DAQ.DATA:FLC_1'),flc0ms:[mdsvalue('.MSE.FLC.FLC__00:MARK'),mdsvalue('.MSE.FLC.FLC__00:SPACE')],flc1ms:[mdsvalue('.MSE.FLC.FLC__01:MARK'),mdsvalue('.MSE.FLC.FLC__01:SPACE')],flc0i:mdsvalue('.MSE.FLC.FLC__00:INVERT'),flc1i:mdsvalue('.MSE.FLC.FLC__00:INVERT') ,edge:mdsvalue('.MSE.FLC_EDGE')}
return,flc
end
