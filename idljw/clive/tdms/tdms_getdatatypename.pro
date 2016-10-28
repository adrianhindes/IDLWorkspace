function TDMS_getDataTypeName,dataType

;%TDMS_getDataTypeName  Returns a string indicating dataType
;%
;%   Given a Labview numeric datatype value, this returns a string
;%
;%   typeName = TDMS_getDataTypeName(dataType)
; based on:
; TDMS_getDataTypeName by Jim Hokanson 
; 
; http://www.mathworks.com/matlabcentral/fileexchange/30023-tdms-reader/content/Version_2p4_Final/tdmsSubfunctions/TDMS_getDataTypeName.m

CASE dataType OF
  0l       : typeName = 'tdsTypeVoid'
  1l       : typeName = 'tdsTypeI8'
  2l       : typeName = 'tdsTypeI16'
  3l       : typeName = 'tdsTypeI32'
  4l       : typeName = 'tdsTypeI64'
  5l       : typeName = 'tdsTypeU8'
  6l       : typeName = 'tdsTypeU16'
  7l       : typeName = 'tdsTypeU32'
  8l       : typeName = 'tdsTypeU64'
  9l       : typeName = 'tdsTypeSingleFloat'
  10l      : typeName = 'tdsTypeDoubleFloat'
  11l      : typeName = 'tdsTypeExtendedFloat'
  25l      : typeName = 'tdsTypeSingleFloatWithUnit=0x19'
  26l      : typeName = 'tdsTypeDoubleFloatWithUnit'
  27l      : typeName = 'tdsTypeExtendedFloatWithUnit'
  32l      : typeName = 'tdsTypeString=0x20'
  33l      : typeName = 'tdsTypeBoolean=0x21'
  68l      : typeName = 'tdsTypeTimeStamp=0x44'
  2l^32-1l : typeName = 'tdsTypeDAQmxRawData=0xFFFFFFFF'
    else   : begin
          typeName='ERROR! Unrecognized data type :'
          print,typeName,dataType
          endelse
end

return,typeName

end
