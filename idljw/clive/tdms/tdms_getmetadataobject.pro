pro TDMS_getMetaDataObject,Lun,MetaData,prop_names,prop_values,debug=debug

OUTPUT_FLAG=0
IF KEYWORD_SET(DEBUG) THEN IF (DEBUG eq 1) then OUTPUT_FLAG=1

Is_Root = 0

  object_path_string_len=ULONG(0)  ;- Path lenght, Unsigned LONG 32 bit / 4 bytes
   READU,Lun,object_path_string_len
   IF OUTPUT_FLAG THEN print,'Lenght objects in this segment',object_path_string_len

;- Variable length, see previous field
  if (object_path_string_len eq 0) then STOP
  object_path_string=whitespaces_string(object_path_string_len)  ;- Actual Path string, with lenght object_path_string_len
   READU,Lun,object_path_string
   IF OUTPUT_FLAG THEN print,'Actual Path string : ',object_path_string

if (N_ELEMENTS(byte(object_path_string)) eq 1) then $
  Is_Root=(byte(object_path_string)) eq 47?1:0  $
else Is_Root=0


;  raw_data_index=BYTARR(4)  ;- Raw data index ("FF FF FF FF" means there is no raw data assigned to the object)
  raw_data_index=ULONG(4)  ;- Raw data index ("FF FF FF FF" or 2^32 means there is no raw data assigned to the object)
   READU,Lun,raw_data_index
   IF OUTPUT_FLAG THEN print,'Raw data index : ',raw_data_index

;- Fake raw_data_desc to save the output structure format
;- Let's do check raw_data_index after to see if there are actual data
   raw_data_desc = { $
        Data_type       : ULONG(0),$
        Array_dimension : ULONG(0),$
        n_values        : ULONG64(0) ,$
        data_start_raw  : ULONG64(0ul), $
        total_size      : ULONG64(0) , $ ;- redundant for non string data, but I like it anyway.
      ;-- Not in TDMS structure, control parameter!        
        replicate_previous_segment : byte(0) , $ ;- flag storing if the actual field has a Raw data index: they store an unsigned 32-bit integer (0x0000000) in case, instead the raw_data_desc structure 
        no_raw_data                : byte(0) $ ;- flag storing if the actual field has a Raw data in this segment: they store a unsigned 32-bit integer (0xFFFFFFFF) in case, instead the raw_data_desc structure
      }


 ;- START RAW Data Descriptor
;raw_data_index : all bits non zero = 0xFF FF FF FF / 4294967295ul > No raw data associated with this object.
;raw_data_index : all bits are zero = 0x00 00 00 00 > the object list matches exactly the previous list. 
;MASK_NULL_raw_data_index intermediate values are a new index! Raw Data are coming...
 
;IF OUTPUT_FLAG THEN print,(raw_data_index ne 4294967295ul) AND (raw_data_index ne 0ul) and Is_Root eq 0
 if (raw_data_index ne 4294967295ul) AND (raw_data_index ne 0ul) and Is_Root eq 0 then begin

;  Length_index = raw_data_index

  Data_type=ULONG(0)  ;- Data type (tdsDataType enum, stored as 32-bit integer) / 4 bytes
   READU,Lun,Data_type
   IF OUTPUT_FLAG THEN print,'Data type numeric/TDMS : ',Data_type,' / ',TDMS_getDataTypeName(Data_type),' / Data size (bytes):',TDMS_getDataTypeSize(Data_type)

  Array_dimension=ULONG(0)  ;- Array dimension (unsigned 32-bit integer)  (right now 1 is the only valid value) / 4 bytes
   READU,Lun,Array_dimension
   IF OUTPUT_FLAG THEN print,'Array dimension ',Array_dimension

  n_values=ULONG64(0)  ;- Number of values (unsigned 64-bit integer) / 8 bytes
   READU,Lun,n_values
   IF OUTPUT_FLAG THEN print,'Number of values ',n_values
   
   ;- aggregating all the raw data description for this object
    raw_data_desc.Data_type       = Data_type
    raw_data_desc.Array_dimension = Array_dimension
    raw_data_desc.n_values        = n_values
    ;- Data_type.data_start_raw  = it is defined in the calling routine, combining data from LeadIn

   if Data_type eq 32 then begin ;- 32 = TDMS data type for string / Time Stamp is read as a string but it isn't a string in TDMS!
    ;- Read only for strings!!!
    Total_size=ULONG64(0)  ;- Total size in bytes (unsigned 64-bit integer) (only stored for variable length data types, e.g. strings) / 8 bytes
     READU,Lun,Total_size
     IF OUTPUT_FLAG THEN print,'Total size in bytes ',Total_size
     raw_data_desc.total_size=Total_size
   endif else raw_data_desc.total_size=TDMS_getDataTypeSize(Data_type)*ARRAY_DIMENSION*N_VALUES ;- redundant for non string data, but I like it anyway.

 endif

 ;- END RAW Data Descriptor

  n_properties=ULONG(0) 
   READU,Lun,n_properties
   IF OUTPUT_FLAG THEN print,'Number properties for current object: ',n_properties ;- Number of properties for actual object (path)

;- Fake prop_names/prop_values to save the output structure format
;- Let's do check n_properties after to see if prop are set
prop_names  = {FAKE_PROP_NAME :'FAKE_NOT_SET'}
prop_values = {FAKE_PROP_VALUE:'FAKE_NOT_SET'}

;- START - protection for object with no-properties
if n_properties gt 0 then begin
  ;- define the property structure first element
    k=0
    property_tmp=TDMS_getproperty(Lun,Debug=0)
  ;  helps,property_tmp & k++
    prop_names=CREATE_STRUCT('property_names_'+stringer(k),property_tmp.name)
    prop_values=CREATE_STRUCT('property_values_'+stringer(k),property_tmp.value)
    
  ;- concatenate the properties  
    for k=long64(1),n_properties-1 do begin
       print,'hey1'
      property_tmp=TDMS_getproperty(Lun,Debug=0)
  ;    helps,property_tmp
      prop_names=CREATE_STRUCT(prop_names,'property_names_'+stringer(k),property_tmp.name)
      prop_values=CREATE_STRUCT(prop_values,'property_values_'+stringer(k),property_tmp.value)
    end
    
  ;helps,prop_names
  ;helps,prop_values
 end  
;    prop_names=CREATE_STRUCT(prop_names,'n_property_names',n_properties)
;    prop_values=CREATE_STRUCT(prop_values,'n_property_values',n_properties)

;- END - protection for object with no-properties 

  MetaData= {$
  ;  object_path_string_len : object_path_string_len ,$
    object_path_string     : object_path_string ,$
    raw_data_index         : raw_data_index ,$ ;- if it is 4294967295ul no data
    raw_data_descriptor    : raw_data_desc ,$
    n_properties           : n_properties $   ;- it it is 0 no properties
;    property_names         : prop_names,$   ;-- moved in separated structure
;    property_values        : prop_values $  ;-- moved in separated structure
    }
;return,MetaData

end
