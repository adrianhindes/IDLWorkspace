function read_mse_process_settings, shotno, tree=tree

default, tree, 'mse_2013'
default, s, default_mse_2013_settings()

mdsopen, tree, shotno
mdssetdefault, '.settings', status=status, /quiet
if not status then begin
  print,"Can't find .SETTINGS at shotno "+strtrim(shotno,2)
  mdsclose
  return, -1
end

tn = tag_names(s)
for i = 0, n_elements(tn)-1 do begin
   tag = tn[i]
   node =  ':'+tn[i]
   val = mdsvalue( node, /quiet, status=status )
   if status then s.(i) = val
end

mdsclose, tree, shotno
s.tree = tree

return, s

end
 