pro TDMS_reader,file,LEADIN,METADATA,PROP_NAMES,PROP_VALUES,DEBUG=DEBUG

OUTPUT_FLAG=0
IF KEYWORD_SET(DEBUG) THEN IF (DEBUG eq 1) then OUTPUT_FLAG=1
IF OUTPUT_FLAG EQ 1 THEN DEBUG=1 ELSE DEBUG=0

fileinfo=FILE_INFO(file)

IF fileinfo.exists AND fileinfo.size gt 0l  THEN BEGIN ;- START protection for non existing/zero length files
  
  ;ToDo: Support for tdms_index file, simply skip the pointer relocation and just read the adjacent section.
  ;ToDo: check all the ToCmask case. Currently:
  ; OK - kTocMetaData         
  ; NO - kTocRawData        
  ; NO - kTocDAQmxRawData   
  ; OK - kTocInterleavedData
  ; NO - kTocBigEndian      
  ; OK - kTocNewObjList
  
  GET_LUN,lun
  OPENR,lun,file
  POINT_LUN,lun,0
  
  ;POINT_LUN,lun,289426   ;- seg 95 > META OBJ = 2
  ;POINT_LUN,lun,290029   ;- seg 96 > META OBJ = 2
  ;POINT_LUN,lun,290625   ;- seg 97 > META OBJ = 90
  ;POINT_LUN,lun,6537717  ;- seg 98 > META OBJ = 90
  ;POINT_LUN,lun,13018409 ;- seg 99 > META OBJ = 90
  ;POINT_LUN,lun,19576677 ;- seg 100 > META OBJ = 60!!
  
  ;POINT_LUN,lun,26053535
  ;POINT_LUN,lun,26055583 > looking in the data file the next segment starts here!!!!
  ;UNIT=lun
  ;POINT_LUN,-lun,a & print,a
  Segment_counter=0l
  
  leadin      = ''
  MetaData    = ''
  Prop_names  = ''
  Prop_values = ''
  
  WHILE ~ EOF(lun) DO BEGIN 
  ;WHILE Segment_counter le 101 DO BEGIN 
  
  
  ;- clean the temporary/current segment variables
  MetaData_seg = 0
  leadin_seg   = 0
  Prop_names_seg = 0 
  Prop_values_seg = 0
  ;Lead In
  DEBUG=0
  leadin_seg=TDMS_getLeadIn(lun,DEBUG=DEBUG)
        leadin_seg  = CREATE_STRUCT(leadin_seg,'SEGMENT_ID',Segment_counter) 
  if leadin_seg.KTOCNEWOBJLIST eq 0 then POINT_LUN,(-1*lun),Metadata_start_pointer_from_Leadin ;- needed after if kTocNEWOBJLIST set to 0
  
  
  DEBUG=0
  ;POINT_LUN,lun,26053563
  ;;Meta Data
  if leadin_seg.KTOCMETADATA eq 1 then begin $ ;- if kTocMETADATA set there are metadata defined
    TDMS_getMetaData,Lun,Segment_counter,leadin_seg,MetaData_seg,Prop_names_seg,Prop_values_seg,MetaData,DEBUG=DEBUG
  endif else  begin;- if kTocMETADATA not set must be identical to the previous
  
  ;-- update manually some METADATA parts:
    MetaData_seg = MetaData(where(METADATA.SEGMENT_ID eq Segment_counter-1))
    Prop_names_seg=Prop_names.(Segment_counter-1)
    Prop_values_seg= Prop_values.(Segment_counter-1)
    
  Absolute_RawData_Start_pointer = Metadata_start_pointer_from_Leadin+leadin_seg.RAW_DATA_OFFSET
     CUMULATE_raw_data_length=([0,total(MetaData_seg.RAW_DATA_DESCRIPTOR.TOTAL_SIZE,/CUMULATIVE)])(0:N_ELEMENTS(MetaData_seg)-1)
     MetaData_seg.RAW_DATA_DESCRIPTOR.DATA_START_RAW = Absolute_RawData_Start_pointer+CUMULATE_raw_data_length
     
     MetaData_seg.SEGMENT_ID = Segment_counter
     MetaData_seg.CHANNEL_ID = L64INDGEN(N_ELEMENTS(MetaData_seg.CHANNEL_ID))
     MetaData_seg.RAW_DATA_DESCRIPTOR.REPLICATE_PREVIOUS_SEGMENT = 1b ;- raise flag: we are replicating previous METADATa channel 
;     MetaData_seg.RAW_DATA_DESCRIPTOR.NO_RAW_DATA = 1b. ;- raise flag: we are in a channel without RAW Data 
        ;- TO CHECK!!
  ;      MetaDataObject_RAW_size = MetaData_seg.RAW_DATA_DESCRIPTOR.TOTAL_SIZE
  ;      Absolute_RawData_Start_pointer = Absolute_RawData_Start_pointer+MetaDataObject_RAW_size
  endelse
  
  if leadin_seg.KTOCMETADATA eq 1 AND leadin_seg.KTOCNEWOBJLIST eq 0 then begin $ ;- if kTocNEWOBJLIST set to 0
    ; take the last METADATA & Props definition
    
    last_METADATA     = MetaData(where(METADATA.SEGMENT_ID eq Segment_counter-1))
    n_last_METADATA   = N_ELEMENTS(last_METADATA)
    last_Prop_names   = Prop_names.(Segment_counter-1)
    last_Prop_values  = Prop_values.(Segment_counter-1)
  
  ;--- map the old (last) METADATA channel in the new based on the channel path match
  index_old2new_METADATA = -100 ;- define the index vector with fake data
  for ch=0,leadin_seg.N_NEW_OBJ_IN_SEGMENT-1 do $
        index_old2new_METADATA=[index_old2new_METADATA,where(STRMATCH(last_METADATA.OBJECT_PATH_STRING,MetaData_seg(ch).OBJECT_PATH_STRING))]
        index_old2new_METADATA = index_old2new_METADATA(1:*) ;- clean the index vector from fake data
  
  ;- separate the index of the matched (=updated) channel and the unmatched (=new) channel
  matched_channel = where(index_old2new_METADATA ne -1,n_matched_channel,COMPLEMENT=not_matched_channel,NCOMPLEMENT=n_not_matched_channel)
  ;help,matched_channel,not_matched_channel
  ;-- redundant check, but let's keep it safe...
  
  ;if Segment_counter eq 134 then stop
  
  ;-- aggregate matched channel to the metadata & props
  if n_matched_channel ne 0 then begin
  last_METADATA(index_old2new_METADATA(matched_channel)) = MetaData_seg(matched_channel)
    for ll=0,n_matched_channel-1 do begin
      last_Prop_names.((index_old2new_METADATA(matched_channel))(ll)) = Prop_names_seg.(matched_channel(ll))
      last_Prop_values.((index_old2new_METADATA(matched_channel))(ll))= Prop_values_seg.(matched_channel(ll))
    endfor
  endif
  
  ;if Segment_counter eq 134 then stop
  
  ;-- aggregate not matched channel to the metadata & props
  if n_not_matched_channel ne 0 then begin
    last_METADATA = [last_METADATA,MetaData_seg(not_matched_channel)]
      Prop_names_seg_tagnames = 'Prop_names_object_'+stringer(indgen(n_not_matched_channel)+n_last_METADATA) ; (tag_names(Prop_names_seg))
      Prop_values_seg_tagnames='Prop_values_object_'+stringer(indgen(n_not_matched_channel)+n_last_METADATA) ;(tag_names(Prop_values_seg))
      
    for ll=0,n_not_matched_channel-1 do begin
      ;- due to structure selection we have to explicitely define the name of the new pieces
      ;- that are the old name in the previous segment's structure 
      last_Prop_names  = CREATE_STRUCT(last_Prop_names , Prop_names_seg_tagnames(ll) ,Prop_names_seg.(not_matched_channel(ll)))
      last_Prop_values = CREATE_STRUCT(last_Prop_values,Prop_values_seg_tagnames(ll),Prop_values_seg.(not_matched_channel(ll)))
    endfor
  endif
  
  ;if Segment_counter eq 134 then stop
  
  ;-- update manually some METADATA parts:
  Absolute_RawData_Start_pointer = Metadata_start_pointer_from_Leadin+leadin_seg.RAW_DATA_OFFSET
     CUMULATE_raw_data_length=([0,total(last_METADATA.RAW_DATA_DESCRIPTOR.TOTAL_SIZE,/CUMULATIVE)])(0:N_ELEMENTS(last_METADATA)-1)
     last_METADATA.RAW_DATA_DESCRIPTOR.DATA_START_RAW = Absolute_RawData_Start_pointer+CUMULATE_raw_data_length
     last_METADATA.SEGMENT_ID = Segment_counter
     last_METADATA.CHANNEL_ID = L64INDGEN(N_ELEMENTS(last_METADATA.CHANNEL_ID))
  ;print,'DATA_TYPE ARRAY_DIMENSION N_VALUES DATA_START_RAW TOTAL_SIZE'
  ;print_list,stringer(MetaData_seg.RAW_DATA_DESCRIPTOR.DATA_TYPE       )+'  '+stringer(MetaData_seg.RAW_DATA_DESCRIPTOR.ARRAY_DIMENSION )+'  '+stringer(MetaData_seg.RAW_DATA_DESCRIPTOR.N_VALUES        )+'  '+stringer(MetaData_seg.RAW_DATA_DESCRIPTOR.DATA_START_RAW  )+'  '+stringer(MetaData_seg.RAW_DATA_DESCRIPTOR.TOTAL_SIZE      )
  
    ;-- put the updated variables in the cycle's temporary variable
    ;-- this way we update the cycle's temporary variable and they will be added to the normal data flow
    MetaData_seg=last_METADATA
    Prop_names_seg=last_Prop_names   
    Prop_values_seg=last_Prop_values  
  
  ;  MetaData_seg = MetaData(where(METADATA.SEGMENT_ID eq segment_id-1))
  ;  Prop_names_seg=Prop_names.(segment_id-1)
  ;  Prop_values_seg= Prop_values.(segment_id-1)
  ;POINT_LUN,(-1*lun),Metadata_start_pointer
  ;Absolute_RawData_Start_pointer = Metadata_start_pointer+leadin_segment.RAW_DATA_OFFSET
  ;      MetaData_seg.RAW_DATA_DESCRIPTOR.DATA_START_RAW = Absolute_RawData_Start_pointer
        ;- TO CHECK!!
  ;      MetaDataObject_RAW_size = MetaData_seg.RAW_DATA_DESCRIPTOR.TOTAL_SIZE
  ;      Absolute_RawData_Start_pointer = Absolute_RawData_Start_pointer+MetaDataObject_RAW_size
  endif
  
  
  ;help,MetaData_seg
  ;helps,leadin_seg
  
  ;MetaData_seg > temporary Metadata storage
      ;- initialize the first or assing new data 
      if (SIZE(leadin,/TYPE) ne 7)      then leadin     = [leadin,leadin_seg]      else leadin  =leadin_seg
      if (SIZE(MetaData,/TYPE) ne 7)    then MetaData   = [MetaData,MetaData_seg]  else MetaData=MetaData_seg
      if (SIZE(Prop_names,/TYPE) ne 7)  then Prop_names = CREATE_STRUCT(Prop_names ,'Prop_names_seg_'+stringer(Segment_counter),Prop_names_seg)  else Prop_names =Prop_names_seg
      if (SIZE(Prop_values,/TYPE) ne 7) then Prop_values= CREATE_STRUCT(Prop_values,'Prop_values_seg_' +stringer(Segment_counter),Prop_values_seg)  else Prop_values=Prop_values_seg
  ;print,'                            N_MetaData.SEGMENT_ID : ',N_ELEMENTS(MetaData.SEGMENT_ID)
  ;print,'SEGMENT_ID : ',leadin_seg.SEGMENT_ID,MetaData_seg(0).SEGMENT_ID,leadin_seg.N_NEW_OBJ_IN_SEGMENT,N_ELEMENTS(MetaData_seg.SEGMENT_ID),N_ELEMENTS(MetaData.SEGMENT_ID)
  
  ;------------------------------------------------------------------------------------
  ;- Logical Link!
  ;- MetaData(k) <> PROPERTIES_NAMES.(k) <> PROPERTIES_VALUES.(k)
  ;------------------------------------------------------------------------------------
  
  ;print,([transpose([TAG_NAMES(MetaData.RAW_DATA_DESCRIPTOR),'RAW_DATA_INDEX']),string($
  ;[[MetaData.RAW_DATA_DESCRIPTOR.DATA_TYPE],$
  ;[MetaData.RAW_DATA_DESCRIPTOR.ARRAY_DIMENSION],$
  ;[MetaData.RAW_DATA_DESCRIPTOR.N_VALUES],$
  ;[MetaData.RAW_DATA_DESCRIPTOR.DATA_START_RAW],$
  ;[MetaData.RAW_DATA_DESCRIPTOR.TOTAL_SIZE],$
  ;[MetaData.RAW_DATA_INDEX]])])
  
  
  ;- Set k to the last object in Segment
  last_object_in_seg=(N_ELEMENTS(METADATA_seg))-1
  ;- Set the next segment beginning equal to the end of the last object in Segment
   Next_Segment_pointer=MetaData_seg(last_object_in_seg).RAW_DATA_DESCRIPTOR.DATA_START_RAW+$
                        MetaData_seg(last_object_in_seg).RAW_DATA_DESCRIPTOR.TOTAL_SIZE
  ;- Check if we are reading the root segment, then skip to the end of the segment (varing due to number of properites)
  if (N_ELEMENTS(byte(MetaData_seg(last_object_in_seg).OBJECT_PATH_STRING)) eq 1) then $
    if (byte(MetaData(last_object_in_seg).OBJECT_PATH_STRING)) eq 47 then POINT_LUN,(-1*lun),Next_Segment_pointer 
  
  ;endfor
  
  if (OUTPUT_FLAG eq 1) then begin ;- START OUTPUT_FLAG
    print,'------------------------------------------------------------------------------------------------------------------'
    print,'Actual Segment n.'+stringer(Segment_counter)+' has '+stringer(N_ELEMENTS(METADATA_seg))+' Objects'
    
    
    head= [ '                Path'+$
          ' RAW_DATA_INDEX'+$
          ' DATA_TYPE'+$
          ' ARRAY_DIMENSION'+$
          ' N_VALUES'+$
          ' DATA_START_RAW'+$
          ' TOTAL_SIZE']
    print,head & print_list,/NOINDEX,stringer(MetaData_seg.OBJECT_PATH_STRING)+' > '+$
                                     stringer(MetaData_seg.RAW_DATA_INDEX)+'  '+$
                                     stringer(MetaData_seg.RAW_DATA_DESCRIPTOR.DATA_TYPE       )+'  '+$
                                     stringer(MetaData_seg.RAW_DATA_DESCRIPTOR.ARRAY_DIMENSION )+'  '+$
                                     stringer(MetaData_seg.RAW_DATA_DESCRIPTOR.N_VALUES        )+'  '+$
                                     stringer(MetaData_seg.RAW_DATA_DESCRIPTOR.DATA_START_RAW  )+'  '+$
                                     stringer(MetaData_seg.RAW_DATA_DESCRIPTOR.TOTAL_SIZE      )                                 
                                     print,'Next Segment n.'+stringer(Segment_counter)+' start',Next_Segment_pointer
                                     print
  endif ;- END OUTPUT_FLAG
  
  Segment_counter++
  POINT_LUN,lun,Next_Segment_pointer
  
  endwhile
 
  ;-- Close and Free file
  CLOSE, lun
  Free_LUN, lun
  ;.full

ENDIF ELSE PRINT,fileinfo.exists eq 0?'STOPPING : File does not exists  '+file:'STOPPING : 0 length file  '+file ;- END protection for non existing/zero length files
  
end
