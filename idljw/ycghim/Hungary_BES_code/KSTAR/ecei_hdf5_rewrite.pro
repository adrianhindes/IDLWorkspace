pro ecei_hdf5_rewrite, shot
dir='~/ECEI/'
diags=['LFS','HFS','GFS']
spawn,'ls',ls
spawn,'cd '+dir
command='read_hdf5_attr('+strtrim(shot,2)+'); exit;'
spawn,'matlab -nodisplay -r "'+command+'"'
spawn,'cd '+ls

lofreq=dblarr(3)
dpfreq=dblarr(3)
lensfocus=dblarr(3)
lenszoom=dblarr(3)
zoomcodev=dblarr(3)
rfchannel=dblarr(3)
channel=strarr(3)
samplerate=dblarr(3)
samplenum=dblarr(3)
tfcurrent=dblarr(3)
starttime=dblarr(2)
eceidir='/home/mlampert/ECEI/'+string(shot,format='(I6.6)')+'/'
for i=0,2 do begin
  file = eceidir+'ECEI.'+string(shot, format='(I6.6)')+'.'+diags[i]+'.info'
  OPENR, lun, file, /GET_LUN
  READF, lun, a
  tfcurrent[i]=a
  READF, lun, a
  samplerate=a*1e3
  READF, lun, a,b
  starttime[0]=a
  starttime[1]=b
  READF, lun, a
  lofreq[i]=a
  READF, lun, a
  dpfreq[i]=a
  READF, lun, a
  lensfocus[i]=a
  READF, lun, a
  lenszoom[i]=a
  READF, lun, a
  zoomcodev[i]=a
  READF, lun, a
  rfchannel[i]=a
  CLOSE, lun
  FREE_LUN, lun
endfor


ind=intarr(3,6)
ind[0,*]=[60,61,62,63,64,65]
ind[1,*]=[66,67,68,69,70,71]
ind[2,*]=[125,127,128,129,130,131]

channel=['l','h','g']

attname=['SampleRate','SampleNum','TFcurrent','LoFreq','DpFreq','LensFocus','LensZoom','RFchannel','ZoomCodeV']

samplenum=(starttime[1]-starttime[0])*samplerate
datadir='/data/KSTAR/APDCAM/'+strtrim(shot,2)
t=file_test(datadir)
if not t then return
for c=0,2 do begin
  attribute=[samplerate, samplenum,  tfcurrent[c],  lofreq[c],  dpfreq[c],  lensfocus[c],  lenszoom[c],  RFchannel[c],  ZoomCodeV[c]]
  print, attribute
  new_filename=dir_f_name(datadir,"ecei-kstar-"+channel[c]+"fs."+string(shot, format='(I8.8)')+'.hdf5')
  new_file_id=h5f_create(new_filename)
  new_group_id=h5g_create(new_file_id, '/ECEI')
  
  atttype_id=h5t_idl_create(starttime)
  attspace_id = h5s_create_simple(2)
  att_id=h5a_create(new_group_id,'StartTime',atttype_id,attspace_id)
  h5a_write, att_id, starttime
  h5a_close, att_id

  for i=0, n_elements(attname)-1 do begin
    attspace_id = h5s_create_scalar()
    atttype_id=h5t_idl_create(attribute[i])
    att_id=h5a_create(new_group_id,attname[i],atttype_id,attspace_id)
    h5a_write, att_id, attribute[i]
    h5a_close, att_id
  endfor
  
  for i=0,5 do begin
    filename=dir_f_name(eceidir,"SHOT."+string(shot,format='(I6.6)')+".acq132_"+string(ind[c,i],format='(I3.3)')+".h5")
    file_id=h5f_open(filename)
    for j=i*4+1,(i+1)*4 do begin
      for k=1,8 do begin
        groupname="ECEI/ECEI_"+strupcase(channel[c])+string(j,format='(I2.2)')+'0'+strtrim(k,2)
        group_id=h5g_open(file_id,groupname)
        attr_calfac = H5A_OPEN_NAME(group_id,'CalFactor')
        calfac=h5a_read(attr_calfac)
        attr_caloffset = H5A_OPEN_NAME(group_id,'CalOffset')
        caloffset=h5a_read(attr_caloffset)
        dataset_id = H5D_OPEN(file_id, groupname+'/Voltage')
        data=h5d_read(dataset_id)
        
        ds = h5d_get_space(dataset_id)      
        datatype_id=h5t_idl_create(data)
        datagroup_id=h5g_create(new_file_id,groupname)
        
        attspace_id=h5a_get_space(attr_calfac)
        atttype_id=h5t_idl_create(calfac)
        att_id=h5a_create(datagroup_id,'CalFactor',atttype_id,attspace_id)
        h5a_write, att_id, calfac
        h5a_close, att_id
        attspace_id=h5a_get_space(attr_caloffset)
        atttype_id=h5t_idl_create(caloffset)      
        att_id=h5a_create(datagroup_id,'CalOffset',atttype_id,attspace_id)
        h5a_write, att_id, caloffset
        h5a_close, att_id
        data_id=h5d_create(new_file_id,groupname+'/Voltage',datatype_id,ds,CHUNK_DIMENSIONS=n_elements(data))
        h5d_write, data_id,data
        
        h5d_close, data_id
        h5g_close, datagroup_id
        h5t_close, datatype_id
        h5a_close, attr_calfac
        h5a_close, attr_caloffset
        h5g_close, group_id
        h5d_close, dataset_id
      endfor
    endfor 
    h5f_close, file_id
 endfor
  h5g_close, new_group_id
  h5f_close, new_file_id
endfor

end
