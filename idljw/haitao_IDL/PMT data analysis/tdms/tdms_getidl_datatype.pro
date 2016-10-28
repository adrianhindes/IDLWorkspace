function TDMS_getIDL_DataType,dataType

;%TDMS_getDataTypeName  Returns a string indicating dataType
;%
;%   Given a Labview numeric datatype value, this returns the corresponding atomic size for this type.
;%
;%   typeSize = TDMS_getDataTypeName(dataType)
; based on:
; TDMS_getDataTypeName by Jim Hokanson 
; 
; http://www.mathworks.com/matlabcentral/fileexchange/30023-tdms-reader/content/Version_2p4_Final/tdmsSubfunctions/TDMS_getDataTypeName.m

CASE dataType OF
  0l       : typeSize =  FIX(0,TYPE=0)                ;'tdsTypeVoid'
;  1l       : typeSize = 'Undefined'                   ;'tdsTypeI8'
  2l       : typeSize =  FIX(0,TYPE=2)                ;'tdsTypeI16'
  3l       : typeSize =  FIX(0,TYPE=3)                ;'tdsTypeI32'
  4l       : typeSize =  FIX(0,TYPE=14)               ;'tdsTypeI64'
  5l       : typeSize =  FIX(0,TYPE=1)                ;'tdsTypeU8'
  6l       : typeSize =  FIX(0,TYPE=12)               ;'tdsTypeU16'
  7l       : typeSize =  FIX(0,TYPE=13)               ;'tdsTypeU32'
  8l       : typeSize =  FIX(0,TYPE=15)               ;'tdsTypeU64'
  9l       : typeSize =  FIX(0,TYPE=4)                ;'tdsTypeSingleFloat'
  10l      : typeSize =  FIX(0,TYPE=5)                ;'tdsTypeDoubleFloat'
;  11l      : typeSize = 'Undefined'                   ;'tdsTypeExtendedFloat'
;  25l      : typeSize = 'Undefined'                   ;'tdsTypeSingleFloatWithUnit=0x19'
;  26l      : typeSize = 'Undefined'                   ;'tdsTypeDoubleFloatWithUnit'
;  27l      : typeSize = 'Undefined'                   ;'tdsTypeExtendedFloatWithUnit'
  32l      : typeSize = '0';FIX(0,TYPE=7)             ;'tdsTypeString=0x20'
;  33l      : typeSize = 'Undefined'                   ;'tdsTypeBoolean=0x21'
  68l      : typeSize = {u64:ULONG64(0),i64:LONG64(0)};'tdsTypeTimeStamp=0x44' 
;  2l^32-1l : typeSize = 'Undefined'                    ;'tdsTypeDAQmxRawData=0xFFFFFFFF      
                              else   : begin
          typeSize='ERROR! Unrecognized data type :'
          print,typeSize,dataType
          endelse
end

return,typeSize

end
