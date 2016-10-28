;************************************************************************
;+
; NAME:
;	READ_NC
;
; PURPOSE:
;	This function reads a set of variables from a ncdf file.
;	It returns all retrived data in a structure with 
;	tag_names same as variable names. The error index and error
;	message are returned in tag 'ERROR' and 'MSG'. Variable
;	names are returned in tag 'NAME' if keyword varname is set.
;	Note that this function works best for time-dependent
;	variables, e.g., those written by onetwo. If the function is
;	used to retrive other variables, do not specify time keyword.
;
; CATEGORY:
;	I/O
;
; CALLING SEQUENCE:
;	result = READ_NC (filename [,var] [,TIME=time] 
;			  [,STRUCTNAME=structname] [,/VARNAME]
;			  [,/SOURCE] [,/NEAREST_TIME])
; INPUTS:
;	FILENAME - the name of the ncdf file to read
;	VAR -	(optional)
;		an array of strings that holds the variable names
;		whose data will be retrived. If omitted, all variables
;		will be retrived.  Note that the maximum number of
;		variables to be retrived at one time is 124 
;		(limited by create_struct).
;
; KEYWORD PARAMETERS:
;	TIME - 	Set this keyword to specify the time slice for 
;		time-dependent variables.  All will be retrived
;		if omitted
;	STRUCTNAME - name of the return structure;
;		anonymous if omitted
;	VARNAME -
;		Setting this keywork will return a list of variable 
;		names available in the filename in result.NAME. 
;		There will be no real data retrival.  With this keyword, 
;		only filename has to be provided.
;	SOURCE -Returns filename used in struct.source.
;	NEAREST_TIME -
;		If set, will find the nearest time rather than exact match
;		(note that exact match has torrence of 0.001).
;
; OUTPUTS:
;	The function returns the result in a structure with first two
;	tags being ERROR and MSG, and rest holding the data.
;
; COMMON BLOCKS:
;	None
;
; SIDE EFFECTS:
;
; RESTRICTIONS:
;	The maximum number of variables that may be retrived at one time
;	is 124.  The dimension of variable to be retrived is either one 
;	for vector including scalar with one element or two for matrix.  
;	Higher dimension has not been implemented.  For a time-dependent
;	file, only time dimension may have non-limited size, and time
;	variable has to be named as 'TIME'.
;
; PROCEDURE:
;
; EXAMPLE:
;	file = 'trpltout.nc'
;	result = (file,/VARNAME)
;	name = result.NAME
;	result = (file,name[5:10])
;	help,result,/struct
;
;
; HISTORY:
;	07-30-96 created by Q.Peng (peng@gav.gat.com)
;	08-01-96 revised,variable name checking	added
;	01-16-98 catch nonfatal errors in create_struct
;		 fixed a bug to read scalar correctly when time
;		 keyword is used.
;	03-27-98 Jeff Schachter - changed ERR tag to ERROR
;	05-06-98 Jeff Schachter - return error if ncdf_open returns -1
;	05-16-98 Jeff Schachter - added SOURCE keyword, if set, returns
;		 filename used in structure.SOURCE
;	01-19-99 Q.Peng - return the whole array if time is specified but
;		 the var does not have time dimension.
;	06-23-99 Q.Peng - added NEAREST_TIME keyword to allow approximate 
;		 match when TIME is specified.
;	12-09-99 Q.Peng - check 'TIME' if 'time' is not found in the nc file
;		 per D.Baker. Removed the limit on number of vars. IDL has
;		 increased the number of structure tags allowed. 
;	01-25-2000 Q.P. - check upper case variable names if lower case fails.
;	06-13-2001 Q.P. - catch error when reading with time keyword but 
;                no time is written in file (happens for efit M file somehow)
;-
;************************************************************************

FUNCTION read_nc, filename, var, time=time, structname=structname, $
		  varname=varname, source=source, nearest_time=nearest_time

if (keyword_set(source)) then begin
  z = create_struct('error', 0, 'msg', '', $ 		; create a struct to hold 
	'source',filename)
endif else begin
  z = create_struct('error', 0, 'msg', '') 		; create a struct to hold 
endelse
						; all retrived data and errmsg
if filename ne (findfile(filename))(0) $	; if input filename
then begin					; doesnot exist, 
	z.error = -1				; return -1
	z.msg = "Cannot find "+filename+"."
	return, z
endif

id = ncdf_open(filename)			; open filename for reading
ncdf_control,id,/noverbose

if (id eq -1) then begin
	z.error = -1
	z.msg = filename+" is not a valid NetCDF file."
	return,z
endif

result = ncdf_inquire(id)
nvar = result.nvars				; get number of vars
names = make_array(nvar,/string)
for i = 0, nvar-1 do begin		
	result = ncdf_varinq(id, i)		; get and all varnames
	names(i) = result.name
endfor

if keyword_set(varname) then begin		; request for list of var names
	z = create_struct(z, 'name',names)	; put varnames in name tag
	ncdf_close, id				; close ncdf file	
	return, z				; return 0, normal
endif
						
if n_elements(var) eq 0 then begin		; if no pass-in varnames, by 
	var = strarr(nvar)			; default, retrive all vars
	for i = 0, nvar-1 do begin		; define var as a string array
	result = ncdf_varinq(id, i)		; holding full set of varnames
	var(i) = result.name
	endfor
endif

;Remove the limit, IDL increased the number of tags allowed. 
;if n_elements(var) ge 127-3 then begin		; exceeds allowed max struct
;	z.error = -4				; fields, 3 for err,msg,time
;	z.msg = "Requested too many variables.  The maximum is 124 at one time."
;	ncdf_close, id				; close ncdf file
;	return,z				; return -4
;endif
						; lower case varnames for
var = strlowcase(var)				; consistancy

if keyword_set(time) then begin			; a time is specified
timeid = ncdf_varid(id, 'time')			; retrive time 
if timeid eq -1 then timeid = ncdf_varid(id,'TIME') ; try upper case if failed

catch,error_status				; catch error in getting time
if error_status ne 0 then begin
	z.error = -4				; return -4
	z.msg = "Error reading time from "+filename+"."
	return, z
endif
ncdf_varget, id, timeid, slice
catch,/cancel

count = 1
IF Keyword_Set(nearest_time) THEN $
zz = Min(abs(float(slice)-float(time)),itime) ELSE $ 			
itime = where(abs(float(slice)-float(time)) lt 0.001, count) ; close enough
case count of 					; if asked time slice exists
0 : begin					; does not exists
	z.error = -2				; return -2
	z.msg = "File "+ filename+" does not have time "+string(time)+"."
	ncdf_close, id				; close ncdf file
	return, z
    end
1 : 	offset_time = itime(0)			; exists once, get position
else : begin					; duplicated slices
	z.error = -3				; return -3, error
	z.msg = "File "+filename+" has duplicated time slice "+string(time)+".  Report to the programmer."
	ncdf_close, id				; close ncdf file
	return, z
    end
endcase
z = create_struct(z, 'time',time)		; add time to return structure

endif else offset_time = 0			; will retrive the whole data
timeid = ncdf_varid(id, 'time')			; retrive time 
if timeid ne -1 then $
dim_time = (ncdf_varinq(id,'time')).dim else $	; get time dimension id.
dim_time = (ncdf_varinq(id,'TIME')).dim		; try upper case.

for i=0, n_elements(var)-1 do begin		; loop over all asked var

idum = where(names eq var(i),count)		; check if var exists in file
if count eq 0 then begin
   var(i) = strupcase(var(i))			; check upper case if lower
   idum = where(names eq strupcase(var(i)),count) ;     case fails
endif
if count ge 1 then begin			; skip if not

varinq = ncdf_varinq(id, var(i))		; get var info

if (where(varinq.dim eq dim_time))[0] eq -1 $	; check if var has time dim
then nodimtime = 1 else nodimtime = 0

offset = 0
case varinq.ndims of				; check var dimension
1 : begin
	if varinq.dim(0) eq 1 $
	then offset = 0 $			; scalar
	else offset = [offset_time] 		; set hyperslab for vector 
	count = [1]				; including scalar(1 element)
    end
2 : begin
	offset = [0, offset_time] 		; set hyperslab for matrix
	ncdf_diminq, id, varinq.dim(0), name, size
	count = [size, 1]	
    end
else:						; not in use (or true scalar)
endcase

if keyword_set(time) and not nodimtime $
then ncdf_varget, id, var(i), data, offset=offset,count=count $
else ncdf_varget, id, var(i), data

catch,error_status				; catch error in create_struct
if error_status ne 0 then begin
	;print,'Warning: ',!err_string,' Continue...'
	error_status = 0
	goto, pass
endif
z = create_struct(z, var(i), data)		; append data to the struct
						; set tag_name same as varname
pass:
catch,/cancel

endif
endfor

ncdf_close, id					; close filename

if keyword_set(structname) then name = structname else name = ''
z = create_struct(name=name,z)			; create a named structure

return, z					; return retrived data as  
						; whole in a structure
END

