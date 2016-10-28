pro all_apd_to_hdf5,shot,data_source=data_source,nocalibrate=nocalibrate,$
                datapath=datapath,local_datapath=local_datapath, scaling=scaling

signal_name_in=strarr(4,8)
for i=1,4 do begin
  for j=1,8 do begin
    signal_name_in[i-1,j-1]='BES-'+i2str(i)+'-'+i2str(j)
  endfor
endfor

    create_hdf5,shot,signal_name_in,data_source=data_source,nocalibrate=nocalibrate,$
                datapath=datapath,local_datapath=local_datapath, scaling=scaling

end