pro write_local_kstar_node, data
 
   if n_elements(data) gt 1 then begin
      write_local_kstar_node, data[0]
      write_local_kstar_node, data[1:*]
   
    end else begin
   
      str2 = 'build_with_units($,"Seconds")'
      find_or_create_node, data.name, usage='signal', quiet=quiet
;      find_or_create_node, ':'+data.name, usage='signal', quiet=quiet
      str1 = 'build_with_units($,"'+string(data.units)+'")'
      str = "build_signal("+str1+",*,"+str2+")"
      mdsput, data.name, str, [data.data], [data.time], quiet=quiet, status=status
   
    end
    
end

