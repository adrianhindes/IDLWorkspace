function tdms_channel_data_reader,file,METADATA_local,channells_in_segment,copy_tdms=copy_tdms

n_channells_in_segment = N_ELEMENTS(channells_in_segment)
common cbbtcdr, filestore, lun

if n_elements(filestore) ne 0 then if filestore eq file then begin
   print,'in tdms channel reader skipping file open'
   goto,noopen
endif
if n_elements(filestore) ne 0 then begin
   close,lun
   free_lun,lun
   print,'closed the file',filestore
endif

if keyword_set(copy_tdms) then begin
   print,'before ramdisk copy'
   spawn,'rm -rf /tmp/ramdisk/*'
   spawn,'cp '+file+' /tmp/ramdisk'
   print,'done copying'
;OPENR,lun,path+file
   spl=strsplit(file,'/',/extract)
   file1='/tmp/ramdisk/'+spl(n_elements(spl)-1) ;file
endif else file1=file

GET_LUN,lun

OPENR,lun,file1
filestore=file
noopen:
;TYPE=TDMS_getIDL_DataType(METADATA_local[channells_in_segment(0]).RAW_DATA_DESCRIPTOR.DATA_TYPE)
;
;if TYPE ne -1 $ ;- -1 is the TimeStamp type
; then data_read = FIX(0,TYPE=TYPE) $
; else data_read = {i64:LONG64(0),u64:ULONG64(0)}
   
   data_read = TDMS_getIDL_DataType(METADATA_local[channells_in_segment[0]].RAW_DATA_DESCRIPTOR.DATA_TYPE)
   
for ll=long64(0),n_channells_in_segment-1 do begin

  ;- shift pointer to new block
  POINT_LUN,lun,METADATA_local[channells_in_segment[ll]].RAW_DATA_DESCRIPTOR.DATA_START_RAW 
;  print,METADATA_local[channells_in_segment(ll]).RAW_DATA_DESCRIPTOR.DATA_START_RAW 
;  helps,METADATA_local[channells_in_segment(ll]).RAW_DATA_DESCRIPTOR
     
  if METADATA_local[channells_in_segment[ll]].RAW_DATA_DESCRIPTOR.N_VALUES gt 0 then begin ;-START check if more then 0 values to read
    ;- create temporary storage variable
    ;- Redundant: the same array could not change the type. Retain this line to check for error in read,it is formally correct.
    
    ;- Define the a teporary variable tmp_read to be readed from the file
    ;- Are we reading a string filed ?
    TYPE=METADATA_local[channells_in_segment[ll]].RAW_DATA_DESCRIPTOR.DATA_TYPE
    if TYPE ne 32 then begin ;- take care of string filed adress field before the actual data
      tmp_read = Replicate( TDMS_getIDL_DataType(METADATA_local[channells_in_segment[ll]].RAW_DATA_DESCRIPTOR.DATA_TYPE),METADATA_local[channells_in_segment[ll]].RAW_DATA_DESCRIPTOR.N_VALUES) 
    endif else begin
;- ToDo : is this stil valid in case the METADATA are not set / copied from previous channel??
;Missing from the descriptio on http://www.ni.com/white-paper/5696/en : TDMS File Format Internal Structure
;The string fields have N_VALUES*32 bits / 4 bytes filed before the data pointing to each string value, starting at the end of the address field
;
;## Example 
;
;file : mer_f_mertis_quartz_800_2x4_300C
;Start :  6221213 / 5EED9D
;Channel: /'TM_SCIENCE_TIS_DATA'/'par_tis_bin_mode_txt:2'
;RAW_DATA_DESCRIPTOR :
;   DATA_TYPE       ULONG         32
;   ARRAY_DIMENSION ULONG          1
;   N_VALUES        ULONG64        8
;   DATA_START_RAW  ULONG64  6221213
;   TOTAL_SIZE      ULONG64      56
;
;Hexdump fo the file from 6221213 to 6221213+56 = 6221269
;The first 8*4 bytes = #2 bytes are the addresse to each signle text value.
;
;  03 00 00 00  =   3   : tdsTypeI32
;  06 00 00 00  =   6   : tdsTypeI32
;  09 00 00 00  =   9   : tdsTypeI32
;  0C 00 00 00  =  12   : tdsTypeI32
;  0F 00 00 00  =  15   : tdsTypeI32
;  12 00 00 00  =  18   : tdsTypeI32
;  15 00 00 00  =  21   : tdsTypeI32
;  18 00 00 00  =  24   : tdsTypeI32
;  31 78 32     =  1x2  : tdsTypeString from  0 to 3
;  31 78 32     =  1x2  : tdsTypeString from  3 to 6
;  31 78 32     =  1x2  : tdsTypeString from  6 to 9
;  31 78 32     =  1x2  : tdsTypeString from  9 to 12
;  31 78 32     =  1x2  : tdsTypeString from 12 to 15
;  31 78 32     =  1x2  : tdsTypeString from 15 to 18
;  31 78 32     =  1x2  : tdsTypeString from 18 to 21
;  31 78 32     =  1x2  : tdsTypeString from 21 to 24

      str_addresses = Replicate(TDMS_getIDL_DataType(3l),METADATA_local[channells_in_segment[ll]].RAW_DATA_DESCRIPTOR.N_VALUES)
      READU,Lun,str_addresses
;      print,str_addresses
      ;-- handle the case of 1 value
      if METADATA_local[channells_in_segment[ll]].RAW_DATA_DESCRIPTOR.N_VALUES gt 1 then begin 
        ;- this allow to handle strings with varying lenght 
        str_len = (str_addresses)-[0,(str_addresses(indgen(N_ELEMENTS(str_addresses)-1)))]
        ;- create the array to read
        tmp_read = whitespaces_string(str_len[0])
          for str_index=1,N_ELEMENTS(str_addresses)-1 do tmp_read=[tmp_read,whitespaces_string(str_len[str_index])]
      endif else tmp_read = whitespaces_string(str_addresses[0]) ;-- if only 1 value set the temporary read variable to the only readed address 
;      print_list,tmp_read
    endelse
    
    
    ;- read data in temporary storage variable
    READU,Lun,tmp_read
    
    ;- add data in to static variable
    data_read = [data_read,tmp_read]
  endif  ;-END check if more then 0 values to read

endfor

;-erase first empty field
data_read=data_read[1:*]


;-- Close and Free file

;CLOSE, lun
;Free_LUN, lun
 

;if METADATA_local[channells_in_segment[0]].RAW_DATA_DESCRIPTOR.DATA_TYPE eq 68l then time=time.I64+time.u64*2d^(-64)


return,data_read

;for ll=0,n_channells_in_segment-1 do helps,METADATA_local[channells_in_segment[ll]].RAW_DATA_DESCRIPTOR
;
;tmp=0
;for ll=0,n_channells_in_segment-1 do tmp=tmp+METADATA_local[channells_in_segment[ll]].RAW_DATA_DESCRIPTOR.N_VALUES
;print,tmp

end
