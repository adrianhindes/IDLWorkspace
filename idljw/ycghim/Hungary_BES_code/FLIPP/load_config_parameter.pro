pro load_config_parameter,shot,section,parameter,datapath=datapath,data_source=data_source,$
              errormess=errormess,output_struct=output_struct,silent=silent
;****************************************************************************
;* LOAD_CONFIG_PARAMETER       S. Zoletnik    21.03.2008                     *
;*---------------------------------------------------------------------------*
;* Load data associated with one parameter from an XML configuration file    *
;*                                                                           *
;* INPUT:                                                                    *
;*   shot:      Shot number                                                  *
;*   datapath:  The data directory                                           *
;*   section:   The section of the configuration file: Beam, Geometry, ...   *
;*   parameter: The parameter name                                           *
;*   data_source: data_source as usual                                       *
;* OUTPUT:                                                                   *
;*   output_struct: An output structure typically containing the following   *
;*                  fields:                                                  *
;*     value:   The value of the parameter. Type depends on parameter type.  *
;*     unit:    The unit                                                     *
;*     comment: The comment associated with parameter (if any)               *
;*   errormess: error message or ''                                          *
;*   /silent:   Do not print error message just return.                      *
;*****************************************************************************


errormess = ''
default,data_source,fix(local_default('data_source'))
default,datapath,local_default('datapath')
default,config_path,local_default('config_path')

if (not keyword_set(shot)) then begin
  errormess = 'No shot number is set.'
  if (not keyword_set(silent)) then print,errormess
  return
endif

if ((data_source eq 25) or (data_source eq 29) or (data_source eq 32) or (data_source eq 33) or (data_source eq 34) $
or (data_source eq 35) or (data_source eq 39) or (data_source eq 40)  or (data_source eq 41) or (data_source eq 42))then begin  
; TEXTOR, CXRS BES or KSTAR or JET KY6D or COMPASS LiBES or EAST-Li BES or EAST BES ; Define a nullobject
  nullobject = OBJ_NEW()
  ; Open the configuration file
  ; Define a new XML object
  oConfig = OBJ_NEW('IDLffXMLDOMDocument')
  forward_function dir_f_name
  if (data_source eq 34) then begin
    ;default,config_path,local_default('config_path')
    config_file = dir_f_name(datapath,dir_f_name(i2str(shot),dir_f_name('info',i2str(shot)+'_config_apd.xml')))
    if ~file_test(config_file) then config_file = dir_f_name(dir_f_name(datapath,'calibration'),dir_f_name(i2str(shot),dir_f_name('info',i2str(shot)+'_config_apd.xml')))
  endif else begin
    if (data_source eq 35) then begin
      shot_cent=shot/100
      config_file = dir_f_name(dir_f_name(dir_f_name(datapath,i2str(shot_cent)),i2str(shot)),i2str(shot)+'_config.xml')
    endif else begin
      if (data_source eq 42) then begin
        config_file = dir_f_name(datapath,dir_f_name(i2str(shot),dir_f_name('info',i2str(shot)+'_config_abp.xml')))
      endif else begin  
        config_file = dir_f_name(datapath,dir_f_name(i2str(shot),i2str(shot)+'_config.xml'))
      endelse
    endelse
  endelse
  if (data_source eq 33) or (data_source eq 41) then begin
    ;default,config_path,local_default('config_path')
    config_file = dir_f_name(datapath,dir_f_name(i2str(shot),i2str(shot)+'_config.xml'))
    if ~file_test(config_file) then config_file = dir_f_name(datapath,dir_f_name(i2str(shot),i2str(shot)+'_shotSettings.xml'))
    if ~file_test(config_file) then config_file = dir_f_name(datapath,dir_f_name(i2str(shot),'shotSettings.xml'))
  endif
  ; Error handling for file open
  catch,error
  if (error ne 0) then begin
    catch,/cancel
    OBJ_DESTROY, oConfig
    oConfig = OBJ_NEW('IDLffXMLDOMDocument')
    ; Try under info/
    config_file1 = dir_f_name(datapath,dir_f_name(dir_f_name(i2str(shot),'info'),i2str(shot)+'_config.xml'))
    catch,error
    if (error ne 0) then begin
      catch,/cancel
      OBJ_DESTROY, oConfig
      oConfig = OBJ_NEW('IDLffXMLDOMDocument')
      ; Try under original directory as well at AUG
      config_file2 = dir_f_name(datapath,dir_f_name(i2str(shot),i2str(shot)+'_config.xml'))
      catch,error
      if (error ne 0) then begin
        errormess = 'Cannot open configuration file: '+config_file+' or '+config_file1+' or '+config_file2
        if (not keyword_set(silent)) then print,errormess
        catch,/cancel
        OBJ_DESTROY, oConfig
        return
      endif
      oConfig->Load,FILENAME=config_file2
      catch,/cancel
    endif else begin
    oConfig->Load,FILENAME=config_file1
    catch,/cancel
    endelse
  endif else begin
    openr,unit,config_file,error=e,/get_lun
    if (e ne 0) then begin
      errormess='Cannot open configuration file: '+config_file
      if (not keyword_set(silent)) then print,errormess
      catch,/cancel
      OBJ_DESTROY,oConfig
      return
    endif
    close,unit & free_lun,unit
    oConfig->Load,FILENAME=config_file
    catch,/cancel
  endelse
  
  if (data_source eq 25) then begin
    expected_experiment = 'TEXTOR BES'
  endif
  if (data_source eq 29) then begin
    expected_experiment = 'CXRS-APDCAM'
  endif
  if (data_source eq 32) then begin
    expected_experiment = 'KSTAR BES'
  endif
  if (data_source eq 33) then begin
    expected_experiment = 'JET KY6D'
  endif
  if (data_source eq 34) then begin
    expected_experiment = 'COMPASS-APDCAM'
  endif
  if (data_source eq 35) then begin
    expected_experiment = 'AUG Li-BES'
  endif
  if (data_source eq 39) then begin
    expected_experiment = 'EAST Li-BES'
  endif
   if (data_source eq 40) then begin
    expected_experiment = 'EAST BES'
  endif  
  if (data_source eq 41) then begin
    expected_experiment = 'JET KY6D'
  endif
  if (data_source eq 42) then begin
    expected_experiment = 'COMPASS-abp'
  endif
endif else begin
  errormess = 'Don not know where to find XML config file.'
  if (not keyword_set(silent)) then print,errormess
  return
endelse
   ; data_source eq 25 or 29 or 32...

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

; Get Experiment attribute
oExp = oAttributes->GetNamedItem('Experiment')
if (oExp eq OBJ_NEW()) then begin
  errormess = 'Cannot find experiment attribute in ShotSettings.'
  if (not keyword_set(silent)) then print,errormess
  return
endif
  ; Check if Experiment attribute is right
if (oExp->GetNodeValue() ne expected_experiment) then begin
  errormess = 'Incorrect experiment in config file.'
  if (not keyword_set(silent)) then print,errormess
  return
endif

; Get the section element of ShotSettings
oTags = oShotSettings->GetElementsByTagName(section)
if (oTags->GetLength() eq 0) then begin
  errormess = 'Section "'+section+'" not found in configuration file.'
  if (not keyword_set(silent)) then print,errormess
  return
endif
oSection = oTags->Item(0)

; Get parameter
oTags = oSection->GetElementsByTagName(parameter)
if (oTags->GetLength() eq 0) then begin
  errormess = 'Cannot find parameter "'+parameter+'" in configuration file.'
  if (not keyword_set(silent)) then print,errormess
  return
endif
oParameter = oTags->Item(0)
oAttributes = oParameter->getAttributes()

; Get N_values
oVal = oAttributes->GetNamedItem('N_values')
if (oVal eq OBJ_NEW()) then begin
  n_values = 0 ; scalar value
endif else begin
  n_values = fix(oVal->GetNodeValue())
endelse

if (n_values eq 0) then begin
  ; Get Value of parameter
  oVal = oAttributes->GetNamedItem('Value')
  if (oVal eq OBJ_NEW()) then begin
    errormess = 'Cannot find value attribute of parameter "'+parameter+'"'
    if (not keyword_set(silent)) then print,errormess
    return
  endif
  value = oVal->GetNodeValue()
endif else begin
  value = strarr(n_values)
  for i=1,n_values do begin
    oVal = oAttributes->GetNamedItem('Value_'+i2str(i))
    if (oVal eq OBJ_NEW()) then begin
      errormess = 'Cannot find value_'+i2str(i)+' attribute of parameter "'+parameter+'"'
      if (not keyword_set(silent)) then print,errormess
      return
    endif
    value[i-1] = oVal->GetNodeValue()
  endfor
endelse
oType = oAttributes->GetNamedItem('Type')
if (oType eq OBJ_NEW()) then begin
  type = 'string'
endif else begin
  type = oType->GetNodeValue()
endelse

strreplace,value,',','.'

if (strlowcase(type) eq 'float') then value = float(value)
if (strlowcase(type) eq 'int') then value = fix(value)
if (strlowcase(type) eq 'long') then value = long(float(value))

oUnit = oAttributes->GetNamedItem('Unit')
if (oUnit eq OBJ_NEW()) then begin
  unit = ''
endif else begin
  unit = oUnit->GetNodeValue()
endelse

oComment = oAttributes->GetNamedItem('Comment')
if (oComment eq OBJ_NEW()) then begin
  comment = ''
endif else begin
  comment = oComment->GetNodeValue()
endelse

output_struct = create_struct('value',value,'type',type,'unit',unit,'comment',comment)


OBJ_DESTROY, oConfig

end
