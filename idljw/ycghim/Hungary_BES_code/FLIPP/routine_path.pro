function routine_path,name,functions=functions
  ;***********************************************************************
  ;;*  ROUTINE_PATH                              S. Zoletnik  26.02.2014 *
  ;* Returns the path of the source code of the named routine.           *
  ;* INPUT:                                                              *
  ;*   name: Name of the routine or function                             *
  ;*   /functions: The routine is a function                             *
  ;* Return:                                                             *
  ;*   The path as as tring including the last separator character.      *
  ;***********************************************************************
  s=routine_info(name,/source,functions=functions)
  ind = where(strupcase(s.name) eq strupcase(name))
  if (ind[0] lt 0) then return,''
  if (!version.os eq 'Win32') then begin
    sep = '\'
  endif else begin
    sep = '/'
  endelse
  if (not defined(sep)) then begin
    print,'Unknown operating system (routine_path.pro)'
    return,''
  endif
     
  p =  s[ind[0]].path
  str = strsplit(p,sep)
  n = n_elements(str)
  if (str[n-1]-1) lt 0 then return,p
  p = strmid(p,0,str[n-1])
  return,p
 end 
