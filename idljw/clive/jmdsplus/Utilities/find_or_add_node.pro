function find_or_add_node,  node,  expt = expt, usage = usage, close = close, $
                            quiet = quiet,  shotno = shotno, status=status
;
; assumes database is open
; checks for existence of specified node
; if found, return,1
; if not found, create it and return, 0
; default usage is SIGNAL
;
if n_params() eq 0 then message, "please supply node name"

  default, expt,  mdsvalue('$expt()')
  default,  shotno,  mdsvalue('$shot()')
;  default,  usage, 'signal'

  name = mdsvalue('GETNCI('+node+',"FULLPATH")',quiet=quiet,status=status)
  exist =  name ne '*'

  if not exist then begin
     mdstcl,'edit '+expt+' /shot='+strtrim(shotno, 2)
     if not keyword_set(quiet) then print, 'Creating node:', node
     if keyword_set(usage) then begin
;        if strupcase(usage) eq 'CHILD' then $
;         mdstcl,'add node '+node else $
         mdstcl,'add node '+node+' /usage='+usage
       end else mdstcl,'add node '+node
;     if keyword_Set(close) then begin
        mdstcl, 'write'
        mdsclose, expt, shotno
        mdsopen, expt, shotno
;     end
  end

return, exist

end

