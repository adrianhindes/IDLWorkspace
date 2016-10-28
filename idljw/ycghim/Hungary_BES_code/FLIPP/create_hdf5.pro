pro create_hdf5,shot,signal_name_in,data_source=data_source,nocalibrate=nocalibrate,$
                datapath=datapath,local_datapath=local_datapath, scaling=scaling
                
                
; ************* create_hdf5.pro ********************** D.Refy ********10.02.2014
; This routine converts data read by get_rawsignal.pro to hdf5 format. 
; 
; parameters:
;  shot: shot number
;  signal_name_in: [<data source>/]<signal name> or numeric channel number array (see chan_prefiox and chan_postfix)
;       <data_source> is any of the names returned in data_names. This overrides the
;  data_source:  see get_rawsignal.pro
;  /scaling: if the switch is on, get_rawsignal.pro returns scaled APD data (volts), if it is off it returns integer (digit). default: on
;  /nocalibrate: do not calibrate signal (e.g. relative calibaration of Li channels)
; OUTPUT:
;  data saved into file in HDF5 format.
;*******************************************************************************

default,data_source,fix(local_default('data_source'))
default,datapath,local_default('datapath')
default,local_datapath,local_default('local_datapath')
default,scaling,0

   file = dir_f_name(local_datapath,i2str(shot)+'_data.h5') 
   fid = H5F_CREATE(file) 

for i=0, n_elements(signal_name_in)-1 do begin

   get_rawsignal,shot,signal_name_in[i],time, data, data_source=data_source,nocalibrate=nocalibrate,$
                datapath=datapath,local_datapath=local_datapath, scaling=scaling
    
;    mod_sig = signal_name_in[i]
;    signal_in = signal_name_in[i]
;    find_string=['/',':','<']
;    for j=0,n_elements(find_string)-1 do begin
;        i=0
;        while (i NE -1) do begin
;          i=strpos(signal_in,find_string[j],i)
;          IF (i NE -1) THEN BEGIN
;            if not defined(ind) then begin
;              ind=i
;            endif else begin
;              ind=[ind,i]
;            endelse      
;            i=i+1
;          endif
;        endwhile
;    endfor
;    ind=ind[sort(ind)]
;    if (ind[0] ge 0) then begin
;      mod_sig_save = mod_sig
;      mod_sig = ''
;      for i=0, n_elements(ind) do begin
;        ind1 = [-1, ind, strlen(signal_in)]
;        mod_sig = mod_sig+strmid(mod_sig_save,ind1[i]+1,(ind1[i+1]-ind1[i])-1)
;      endfor
;    endif
    
   ;file = dir_f_name(local_datapath,i2str(shot)+'_'+mod_sig+'.h5') 
   ;fid = H5F_CREATE(file)     
        
   ;; get data type and space, needed to create the dataset 
   datatype_id = H5T_IDL_CREATE(data) 
   dataspace_id = H5S_CREATE_SIMPLE(size(data,/DIMENSIONS)) 
 
   ;; create dataset in the output file 
   dataset_id = H5D_CREATE(fid,signal_name_in[i],datatype_id,dataspace_id)
   
   ;; write data to dataset 
   H5D_WRITE,dataset_id,data 
   
   ;; close all open identifiers 
   H5D_CLOSE,dataset_id   
   H5S_CLOSE,dataspace_id 
   H5T_CLOSE,datatype_id

   if i EQ 0 then begin
   timetype_id = H5T_IDL_CREATE(time) 
   timespace_id = H5S_CREATE_SIMPLE(size(time,/DIMENSIONS)) 
   timeset_id = H5D_CREATE(fid,'Sample time',timetype_id,timespace_id)  
   H5D_WRITE,timeset_id,time 
   H5D_CLOSE,timeset_id   
   H5S_CLOSE,timespace_id 
   H5T_CLOSE,timetype_id
   endif
   
endfor
 
   H5F_CLOSE,fid 
    
   print, 'HDF5 output created at: '+file
 
END 
