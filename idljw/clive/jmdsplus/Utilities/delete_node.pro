;************************************************************************
PRO  delete_node, node, status = status, quiet=quiet, $
                 tree = tree,  shotno = shotno
;   
; routine to open a tree and delete the specified node
;
if not keyword_set(tree) then begin
   tree = mdsvalue('$expt()',status=status,/quiet) 
   if tree eq '' then tree = 'H1DATA'
end
tree = strupcase(tree)
node = strupcase(node)
default, shotno,  mdsvalue('current_shot($)', tree, quiet=quiet, stat=status)

  mdsopen, tree,  shotno

  mdstcl,'edit '+tree+' /shot='+strtrim(shotno, 2)

  message =  'Delete node:'+node
  message =  [message, 'At shotno:'+strtrim(shotno, 2)]
   
  if not keyword_set(quiet) then $
   ok = dialog_message(message, /question)
  if ok eq 'No' then return
  mdstcl,'delete node '+node
  print, 'Deleted node '+node

  mdstcl, 'write'

  mdsclose, tree,  shotno
  
end

