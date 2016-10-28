pro putaddnode2d,node,value,time,r
  mdstcl, 'add node '+node+' /usage=signal',/quiet

;      str2 = 'build_with_units($,"Seconds")'
;      find_or_create_node, data.name, usage='signal', quiet=quiet
;      find_or_create_node, ':'+data.name, usage='signal', quiet=quiet
;      str1 = 'build_with_units($value,"'+string(units)+'")'
      str = "build_signal($value,$,$,$)
      mdsput, node, str, reform(value), reform(time), reform(r),quiet=quiet, status=status


   end

