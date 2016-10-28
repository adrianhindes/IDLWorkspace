function local_default,parameter,config_file=config_file,silent=silent
; ************************************************************************
; LOCAL_DEFAULT (FUNCTION)                                               *
; *----------------------------------------------------------------------*
; *     27.02.2008                       S. Zoletnik                     *
; *----------------------------------------------------------------------*
; * Reads a parameter from the local configuration file.                 *
; *                                                                      *
; * Config file structure is ASCII, 1 parameter/line:                    *
; *     <parname> <value> <comment>                                      *
; *     Parameter values cannot contain whitespace characters.           *
; * The program searches for the first occurrance of the specified       *
; * parameter and returns it's value as a string.                        *
; *                                                                      *
; * INPUT:                                                               *
; *  parameter: The name of the parameter (string)                       *
; *  config_file: The name of the configuration file in the working      *
; *               directory (default:fluct_local_config.dat)             *
; *  /silent: Do not print error message                                 *
; *                                                                      *
; * OUTPUT:                                                              *
; *   return value is the value of the configuration setting (string)    *
; *   '' is returned if the parameter is not found.                      *
; ************************************************************************
default,silent,1

default,config_file,'fluct_local_config.dat'
val = get_config_parameter(config_file,parameter,errormess=errormess)
if (errormess ne '') then begin
  if (not keyword_set(silent)) then print,errormess
  return,''
endif
return,val

end
