pro mdsclean, tree, shotno, quiet=quiet

if n_params() ne 2 then begin
  print,'Must supply tree and shotno'
  return
end

   mdstcl, 'set tree '+tree
   mdstcl,'clean '+tree+'/shot='+strtrim(shotno,2)+'/override'
  wait, 1.
  
end
 