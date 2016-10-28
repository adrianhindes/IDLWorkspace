pro make_hdf5_KSTAR, shot
  fname=strtrim(shot,2)+'.h5'
  get_rawsignal,shot,'bes-1-1',t,d, /nocalib
  n=n_elements(t)
  data=dblarr(4,8,n)
  ch_name=strarr(4,8) 
  for i=1,4 do begin
    for j=1,8 do begin
      channel='bes-'+strtrim(i,2)+'-'+strtrim(j,2)
      ch_name[i,j]=channel
      get_rawsignal,shot,channel,t,d
      data[i-1,j-1,*]=d
    endfor
  endfor
 
  struct={name:shot,time:t,data:d,ch_name:ch_name,comment:'RAW data of BES'}
  fileid=h5f_create(fname)
  datatypeID=h5t_idl_create(struct)
  dataspaceID=h5s_create_simple(1)
  datasetid=h5d_create(fileid,shot,datatypeid,dataspaceid)
  h5d_write,datasetid,struct
  h5f_close,fileid
end