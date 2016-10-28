function tdms_getidldatatype,dataType

; based on:
; TDMS_getDataTypeName by Jim Hokanson 
; 
; http://www.mathworks.com/matlabcentral/fileexchange/30023-tdms-reader/content/Version_2p4_Final/tdmsSubfunctions/TDMS_getDataTypeName.m

CASE dataType OF
;- IDL supported TDMS data types
     2l   : IDLData=FIX(0)    ;tdsTypeI16
     3l   : IDLData=LONG(0)   ;tdsTypeI32
     4l   : IDLData=LONG64(0) ;tdsTypeI64
     5l   : IDLData=BYTE(0)   ;tdsTypeU8
     6l   : IDLData=UINT(0)   ;tdsTypeU16
     7l   : IDLData=ULONG(0)  ;tdsTypeU32
     8l   : IDLData=ULONG64(0);tdsTypeU64
     9l   : IDLData=FLOAT(0)  ;tdsTypeSingleFloat
    10l   : IDLData=DOUBLE(0) ;tdsTypeDoubleFloat
    32l   : IDLData=''        ;tdsTypeString=0x20
    68l   : IDLData=''        ;tdsTypeTimeStamp=0x44
;- unsupported TDMS data types - unrecoverable error message, dataType willl be not defined!
      1l  : Result = DIALOG_MESSAGE( 'TDMS data type tdsTypeI8 not supported in IDL.',/ERROR,/CENTER,TITLE='Unsupported DataType') ; tdsTypeI8
     11l  : Result = DIALOG_MESSAGE( 'TDMS data type tdsTypeExtendedFloat not supported in IDL.',/ERROR,/CENTER,TITLE='Unsupported DataType') ; tdsTypeExtendedFloat
     25l  : Result = DIALOG_MESSAGE( 'TDMS data type tdsTypeSingleFloatWithUnit not supported in IDL.',/ERROR,/CENTER,TITLE='Unsupported DataType') ; tdsTypeSingleFloatWithUnit
     26l  : Result = DIALOG_MESSAGE( 'TDMS data type tdsTypeDoubleFloatWithUnit not supported in IDL.',/ERROR,/CENTER,TITLE='Unsupported DataType') ; tdsTypeDoubleFloatWithUnit
     27l  : Result = DIALOG_MESSAGE( 'TDMS data type tdsTypeExtendedFloatWithUnit not supported in IDL.',/ERROR,/CENTER,TITLE='Unsupported DataType') ; tdsTypeExtendedFloatWithUnit
;     33l  : IDLdata=byte(0);Result = DIALOG_MESSAGE( 'TDMS data type tdsTypeBoolean not supported in IDL.',/ERROR,/CENTER,TITLE='Unsupported DataType') ; tdsTypeBoolean
     33l  : IDLdata=byte(0);stop;Result = DIALOG_MESSAGE( 'TDMS data type tdsTypeBoolean not supported in IDL.',/ERROR,/CENTER,TITLE='Unsupported DataType') ; tdsTypeBoolean

 2l^32-1l : Result = DIALOG_MESSAGE( 'TDMS data type tdsTypeDAQmxRawData not supported in IDL.',/ERROR,/CENTER,TITLE='Unsupported DataType') ; tdsTypeDAQmxRawData                        
;- any other data types - unrecoverable error message, dataType willl be not defined!
   else   : IDLData='';stop;Result = DIALOG_MESSAGE( 'ERROR! Unrecognized data type! TDMS code readed:'+string(dataType),/ERROR,/CENTER,TITLE='Unsupported DataType')                      
end

return,IDLData

end
