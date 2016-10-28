

function client_defined, var, nullarray=nullarray
; returns 1 if variable exists otherwise 0
; /null: return 0 if array is set to 0

  if (((size(var))(0) eq 0) and ((size(var))(1) eq 0)) then begin
    return,0
  endif else begin
    if (keyword_set(nullarray)) then $
       if ((where(var ne 0))(0) lt 0) then return,0
    return,1
  endelse

end


function client_i2str,i_in,digits=digits
; **********************************************************************
; converts an integer to string using only as many characters as necessary
; digits: converts to at least <digits> long string by using leading zeros
;************************************************************************

; Modified in 2005. 06. 10.  by D.Dunai

sz=size(i_in)
num=n_elements(sz)

type=sz[num-2]

if (type eq 7) then begin

str=i_in
str1=''
; print, 'Argument of i2str was string type'

endif else begin

if (abs(i_in) lt 1) then begin
  if (not keyword_set(digits)) then return,'0'
  str=''
  for ii=1,digits do str=str+'0'
  return,str
endif
i=i_in
str=''
if (i lt 0) then begin
  i = -i
  str1='-'
endif   else begin
  str1=''
endelse
n=fix(alog10(i))+1
if (n lt 10) then nstr=string(n,format='(I1)') else nstr=string(n,format='(I2)')
f='(I'+nstr+')'
str=string(i,format=f)
if (keyword_set(digits)) then begin
  len=strlen(str)
  if (len lt digits) then begin
    for i=1,digits-len do str='0'+str
  endif
endif
endelse
str=str1+str
return,str
end


;******************************************************************************
;* Pipe communication routines for IDL.                                       *
;*   client_error.pro                                                         *
;*----------------------------------------------------------------------------*
;* client_error.pro function                                                  *
;* Translate a CrossControl communication error code to error string.         *
;*                                                                            *
;******************************************************************************
;* This is written based on Sandor's program                                  *
;* Writer: Young-chul Ghim(Kim)                                               *
;* Written data: 08. Dec. 2010                                                *
;******************************************************************************

function client_error, err

  case err of
    0:  return,'No error occured.'
    1:  return,'Bad configuration file.'
    2:  return,'Cannot start remote pipe program.'
    3:  return,'Cannot open communication pipes.'
    4:  return,'Error writing data to pipe.'
    5:  return,'Error reading from pipe.'
    6:  return,'Pipes are not open.'
    7:  return,'Undefined input data.'
    8:  return,'Parameter type mismatch.'
    9:  return,'Connection is already open.'
   10:  return,'Data size is different from expected size.'
   11:  return,'Invalid response from server.'
   12:  return,'Unsupported data types are used as input.'
   13:  return,'Failed to receive ACK signal.'
   14:  return,'Communication test failed.'
   15:  return,'cuFFT Failed.'
   16:  return,'CUDA correlation Failed.'
  else: return,'Unknown error code.'
  endcase

end



;******************************************************************************
;* Pipe communication routines for IDL.                                       *
;*   client_check_pipes.pro                                                   *
;*----------------------------------------------------------------------------*
;* Checks the pipes structure and returns an error code.                      *
;*                                                                            *
;* INPUT:                                                                     *
;*   pipes: pipe description structure                                        *
;* Return value:                                                              *
;*   error output (see client_error.pro)                                      *
;******************************************************************************
;* This is written based on Sandor's program                                  *
;* Writer: Young-chul Ghim(Kim)                                               *
;* Written data: 08. Dec. 2010                                                *
;******************************************************************************

function client_check_pipes, pipes

  if(not client_defined(pipes)) then $
    return, 6

  if( ( (where(tag_names(pipes) eq 'UNIT_W'))[0] lt 0 ) or $
      ( (where(tag_names(pipes) eq 'UNIT_R'))[0] lt 0 ) ) then begin
    return, 6
  endif

  if( (pipes.unit_r le 0) or (pipes.unit_w le 0) ) then begin
    return, 6
  endif

  return, 0

end  




;******************************************************************************
;* Pipe communication routines for IDL.                                       *
;*   client_get_config_parameter.pro                                          *
;*----------------------------------------------------------------------------*
;* Reads configuration parameters from config_file (see below)                *
;* Config file structure is ASCII, 1 parameter/line:                          *
;*     <parname> <value> <comment>                                            *
;*     Parameter values cannot contain whitespace characters.                 *
;* The program searches for the first occurrance of the specified             *
;* parameter and returns it's value as a string.                              *
;* INPUT:                                                                     *
;*   config_file: name of configuration file                                  *
;*   parname: name of the parameter                                           *
;* OUTPUT:                                                                    *
;*   errormess: Error message or '' if operation was                          *
;*              successfull                                                   *
;* RETURN:                                                                    *
;*   string for parname                                                       *
;******************************************************************************
;* This is written based on Sandor's program                                  *
;* Writer: Young-chul Ghim(Kim)                                               *
;* Written data: 08. Dec. 2010                                                *
;******************************************************************************

function client_get_config_parameter, config_file, parname, errormess = errormess

  errormess = ''

;open config_file to read
  openr, unit, config_file, /get_lun, error = error
  if( error ne 0 ) then begin
    errormess = 'Cannot open configuratino file ' + config_file
    return, ''
  endif

;if there is an I/O error, jump to err
  on_ioerror, err

  found = 0
  line = 1
  while(found eq 0) do begin

    txt = ''

    readf, unit, txt
    txt = strtrim(txt, 2)	;remove the leading and trailing blank spaces
    txt = strcompress(txt)	;compresses multiple blanks with one blank space
    p = str_sep(txt, ' ')	;separate the string separated by a blank space into arrays of p 

    if( n_elements(p) lt 2 ) then begin
      errormess = 'Bad format in config file ' + config_file + ', line ' + client_i2str(line) + '.'
      close, unit & free_lun, unit
      return, 0
    endif

    if( strlowcase(p[0]) eq strlowcase(parname) ) then begin
      close, unit & free_lun, unit
      return, p[1]
    endif
    
    line = line + 1

  endwhile

err:
  close, unit & free_lun, unit
  errormess = 'Cannot find parameter <'+parname+'> in config file ' + config_file + '.'
  return, ''
end


;******************************************************************************
;* Pipe communication routines for IDL.                                       *
;*   client_startup.pro                                                       *	
;*----------------------------------------------------------------------------*
;* startup procedure for IDL: opens up pipes lines                            *
;*                                                                            *
;* INPUT:                                                                     *
;*   config_file: file name that contains configuration info                  *
;*   pipes: pipe description structure                                        *
;* Return:                                                                    *
;*   1 if successful, 0 otherwise                                             *
;******************************************************************************
;* This is written based on Sandor's program                                  *
;* Writer: Young-chul Ghim(Kim)                                               *
;* Written data: 08. Dec. 2010                                                *
;******************************************************************************

function client_startup, config_file, pipes

; get configuration info for fifo_a and fifo_b
  fifo_a = client_get_config_parameter(config_file, 'FIFO_A', errormess = errormess)
  if(errormess ne '') then begin
    print, errormess
    return, 0
  endif

  fifo_b = client_get_config_parameter(config_file, 'FIFO_B', errormess = errormess)
  if(errormess ne '') then begin
    print, errormess
    return, 0
  endif

; open up the pipes 
  print, 'Opening output pipe ('+fifo_a+')...',format='(A,$)'
  openw, unit, fifo_a, /get_lun, error = error, /noauto, /binary
  if(error ne 0) then begin
    print, 'Cannot open '+fifo_a
    return, 0
  endif
  pipes.unit_w = unit
  print, 'Done'

  print, 'Opening input pipe ('+fifo_b+'). (Will block until server starts)...', format = '(A,$)'
  openr, unit, fifo_b, /get_lun, error = error, /noauto, /binary
  if(error ne 0) then begin
    close, pipes.unit_w
    free_lun, pipes.unit_w
    print, 'Cannot open '+fifo_b
    return, 0
  endif
  pipes.unit_r = unit
  print, 'Done'


  return, 1

end


;******************************************************************************
;* Pipe communication routines for IDL.                                       *
;*   client_put_data.pro                                                      *	
;*----------------------------------------------------------------------------*
;* Sends data through the communication pipes.                                *
;*                                                                            *
;* INPUT:                                                                     *
;*   pipes: pipe description structure                                        *
;*   dat: the data array                                                      *
;* OUTPUT:                                                                    *
;*   error output (see client_error.pro)                                      *
;******************************************************************************
;* This is written based on Sandor's program                                  *
;* Writer: Young-chul Ghim(Kim)                                               *
;* Written data: 08. Dec. 2010                                                *
;******************************************************************************

pro client_put_data, pipes, data, error = error

; check if pipes are open
  error = client_check_pipes(pipes)
  if(error ne 0) then $
    return

; check if data argument exists
  if( not client_defined(data) ) then begin
    error = 7
    return
  endif

; check the data type and number of elements
; type_code:
;    1: byte	(1 byte)
;    2: int	(2 bytes)
;    3: long	(4 bytes)
;    4: float	(4 bytes)
;    5: double	(8 bytes)
;    7: string
  n = n_elements(data)
  type_code = size(data)
  type_code = (type_code)[type_code[0]+1]
  if( (type_code ne 1) and (type_code ne 2) and (type_code ne 3) and $
      (type_code ne 4) and (type_code ne 5) and (type_code ne 7) ) then begin
    error = 12	;unsupported data types are used.
    return
  endif
  case type_code of
    1: s = 1
    2: s = 2
    3: s = 4
    4: s = 4
    5: s = 8
    else: begin
    end
  endcase
; if data type is string, then it needs to be converted into charaters (i.e. bytes)
  if( type_code eq 7 ) then begin
    slen = long(strlen(data))
    a = bytarr(slen)
    a[0:slen-1] = byte(data)
    a = [a, byte(0)]
    slen = long(slen+1)
    data = a
  endif else begin
    slen = long(s*n)
  endelse

; write header (i.e. slen) and data to the server (C)
  on_ioerror, put_data_werr
  writeu, pipes.unit_w, slen	;write header
  writeu, pipes.unit_w, data	;write data
  flush, pipes.unit_w

; read ACK from the server (C)
  on_ioerror, put_data_rerr
  c = byte(0)
  ack = byte(6)
  readu, pipes.unit_r, c
  if( c eq ACK ) then begin
    error = 0
    return
  endif else begin
    error = 13
    return
  endelse



put_data_werr:
  error = 4
  return

put_data_rerr:
  error = 5
  return

end




;******************************************************************************
;* Pipe communication routines for IDL.                                       *
;*   client_get_data.pro                                                      *	
;*----------------------------------------------------------------------------*
;* Reads data from the communication pipes.                                   *
;*                                                                            *
;* INPUT:                                                                     *
;*   pipes: pipe description structure			                      *
;*   var_type: specified the type of variable                                 *
;*             'byte'  : byte (1 bytes)			                      *
;*             'int'   : int  (2 bytes)                                       *
;*             'long'  : long (4 bytes)			                      *
;*             'float' ; floating (4 bytes)                                   *
;*             'double': double (8 bytes)                                     *
;*             'string': string                                               *
;* OUTPUT:                                                                    *
;*   dat: the data read                                                       *
;*   error output (see client_error.pro)                                      *
;******************************************************************************
;* This is written based on Sandor's program                                  *
;* Writer: Young-chul Ghim(Kim)                                               *
;* Written data: 08. Dec. 2010                                                *
;******************************************************************************

pro client_get_data, pipes, var_type, data, error = error

; check if pipes are open
  error = client_check_pipes(pipes)
  if(error ne 0) then $
    return


; read the header (i.e. number of bytes for data) and data from the server
  slen = long(0)
  on_ioerror, get_data_rerr
  readu, pipes.unit_r, slen
  case var_type of
    'char'  : data = bytarr(slen)
    'int'   : data = intarr(slen/2)
    'long'  : data = lonarr(slen/4)
    'float' : data = fltarr(slen/4)
    'double': data = dblarr(slen/8)
    'string': data = string(replicate(32b, slen))
    else: begin
      error = 12
      return
    end
  endcase
  readu, pipes.unit_r, data

; write ACK back to the server
  on_ioerror, get_data_werr
  ACK = byte(6)
  writeu, pipes.unit_w, ACK
  flush, pipes.unit_w

  error = 0
  return

  
get_data_werr:
  error = 4
  return

get_data_rerr:
  error = 5
  return

end
