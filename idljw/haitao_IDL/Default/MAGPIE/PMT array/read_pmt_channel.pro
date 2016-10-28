function read_pmt_channel, shotno, channel, time=time

if n_params() ne 2 then stop, 'Please supply shot number and channel number'

mdsopen, 'magpie', shotno, status=status

if status then begin
   chan_name = '.PMT:CHANNEL_'+string(channel,'(i02)')
   y = mdsvalue(chan_name)
   time =  mdsvalue('dim_of('+chan_name+')')
   mdsclose, 'magpie', shotno
end else y=-1

return, y

end

