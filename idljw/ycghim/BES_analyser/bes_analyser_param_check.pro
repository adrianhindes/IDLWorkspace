;===================================================================================
;
; This file contains following functions and procedures to check parameters of
;   bes_analyser:
;
;  1) bes_analyser_ver_check
;     --> check whether newer version bes_analyser is available.
;  2) is_valid_str_to_be_number
;     --> check if the specified string is valid to be number type
;  3) is_vaild_time_file
;     --> chekc if the specified file is valid as a time file.
;
;===================================================================================





;===================================================================================
; Check the version of the bes_analyser.
; Version history is saved under 
;   ~yckim/BES/BES_Widgets/widget_ver_log/bes_analyser_version_log.txt
;   and the first line of the file contains the most up-to-date version number.
;===================================================================================
; Return value
;  0: if failed to read the bes_analyser_version_log.txt file
;  1: if succeeded to read the bes_analyser_version_log.txt file
;===================================================================================
; Note:
;   Even if the running bes_analyser version is not most up-to-date,
;   it is possible to run the program.  Thus, do not stop running the program.
;   But, provide a user warning if the version is not up-to-date.
;===================================================================================
function bes_analyser_ver_check, cur_ver

  return_result = 1

; read the version log file.
; Note: the first line contains the most up-to-date version number.
  ver_log_file = '~yckim/BES/BES_Widgets/widget_ver_log/bes_analyser_version_log.txt'
  openr, in, ver_log_file, /get_lun, error = err
  if err ne 0 then begin
    return_result = 0
    print, ''
    print, !error_state.msg
    print, 'Failed to open ' + ver_log_file + ' to check the version of the bes_analyser.'
    print, 'Report to Young-chul Ghim(Kim).'
    print, ''
  endif else begin
  ; get the most up-to-date version number from the file.
    line = ''
    readf, in, line
    up_to_date_ver = float(line)
    if cur_ver lt up_to_date_ver then begin
      print, ''
      print, 'bes_analyser v' + string(up_to_date_ver, format='(f0.1)') + ' is available.'
      print, 'Recommende to checkout the new verion!'
      print, ''
    endif
    free_lun, in
  endelse

  return, return_result

end


;===================================================================================
; Check the user specified shot number.
;   str_shot number must be able to be converted to a long type.
;===================================================================================
; Function parameter:
;   str_shot: <string> a string containing the user specified shot number
;===================================================================================
; Return value
;  0: if str_shot cannot be converted to long type
;  1: if str_shot can be converted to long type
;===================================================================================
function is_valid_str_to_be_number, str

  valid_num = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '-', '+', 'e', '_']

  str_number = strtrim(str, 2)
  str_len = strlen(str_number)
  if str_len lt 1 then $
    return, 0

  for i = 0, str_len - 1 do begin
    temp_ch = strmid(str_number, i, 1)
    temp_inx = where(temp_ch eq valid_num, count)
    if count le 0 then $
      return, 0
  endfor

  return, 1

end


;===================================================================================
; Check the user selected file is valid as a time file.
;   fname must have an extension of *.time.
;===================================================================================
; Function parameter:
;   fname: filename to be checked.
;===================================================================================
; Return value
;  0: Not valid. The file name does not have the proper file extension.
;  1: Valid. The file name has the proper file extenstion.
;===================================================================================
function is_vaild_time_file, fname

  extension = '.time

; check the number of characters in fname.  It must be greater than 5.
  if strlen(fname) le 5 then $
    return, 0

; check the file extension
  fname_ext = strmid(fname, 4, 5, /reverse_offset)
  if fname_ext ne extension then $
    return, 0

; fname is valid.
  return, 1

end
