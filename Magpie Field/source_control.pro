pro source_control, update=update, infofile=infofile, textfile=textfile, $
   include_filter=incfilter, exclude_filter=excfilter, debug=debug, $
		    filteredlist=filtered, quiet=quiet, help=help, $
		format=format, search=search
;+
; produce a list of files to be copied or updated, typically for detecting
; local files unknowingly auto-compiled into programs, and for
; generating a clean self-contained source distribution  bdb 5/99
; Simple use - fast=track help source
;       SOURCE_CONTROL,INC='gendata' 
;  gives a "one line answer" on source file for GENDATA.PRO
;
;  resolve_all,skip=['C','mds$open','mds$close','mds$sendarg','mds$value','trnlog','dellog','doc_library','mds$set_def','mdsmemcpy']
;  TEXTFILE =  Will create a file to run a backup/pkzip (or SEARCH below)
;  SEARCH = 'string'  -->   file created in form for search and executed
; ;; Example - to put all the files used by tree_view in the one
;    directory, with dates intact   from 3665 May 31  2000 source_control.pro.4
;   SOURCE_CONTROL,INC='',exc=['IDL_DIR','ROOT:[IDL'],TEXTFILE='COPY_TREE.COM'   
;   CREAT/DIR [.TREE_VIEW_2001_7_30]
; SET DEF [.TREE_VIEW_2001_7_30]
; @[-]CPTREE
; then use PKzip to save files, and emacs to replace all '^@.*:' with @ in tagged files
;  Note:  on windows systems, you probably want to discard directory
;  info in the Zipfile
;  11/2003 - improved printout in relation to INC and EXC filters (strjoin...)
;
;-

;; source_control,inc='',form="('$sear ',a, ' mdsplus')"
default, debug, 1b
default, quiet, 0b
default, infofile, 'routine_info.xdr'
default, textfile, ''; 'routine_info.txt'
default, incfilter, ''
default, excfilter, ''
progfile='source_control'
;@helplines
if (keyword_set(search)) and (n_elements(format) eq 0) then case !version.os of
  'vms': format="('$search/heading ',a, ' "+ search +"')"
'Win32': format="('grep "+search+" ',a)"
else: message,'search on unknown OS' + !version.os
endcase
;; Note that the /heading qualifier under VMS won't work unless * or % is used

if n_elements (format) eq 0 then case !version.os of
 'Win32': format= "('pkzip -j -a idlsource.zip ',a,' ')"
 'vms': format= "('$backup ',a,' *.*')"
 'linux': format="('zip -j idlsource.zip ',a,' ')"
else: if textfile ne '' then message, "Need a format string"
endcase
  file_struct_rou=routine_info(/source) 
  file_struct_fun=routine_info(/source,/functions) 
  names=[file_struct_rou.name, file_struct_fun.name]
  print, n_elements(uniq(names, sort(names))), $
	 " compiled routines known "
  filenames=[file_struct_rou.path, file_struct_fun.path]
  idx=uniq(filenames, sort(filenames))
  sorted=filenames(idx)
; remove blanks - e.g. if there is no "main"
  nonblanks=where(sorted ne '')
  if nonblanks(0) ne -1 then sorted=sorted(nonblanks)

  filtered=sorted  ; keep all copies for debugging
; this one needs to be a union of those that match - trickier than exclude
  mask= (filtered eq filtered)  ; initialize to all ones if no includes
  if incfilter(0) ne '' then mask=0*mask ; or all 0s if there is an incfilter
  for f=0, n_elements(incfilter)-1 do if incfilter(f) ne '' then begin
    hits=strpos(strupcase(filtered), strupcase(incfilter(f)))
    w=where(hits ne -1)
    if w(0) ne -1 then mask(w)=1b
  endif  ;  loop over includes
  if max(mask) eq 0 then begin
          message,/cont,'No files found surviving filter include= '+ incfilter
          filtered=''
  endif else filtered=filtered(where (mask eq 1))
  
  for f=0,n_elements(excfilter)-1 do if excfilter(f) ne '' then begin
    hits=strpos(strupcase(filtered), strupcase(excfilter(f)))
    w=where(hits eq -1)
    if w(0) ne -1 then filtered=filtered(w) else begin 
          message,/cont,'No files found surviving filter exclude= '+ excfilter(f)
          filtered=''
    endelse	  
  endif ;  loop over excludes

  if (quiet eq 0) or (debug gt 0) and (not keyword_set(forcompile)) then print, filtered, format='("cp ",a," .")'
  if (quiet eq 0) or (debug gt 0) and keyword_set(forcompile) then print, filtered, format='("@",a)'
  if (quiet eq 0) then print,strtrim(n_elements(filtered),2)+ ' matches to ' + strjoin('"'+incfilter+'"',' or ') 
  if strjoin(excfilter) eq '' then print, 'no exclusions' else print, ' Excluding '+ strjoin('"'+excfilter+'"', ' and ') 
  if debug gt 1 then stop
  if textfile ne '' then begin
    print, 'Writing data to ', textfile
    openw, lun, /get, textfile
    printf, lun, filtered, format=format
    close, lun
    free_lun, lun
    if keyword_set(search) then spawn,'@'+textfile
  endif
end
