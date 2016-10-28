function load_experiment,experiment,silent=silent,errormess=errormess
  																								  
; ************************** LOAD_EXPERIMENT.PRO *************** 03.07.2001 ******************
;                                                 Written by S. Zoletnik
; This function reads the description of and experiment (a series of discharges) for a file
; named exp/<experiment>.exp.
; Experiment files are 4 column ASCII files:
;   <shot number>  <timefile name>  <background shot> <background timefile name>
; The function returns an array of structures.
;	
; INPUT:
;   experiment: name of the experiment (string)
;	  /silent: DO not print info and error messages
;   errormess: error message or ''  (string)
; ***************************************************************************************
		  
errormess = ''

file = dir_f_name('exp',experiment+'.exp')
openr,unit,file,error=e,/get_lun
if (e ne 0) then begin
  errormess = 'Cannot open experiment file: '+file
	if (not keyword_set(silent)) then print,errormess
	return,0
endif					  

on_ioerror,err						  

line_counter=0
while (not eof(unit)) do begin
  txt=''
  readf,unit,txt
  txt=strcompress(strtrim(txt,2))
	if ((txt ne ' ') and (txt ne '')) then begin
	  txt_arr=str_sep(txt,' ')
	  if (n_elements(txt_arr) ne 4) then begin  
		  close,unit & free_lun,unit
	    errormess = 'Bad experiment file '+file+', line '+i2str(line_counter+1) 
		  if (not keyword_set(silent)) then print,errormess
		  return,0
	  endif					  
	  												 
		exp_1 = {exp, shot: long(txt_arr(0)), $
		              timefile: txt_arr(1), $
									backshot: long(txt_arr(2)), $
									backtimefile: txt_arr(3)}
		if (line_counter eq 0) then begin
		  exp_arr = exp_1
		endif else begin
		  exp_arr = [exp_arr,exp_1]
		endelse
		line_counter = line_counter+1									
  endif
endwhile																					  
close,unit & free_lun,unit

return,exp_arr

err:
  errormess = 'Error reading from file '+file
	if (not keyword_set(silent)) then print,errormess
	close,unit & free_lun,unit
	return,0
	  
end
