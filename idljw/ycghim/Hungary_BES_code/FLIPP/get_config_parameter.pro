; ************************************************************************
; * GET_CONFIG_PARAMETER.PRO                                             *
; *----------------------------------------------------------------------*
; *     01.03.2000                       S. Zoletnik                     *
; *----------------------------------------------------------------------*
; * Reads configuration parameters from config_file (see below)          *
; * Config file structure is ASCII, 1 parameter/line:                    *
; *     <parname> <value> <comment>                                      *
; *     Parameter values cannot contain whitespace characters.           *
; * The program searches for the first occurrance of the specified       *
; * parameter and returns it's value as a string.                        *
; * INPUT:                                                               *
; *   config_file: name of configuration file                            *
; *   parname: name of the parameter                                     *
; * OUTPUT:                                                              *
; *   errormess: Error message or '' if operation was                    *
; *              successfull                                             *
; ************************************************************************
function get_config_parameter,config_file,parname,errormess=errormess

errormess=''

openr,unit,config_file,/get_lun,error=error
if (error ne 0) then begin
  errormess='Cannot open configuration file '+config_file
  return,''
endif

on_ioerror,err

found=0
line=1
while (found eq 0) do begin
  txt=''


  readf,unit,txt
  txt=strtrim(txt,2)
  txt=strcompress(txt)
  p=str_sep(txt,' ')
  if (n_elements(p) lt 2) then begin
    errormess='Bad format in config file '+config_file+', line'$
              +i2str(line)+'.'
    close,unit & free_lun,unit
    return,0
  endif
  if (strlowcase(p(0)) eq strlowcase(parname)) then begin
    close,unit & free_lun,unit
    return,p(1)
  endif
  line = line+1
endwhile

err:
close,unit & free_lun,unit
errormess='Cannot find parameter <'+parname+$
          '> in config file '+config_file+'.'
return,0
end

