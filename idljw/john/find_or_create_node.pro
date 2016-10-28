;______________________________________________________________________________
pro find_or_create_node, node, usage=usage, quiet=quiet
;assumes open for write
default, quiet, 1
name = mdsvalue('GETNCI('+node+',"FULLPATH")',quiet=quiet,status=status)
exist = size(name,/type) ne 1 and name ne '*'
;exist =  string(name) eq strupcase(node)

if exist eq 1 then begin
    issignal = mdsvalue('GETNCI('+node+',"USAGE_SIGNAL")',quiet=quiet,status=status)
    isnumeric = mdsvalue('GETNCI('+node+',"USAGE_NUMERIC")',$
                         quiet=quiet,status=status)
    if not keyword_set(usage) then goto, nocheck
    if (issignal eq 0 and usage eq 'signal') or $
       (isnumeric eq 0 and usage eq 'numeric') then begin
        mdstcl,'delete node '+node+' /noconfirm'
        exist = 0
    endif
endif
nocheck:

if exist eq 0 then begin
    if keyword_set(usage) then strextra=' /usage='+usage else strextra=''
    mdstcl,'add node '+node+strextra
endif
end


