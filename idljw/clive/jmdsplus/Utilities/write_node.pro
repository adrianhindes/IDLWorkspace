;************************************************************************
PRO  write_node, _node, newdata, time, channels,  $
                 status = status, quiet=quiet, $
                 tree = tree,  shotno = shotno
;   
; routine to open a tree and create/overwrite the specified node
;
if not keyword_set(tree) then begin
   tree = mdsvalue('$expt()',status=status,/quiet) 
   if tree eq '' then tree = 'H1DATA'
end
default, shotno,  mdsvalue('current_shot($)', tree, quiet=quiet, stat=status)
tree = strupcase(tree)
node = strupcase(_node)

mdsopen, tree,  shotno

tvctr = double([min(time), max(time), time(1)-time(0)])

if n_params() eq 3 then begin

   put = 0B
   exist =  find_or_add_node(_node,  usage='signal', $
                             quiet=quiet, status=status)
   str = "BUILD_SIGNAL(build_with_units($,'Arb'),*,build_with_units($ : $ : $,'seconds'))"
   
   mdsput, _node, str, newdata, tvctr(0),tvctr(1),tvctr(2),status = status

end else begin

   print, '2d writes not yet implemented'

end

print, 'Data written to '+_node
if not status then print, report_error, _node, status
put =  put or not exist
if put then mdstcl, 'write'
mdsclose, tree,  shotno

end

