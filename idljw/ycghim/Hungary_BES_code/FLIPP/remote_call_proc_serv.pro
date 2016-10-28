pro remote_call_proc_serv,infile,outfile

restore,infile
                      
if (keyword_set(func)) then cmd = 'f_ret='+name+'(' else cmd = name
   
for i=1,n_args do  cmd = cmd+',par'+i2str(i)

if (defined(key1_name)) then cmd = cmd+','+key1_name+'=key1_val'
if (defined(key2_name)) then cmd = cmd+','+key2_name+'=key2_val'
if (defined(key3_name)) then cmd = cmd+','+key3_name+'=key3_val'
if (defined(key4_name)) then cmd = cmd+','+key4_name+'=key4_val'
if (defined(key5_name)) then cmd = cmd+','+key5_name+'=key5_val'
if (defined(key6_name)) then cmd = cmd+','+key6_name+'=key6_val'
if (defined(key7_name)) then cmd = cmd+','+key7_name+'=key7_val'
if (defined(key8_name)) then cmd = cmd+','+key8_name+'=key8_val'
if (defined(key9_name)) then cmd = cmd+','+key9_name+'=key9_val'
if (defined(key10_name)) then cmd = cmd+','+key10_name+'=key10_val'
                                                         
if (keyword_set(func)) then begin
  cmd = cmd+')'
  strput,cmd,' ',7+strlen(name)
endif  

retval = execute(cmd)
if (not retval) then err_message = !error_state.msg
save,file=outfile

end

