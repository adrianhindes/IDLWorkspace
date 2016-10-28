function TDMS_getProperty,Lun,debug=debug

OUTPUT_FLAG=0
IF KEYWORD_SET(DEBUG) THEN IF (DEBUG eq 1) then OUTPUT_FLAG=1

;--------------------------------------------------
;-  Property lenght

  property_name_lenght=ULONG(0) 
  READU,Lun,property_name_lenght
  IF OUTPUT_FLAG THEN print,'Property name lenght: ',property_name_lenght

;-  Property name - Variable length, see previous field
  property_name=whitespaces_string(property_name_lenght)
  ;BYTARR(property_name_lenght)  ;- Actual Path string, with lenght F
   READU,Lun,property_name
   IF OUTPUT_FLAG THEN print,'Actual property string : ',property_name
  

;- Property value Data type
  value_data_type=ULONG(0) ;- Data type of the property value (tdsTypeString)
   READU,Lun,value_data_type
   
   IF OUTPUT_FLAG THEN print,'Data type of the property value : ',TDMS_getDataTypeName(value_data_type)

IDLDataType = TDMS_getIDLDataType(value_data_type)

;- check if it a string, if not the following doesn't exist!!
  if SIZE(IDLDataType,/TYPE) eq 7 then begin

      I=ULONG(0) ;- Length of the property value (only for strings)
       READU,Lun,I
       IF OUTPUT_FLAG THEN print,'Length of the property value string : ',I
      if I gt 0 then begin
        L=whitespaces_string(I);BYTARR(I)  ;- Value of the property prop, with lenght I
         READU,Lun,L
         IF OUTPUT_FLAG THEN print,'Actual property value string: ',L
      endif else L=''
  end else begin

      L=IDLDataType ;- Length of the property value (only for strings)
       READU,Lun,L
       IF OUTPUT_FLAG THEN print,'property value : ',L
  
  endelse
  
; END of Property 
;--------------------------------------------------
property_str = {name: property_name, value:L}

return,property_str

end