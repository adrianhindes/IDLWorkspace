function TDMS_getLeadIn,Lun,debug=debug

OUTPUT_FLAG=0
IF KEYWORD_SET(DEBUG) THEN IF (DEBUG eq 1) then OUTPUT_FLAG=1


leadin_str= {$
  tag             : whitespaces_string(4) ,$
  ToC_mask        : BYTARR(4) ,$
  Version         : ULONG(0)  ,$
  Next_offset     : ULONG64(0),$
  Raw_data_offset : ULONG64(0) $
  }
;  POINT_LUN,-lun,a & print,a
  
  READU,Lun,leadin_str
  
 ToC_mask_str = { $
  kTocMetaData         : total(REVERSE(leadin_str.ToC_mask) AND ISHFT(byte(1),1)) ne 0 ,$;(1L<<1)  Segment contains meta data
  kTocNewObjList       : total(REVERSE(leadin_str.ToC_mask) AND ISHFT(byte(1),2)) ne 0 ,$;(1L<<2)  Segment contains new object list (e.g. channels in this segment are not the same channels the previous segment contains)
  kTocRawData          : total(REVERSE(leadin_str.ToC_mask) AND ISHFT(byte(1),3)) ne 0 ,$;(1L<<3)  Segment contains raw data
  kTocDAQmxRawData     : total(REVERSE(leadin_str.ToC_mask) AND ISHFT(byte(1),7)) ne 0 ,$;(1L<<7)  Segment contains DAQmx raw data
  kTocInterleavedData  : total(REVERSE(leadin_str.ToC_mask) AND ISHFT(byte(1),5)) ne 0 ,$;(1L<<5)  Raw data in the segment is interleaved (if flag is not set, data is contiguous)
  kTocBigEndian        : total(REVERSE(leadin_str.ToC_mask) AND ISHFT(byte(1),6)) ne 0  $;(1L<<6)  All numeric values (properties, raw data…)  in the segment are big-endian formatted (if flag is not set, data is little-endian)
  }

;- ToC_mask_str & N_new_obj_in_segment must be added after the reading phase!!
;- the structure data are directly read from the file!
leadin_str = CREATE_STRUCT(leadin_str,$
                          ToC_mask_str,$
                          'N_new_obj_in_segment',ULONG(0)) ;- it comes from the first MetaData field, easy to have here! 
                                                           ;- It will be assigned after MetaData Reading
                                                           ;- If there are no object (kTocNewObjList=0) it will stay quietly 0ul

IF OUTPUT_FLAG THEN begin
  print,'Tag : ',leadin_str.tag & $
  print,'Version number :',stringer(leadin_str.Version) & $
  print,'Next segment offset :',stringer(leadin_str.Next_offset) & $
  print,'Raw data offset :',stringer(leadin_str.Raw_data_offset) & $ ;- Raw data in actual segment = Next segment offset - Raw data offset
  print,'Raw data lenght :',stringer(leadin_str.Next_offset-leadin_str.Raw_data_offset) & $
  print,'ToC mask 0x : ',leadin_str.ToC_mask & $
  print,'  ToC mask explained:' & $
  print,'   kTocMetaData        : ',leadin_str.kTocMetaData        &$
  print,'   kTocNewObjList      : ',leadin_str.kTocNewObjList      &$
  print,'   kTocRawData         : ',leadin_str.kTocRawData         &$
  print,'   kTocDAQmxRawData    : ',leadin_str.kTocDAQmxRawData    &$
  print,'   kTocInterleavedData : ',leadin_str.kTocInterleavedData &$
  print,'   kTocBigEndian       : ',leadin_str.kTocBigEndian        
end


return,leadin_str

end