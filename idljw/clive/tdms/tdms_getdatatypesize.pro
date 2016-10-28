function TDMS_getDataTypeSize,dataType

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
  0l       : typeSize = 0          ;'tdsTypeVoid'
  1l       : typeSize = 1          ;'tdsTypeI8'
  2l       : typeSize = 2          ;'tdsTypeI16'
  3l       : typeSize = 4          ;'tdsTypeI32'
  4l       : typeSize = 8          ;'tdsTypeI64'
  5l       : typeSize = 1          ;'tdsTypeU8'
  6l       : typeSize = 2          ;'tdsTypeU16'
  7l       : typeSize = 4          ;'tdsTypeU32'
  8l       : typeSize = 8          ;'tdsTypeU64'
  9l       : typeSize = 4          ;'tdsTypeSingleFloat'
  10l      : typeSize = 8          ;'tdsTypeDoubleFloat'
  11l      : typeSize = 'Undefined';'tdsTypeExtendedFloat'
  25l      : typeSize = 'Undefined';'tdsTypeSingleFloatWithUnit=0x19'
  26l      : typeSize = 'Undefined';'tdsTypeDoubleFloatWithUnit'
  27l      : typeSize = 'Undefined';'tdsTypeExtendedFloatWithUnit'
  32l      : typeSize = 4          ;'tdsTypeString=0x20'
  33l      : typeSize = 'Undefined';'tdsTypeBoolean=0x21'
  68l      : typeSize = 16         ;'tdsTypeTimeStamp=0x44'
  2l^32-1l : typeSize = 'Undefined';'tdsTypeDAQmxRawData=0xFFFFFFFF      
    else   : begin
          typeSize='ERROR! Unrecognized data type :'
          print,typeSize,dataType
          endelse
end

return,typeSize

end
