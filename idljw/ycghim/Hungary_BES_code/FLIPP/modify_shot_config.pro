pro modify_shot_config,shot,datapath=datapath,section=section,element=element,$
    errormess=errormess,silent=silent,overwrite=overwrite,data_source=data_source
;**********************************************************************
;* MODIFY_SHOT_CONFIG.PRO                      S. Zoletnik 4.02 2010
;* Modify or add a shot configuration file entry.
;*
;* INPUT:
;*  shot: Shot number
;*  datapath: The direcory name whete the config file is found.
;*            This is the real directory, no shoit number is added.
;*            Default is '' under the current working directory
;* section: The section in the config file where the element is
;*          to be modified/replaced
;* element: A structure describing the element:
;*          element.name: The name (string)
;*          element.type: The type (string): 'int', 'long', 'float' or 'string'
;*          element.value: The value(s/over) This will be converted to string
;*                         according to the type
;*          element.unit: The unit of the value (string) Def: 'none'
;*          element.comment: A comment (string)
;*          /overwrite: overwrite existing element
;* OUTPUT:
;*  errormess: error message or ''
;*  /silet: Errorm message is not printed
;*
;**********************************************************************
default,datapath,local_default('datapath')
default,data_source,local_default('data_source')

errormess = ''
if (not defined(section)) then begin
  errormess = 'Section not defined.'
  if (not keyword_set(silent)) then print,errormess
  return
endif
if (not defined(element)) then begin
  errormess = 'Element not defined.'
  if (not keyword_set(silent)) then print,errormess
  return
endif
if (not defined(shot)) then begin
  errormess = 'Shot number not defined.'
  if (not keyword_set(silent)) then print,errormess
  return
endif
if (size(element,/type) ne 8) then begin
  errormess = 'Element should be a structure variable.'
  if (not keyword_set(silent)) then print,errormess
  return
endif
names = tag_names(element)
if (total((strupcase(names) eq 'NAME')) eq 0 ) then begin
  errormess = 'Element.name not found.'
  if (not keyword_set(silent)) then print,errormess
  return
endif
if (total((strupcase(names) eq 'TYPE')) eq 0 ) then begin
  errormess = 'Element.type not found.'
  if (not keyword_set(silent)) then print,errormess
  return
endif
if (total((strupcase(names) eq 'VALUE')) eq 0 ) then begin
  errormess = 'Element.value not found.'
  if (not keyword_set(silent)) then print,errormess
  return
endif
if (total((strupcase(names) eq 'UNIT')) eq 0 ) then begin
  unit = 'none'
endif else begin
  unit = element.unit
endelse


case element.type of
  'float': value_str = strcompress(string(element.value,format='(F)'),/remove_all)
  'int': value_str = strcompress(string(element.value,format='(I)'),/remove_all)
  'long':  value_str = strcompress(string(element.value,format='(I)'),/remove_all)
  'string': value_str = element.value
  else : begin
    errormess = 'Unknown format.'
    if (not keyword_set(silent)) then print,errormess
    return
  endelse
endcase



nullobject = OBJ_NEW()
; Open the configuration file
; Define a new XML object
oConfig = OBJ_NEW('IDLffXMLDOMDocument')
forward_function dir_f_name
if ((data_source eq 32) or (data_source eq 25) or (data_source eq 35)) then begin
  datapath_full = dir_f_name(datapath,i2str(shot))
endif else begin
  datapath_full = datapath
endelse    

if (datapath_full ne '') then begin
  config_file = dir_f_name(datapath_full,i2str(shot)+'_config.xml')
endif else begin
  config_file = i2str(shot)+'_config.xml'
endelse


; Error handling for file open
catch,error
if (error ne 0) then begin
errormess = 'Cannot open configuration file: '+config_file
if (not keyword_set(silent)) then print,errormess
catch,/cancel
return
endif
oConfig->Load,FILENAME=config_file
catch,/cancel

; Read shotnumber to check whether this is really a config file of this shot
oTags = oConfig->GetElementsByTagName('ShotSettings')
if (oTags->GetLength() eq 0) then begin
  errormess = 'Cannot find ShotSettings in configuration file.'
  if (not keyword_set(silent)) then print,errormess
  return
endif
oShotSettings = oTags->Item(0)

; Get ShotNumber attribute
oAttributes = oShotSettings->getAttributes()
oShotNumber = oAttributes->GetNamedItem('ShotNumber')
if (oShotNumber eq OBJ_NEW()) then begin
  errormess = 'Cannot find shot number attribute in ShotSettings.'
  if (not keyword_set(silent)) then print,errormess
  return
endif
; Compare shot number withn required shot number
if (long(oShotNumber->GetNodeValue()) ne long(shot)) then begin
  errormess = 'Incorrect shot number in config file.'
  if (not keyword_set(silent)) then print,errormess
  return
endif

oTags = oConfig->GetElementsByTagName(section)
if (oTags->GetLength() eq 0) then begin
  oSection = oConfig->CreateElement(section)
  new_section = 1
endif else begin
  oSection = oTags->Item(0)
endelse


oTags = oSection->GetElementsByTagName(element.name)
if (oTags->GetLength() ne 0) then begin
  if (not keyword_set(overwrite)) then begin
    errormess = 'Set /overwrite to modify an existing element.'
    if (not keyword_set(silent)) then print,errormess
    return
  endif
   oVoid = oSection->RemoveChild(oTags->Item(0))
endif
oChild = oConfig->CreateElement(element.name)
new_element = 1
if (n_elements(value_str) ne 1) then begin
  oChild->SetAttribute,'N_values',i2str(n_elements(value_str))
  for i=1,n_elements(value_str) do begin
    oChild->SetAttribute,'Value_'+i2str(i),value_str[i-1]
  endfor
endif else begin
  oChild->SetAttribute,'Value',value_str
endelse
oChild->SetAttribute,'Type',element.type
oChild->SetAttribute,'Unit',unit
if (total((strupcase(names) eq 'COMMENT')) ne 0 ) then begin
  oChild->SetAttribute,'Comment',element.comment
endif
if (keyword_set(new_element)) then oVoid = oSection->AppendChild(oChild)

if (keyword_set(new_section)) then oVoid = oShotSettings->AppendChild(oSection)

oConfig->Save, FILENAME=config_file
OBJ_DESTROY, oConfig

end