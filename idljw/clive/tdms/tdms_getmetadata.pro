pro TDMS_getMetaData,Lun,Segment_counter,leadin_segment,MetaData_segment,Properties_names,Properties_values,MetaData_global, DEBUG=DEBUG

OUTPUT_FLAG=0
IF KEYWORD_SET(DEBUG) THEN IF (DEBUG eq 1) then OUTPUT_FLAG=1

;- Absolute Beginning of MetaData Section for current segment
POINT_LUN,(-1*lun),Metadata_start_pointer
;- Absolute Raw Data Start(absolute): Metadata_start_pointer(absolute)+leadin_segment.RAW_DATA_OFFSET(relative to the end current leadin)

Absolute_RawData_Start_pointer = Metadata_start_pointer+leadin_segment.RAW_DATA_OFFSET

;- temporary container for current Object RawData Size
MetaDataObject_RAW_size= 0

;- Initialize MetaData_segment structure to a empty string 
MetaData_segment = ''
  
  n_new_obj_in_segment= ULONG(0)
  READU,lun,n_new_obj_in_segment
  IF OUTPUT_FLAG THEN print,'Number of new objects in this segment: ',n_new_obj_in_segment ;- Number of new objects in this segment

leadin_segment.n_new_obj_in_segment=n_new_obj_in_segment ;- aggregate this value to LeadIn
  
  ;-First element = number of objects
  
  for k=long64(0),n_new_obj_in_segment-1 do begin
    ;-Segment objects
;     stop
    TDMS_getMetaDataObject,lun,MetaData,prop_names,prop_values,Debug=Debug
    MetaData = CREATE_STRUCT( MetaData,'Segment_id',Segment_counter)
    MetaData = CREATE_STRUCT( MetaData,'Channel_id',k)

       ;- if (raw_data_index eq 0ul) the metadata portion is the same as the last definition of the same channel???
       if (MetaData.raw_data_index eq 0ul) then begin
        MetaData=MetaData_global(max(where(STRMATCH(MetaData_global.OBJECT_PATH_STRING,MetaData.OBJECT_PATH_STRING))))
        MetaData.SEGMENT_ID=Segment_counter
        MetaData.Channel_id = k
       endif

;-- here we need a check for (MetaData.raw_data_index eq 0ul) and to assign to previous structure!


    ;- check if object contains actual RawData, then calculate its RawData section length
;    if (MetaData.raw_data_index ne 4294967295ul) AND (MetaData.raw_data_index ne 0ul) then begin
     if (MetaData.raw_data_index ne 4294967295ul) then begin
      MetaData.RAW_DATA_DESCRIPTOR.DATA_START_RAW = Absolute_RawData_Start_pointer
      
      MetaDataObject_RAW_size=MetaData.RAW_DATA_DESCRIPTOR.TOTAL_SIZE ;- redundant for non string data, but I like it anyway.
       
       ;- String Data contain directly their Total_length in byte
      
;      MetaDataObject_RAW_size=MetaData.RAW_DATA_DESCRIPTOR.Data_type eq 32?$
;                              MetaData.RAW_DATA_DESCRIPTOR.TOTAL_SIZE:$ ;- String size
;                              TDMS_getDataTypeSize(MetaData.RAW_DATA_DESCRIPTOR.Data_type)*MetaData.RAW_DATA_DESCRIPTOR.ARRAY_DIMENSION*MetaData.RAW_DATA_DESCRIPTOR.N_VALUES
      ;- this is the start of subsequent RawData block
;      ;- it will updated only if there are data or raw_data_index ne 2^64
;      if (MetaData.raw_data_index ne 4294967295ul) then 
      Absolute_RawData_Start_pointer = Absolute_RawData_Start_pointer+MetaDataObject_RAW_size
      IF OUTPUT_FLAG THEN print,'MetaDataObject_RAW_size : ',MetaData.RAW_DATA_DESCRIPTOR.TOTAL_SIZE
    endif
    
    if size(MetaData_segment,/TYPE) ne 7 $ ;- assign data to the data structure
      then begin
;          MetaData_segment = CREATE_STRUCT(MetaData_segment,'Meta_object_'+stringer(k),MetaData_str)
      MetaData_segment(k) = MetaData
      Properties_names  = CREATE_STRUCT(Properties_names,'Prop_names_object_'+stringer(k),prop_names) ;- if it is a string, initialize is as structure with the first object
      Properties_values = CREATE_STRUCT(Properties_values,'Prop_values_object_'+stringer(k),prop_values) ;- if it is a string, initialize is as structure with the first object
      endif else begin ;- initialize new data structure
      MetaData_segment = Replicate(MetaData,n_new_obj_in_segment)
      Properties_names  = CREATE_STRUCT('Prop_names_object_'+stringer(k),prop_names) ;- if it is a string, initialize is as structure with the first object
      Properties_values = CREATE_STRUCT('Prop_values_object_'+stringer(k),prop_values) ;- if it is a string, initialize is as structure with the first object
;      MetaData_segment = CREATE_STRUCT('Meta_object_'+stringer(k),MetaData_str) ;- if it is a string, initialize is as structure with the first object
      endelse
  endfor


end
