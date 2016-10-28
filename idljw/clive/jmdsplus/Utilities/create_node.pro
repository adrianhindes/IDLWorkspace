pro create_node,  expt, shotno, node, quiet = quiet, status=status,usage=usage
;
; assumes database is open
; checks for existence of specified node
; if found, return,1
; if not found, create it and return, 0
; default usage is SIGNAL
;
if n_params() ne 3 then message, "please supply tree, shotno, node name"

  mdsopen, expt, shotno
  
  name = mdsvalue('GETNCI('+node+',"FULLPATH")',quiet=quiet,status=status)
  exist =  string(name) eq strupcase(node)

  if not exist then begin
  
     mdstcl,'edit '+expt+' /shot='+strtrim(shotno, 2)

     if not keyword_set(quiet) then print, 'Creating node:', node
     if keyword_set(usage) then begin
         mdstcl,'add node '+node+' /usage='+usage,quiet=quiet
     end else mdstcl,'add node '+node, quiet=quiet
     
     mdstcl, 'write', quiet=quiet
     wait,.1
     
  end

  mdsclose, expt, shotno, quiet=quiet


end

