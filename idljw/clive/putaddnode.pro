pro putaddnode,node,value,time,units=units
  mdstcl, 'add node '+node+' /usage=signal',/quiet

      str2 = 'build_with_units($,"Seconds")'
;      find_or_create_node, data.name, usage='signal', quiet=quiet
;      find_or_create_node, ':'+data.name, usage='signal', quiet=quiet
      str1 = 'build_with_units($value,"'+string(units)+'")'
      str = "build_signal("+str1+",$,"+str2+")"
      mdsput, node, str, reform(value), reform(time), quiet=quiet, status=status
;      mdsput, node, '$', reform(value);, quiet=quiet, status=status

   end

