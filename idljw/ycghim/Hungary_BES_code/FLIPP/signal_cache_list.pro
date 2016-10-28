pro signal_cache_list,list=list,silent=silent,errormess=errormess
;***********************************************************************************
;* PRO SIGNAL_CACHE_LIST                         S. Zoletnik    17.08.2008         *
;*---------------------------------------------------------------------------------*
;* Lists the signals in the signal cache. The list is returned in a struct array   *
;* and printed on the screen. (Unless /silent is set.)                             *
;*                                                                                 *
;* Arguments to SIGNAL_CACHE_LIST:                                                 *
;* INPUT:                                                                          *
;*  /silent: Do not list on the screen.                                            *
;* OUTPUT:                                                                         *
;*  list: A struct array with the list. Undefined if cache is empty.               *
;*  errormess: Error message or ''.                                                *
;***********************************************************************************

errormess = ''

n_cache = 300
command = 'common signal_cache'
for i=1,n_cache do begin
  command = command+',c'+i2str(i)
endfor
if (not execute(command)) then return

signal_counter = 0
for i=1,n_cache do begin
  command = 'res = defined(c'+i2str(i)+')'
  if (not execute(command)) then return
  if res then begin
    command = 'empty = c'+i2str(i)+'.empty'
    if (not execute(command)) then return
    if (not empty) then begin
      command = 'c = c'+i2str(i)
      if (not execute(command)) then return
      if (finite(c.time[0])) then begin
        starttime = c.time[0]
        endtime = c.time[n_elements(c.time)-1]
      endif else begin
        starttime = c.starttime
        endtime = c.starttime + c.sampletime*(n_elements(c.data)-1)
      endelse
      l = {name:c.name, n_data: n_elements(c.data), starttime:double(starttime), endtime: double(endtime)}
      if (signal_counter eq 0) then begin
        list = l
      endif else begin
        list = [list,l]
      endelse
      signal_counter = signal_counter+1
   endif
  endif
endfor

if (not keyword_set(silent)) then begin
  if (not defined(list)) then begin
    print,'Signal cache is empty.'
  endif else begin
    print,'Name                                     n_data       start       end'
    for i=0,signal_counter-1 do begin
      if (strlen(list[i].name) lt 40) then buff = string(bytarr(40-strlen(list[i].name))+32B) else buff = ''
      print,list[i].name+buff+string(list[i].n_data,format='(I8)')+string(list[i].starttime,format='(F10.6)')+$
                         string(list[i].endtime,format='(F10.6)')
    endfor
  endelse
endif

return

end
