function remote_call_proc, name=name,n_args=n_args,$
                            par1,par2,par3,par4,par5,par6,par7,par8,par9,par10,$
                            key1_name=key1_name,key1_val=key1_val,$
                            key2_name=key2_name,key2_val=key2_val,$
                            key3_name=key3_name,key3_val=key3_val,$
                            key4_name=key4_name,key4_val=key4_val,$
                            key5_name=key5_name,key5_val=key5_val,$
                            key6_name=key6_name,key6_val=key6_val,$
                            key7_name=key7_name,key7_val=key7_val,$
                            key8_name=key8_name,key8_val=key8_val,$
                            key9_name=key9_name,key9_val=key9_val,$
                            key10_name=key10_name,key10_val=key10_val,$
                       rem_machine=rem_machine,rem_user=rem_user,rem_dir=rem_dir,$
                       ssh=ssh,rsh=rsh,silent=silent,call_function=func,call_proc=proc,$
                       return_value=f_ret
                     
; *****************************************************************************
; REMOTE_CALL_PROC                                28.4.2001    S. Zoletnik                      
; 
; This program can run an IDL program on another machine using ssh or rsh and
; transport arguments back and forth.
; Prerequisites:
; - The user on the local machine should have access to the remote machine with rsh or ssh
; - The following IDL programs are needed on the remote side: REMOTE_CALL_PROC_SERV.PRO
;                                                             I2STR.PRO, DEFINED.PRO
; - Both local and remote machines are Unix.
;
; remote_call_proc returns an error message or '' if no error occured.
; Up to 10 positional arguments and 10 keywords van be used. The positional arguments
; are simply listed, the keyword arguments are defined by keyx_name, keyx_val named
; argument pairs. The number of positional arguments should be given in n_args.
;
; This program can call both functions or procedures, /call_xxx defines which one to call.
; If nothing is specified a procedure call will be attempted.
;
; Example procedure call:
; 
;   r = remote_call_proc(p1,2,key1_name='out',key1_val=str,name='test_proc',n_args=2,$
;                        rem_machine='hello.where.are.you',rem_user='itsme',rem_dir='ddd'
;   This call will make an ssh call to hello.where.are.you as user itsme.
;   Will change to directory ddd, run IDL and do the following command:
;      test_proc,p1,2,out=str
;   The output values in p1 and out will be transported back in the appropriate variables.
;                       
; For a function call add a /call_function and return_value keywords.
;
; INPUT:
;  name: The name of the remote function or procedure to call
;  n_args: number of positional arguments (should be present)
;  rem_machine: Name of remote machine
;  rem_user: Name of remote user
;  rem_dir: Name of remote directory to which to cd before running the program
;  /ssh: Use ssh/scp
;  /rsh: Use rsh/rcp
;  /silent: Do not print error messages just return them
;  return_vale: The retrun value of a function call will be retruned in theis keyword argument
;  key1_name,... key10_name: The names of the keyword arguments
; INPUT/OUTPUT
;  par1,...par10: The positional arguments
;  key1_val,...key10_val: The values or variables of the keyword arguments
; ****************************************************************************                       
                                    
ret = ''
             
if (not keyword_set(proc) and not keyword_set(func)) then proc=1
if (keyword_set(proc) and keyword_set(func)) then begin
  ret = 'Only one of /call_proc or /call_function can be set in remote_call_proc.'
  if (not keyword_set(silent)) then print,ret
  return,ret
endif  

if (not defined(n_args)) then begin
  ret = 'n_args keyword for remote_call_proc must be set!'
  if (not keyword_set(silent)) then print,ret
  return,ret
endif
                                    
if (not (defined(rem_machine) and defined(rem_user))) then begin
  ret = 'rem_machine and rem_user keyword for remote_call_proc must be set!'
  if (not keyword_set(silent)) then print,ret
  return,ret
endif

default,rem_dir,'./'

if (not keyword_set(rsh) and not keyword_set(ssh)) then ssh=1
if (keyword_set(rsh)) then begin
  rsh_cmd = 'rsh'
  rcp_cmd = 'rcp'
endif else begin
  rsh_cmd = 'ssh -q '
  rcp_cmd = 'scp -q '
endelse

pid=getpid()
machine=getenv('HOST')
                            
infile='rem_proc_in_'+machine+'_'+i2str(pid)+'.tmp'
outfile='rem_proc_out_'+machine+'_'+i2str(pid)+'.tmp'
commandfile='rem_proc_'+machine+'_'+i2str(pid)+'.tmp'
                                                                                                    
cmd = 'save,name,n_args'
if ((n_args ge 1) and defined(par1)) then cmd = cmd+',par1'
if ((n_args ge 2) and defined(par2)) then cmd = cmd+',par2'
if ((n_args ge 3) and defined(par3)) then cmd = cmd+',par3'
if ((n_args ge 4) and defined(par4)) then cmd = cmd+',par4'
if ((n_args ge 5) and defined(par5)) then cmd = cmd+',par5'
if ((n_args ge 6) and defined(par6)) then cmd = cmd+',par6'
if ((n_args ge 7) and defined(par7)) then cmd = cmd+',par7'
if ((n_args ge 8) and defined(par8)) then cmd = cmd+',par8'
if ((n_args ge 9) and defined(par9)) then cmd = cmd+',par9'
if ((n_args ge 10) and defined(par10)) then cmd = cmd+',par10'

if (keyword_set(key1_name)) then cmd = cmd+',key1_name'
if (keyword_set(key2_name)) then cmd = cmd+',key2_name'
if (keyword_set(key3_name)) then cmd = cmd+',key3_name'
if (keyword_set(key4_name)) then cmd = cmd+',key4_name'
if (keyword_set(key5_name)) then cmd = cmd+',key5_name'
if (keyword_set(key6_name)) then cmd = cmd+',key6_name'
if (keyword_set(key7_name)) then cmd = cmd+',key7_name'
if (keyword_set(key8_name)) then cmd = cmd+',key8_name'
if (keyword_set(key9_name)) then cmd = cmd+',key9_name'
if (keyword_set(key10_name)) then cmd = cmd+',key10_name'

if (keyword_set(key1_name) and defined(key1_val)) then cmd = cmd+',key1_val'
if (keyword_set(key2_name) and defined(key2_val)) then cmd = cmd+',key2_val'
if (keyword_set(key3_name) and defined(key3_val)) then cmd = cmd+',key3_val'
if (keyword_set(key4_name) and defined(key4_val)) then cmd = cmd+',key4_val'
if (keyword_set(key5_name) and defined(key5_val)) then cmd = cmd+',key5_val'
if (keyword_set(key6_name) and defined(key6_val)) then cmd = cmd+',key6_val'
if (keyword_set(key7_name) and defined(key7_val)) then cmd = cmd+',key7_val'
if (keyword_set(key8_name) and defined(key8_val)) then cmd = cmd+',key8_val'
if (keyword_set(key9_name) and defined(key9_val)) then cmd = cmd+',key9_val'
if (keyword_set(key10_name) and defined(key10_val)) then cmd = cmd+',key10_val'
                       
if (keyword_set(proc)) then cmd = cmd+',proc'                                                   
if (keyword_set(func)) then cmd = cmd+',func'
                                                   
prime=string(byte(39))
cmd = cmd+',file='+prime+infile+prime

if (not execute(cmd)) then begin
  ret = 'Error saving data.'
  return,ret
endif  

; Writing a command file for IDL on the remote machine
openw,unit,commandfile,/get_lun
prime=string(byte(39))
printf,unit,'remote_call_proc_serv,'+prime+infile+prime+','+prime+outfile+prime
printf,unit,'exit'
close,unit & free_lun,unit

; Copying command, and data files to remote machine
cmd=rcp_cmd+' '+commandfile+' '+infile+' '+rem_user+'@'+rem_machine+':'+rem_dir
spawn,cmd


; Running the program on the remote machine 
prime=string(byte(39))
cmd=rsh_cmd+' '+rem_user+'@'+rem_machine+' "cd '+rem_dir+'; idl '+commandfile+'"'
spawn,cmd

; Getting the result from the remote machine
cmd=rcp_cmd+' '+rem_user+'@'+rem_machine+':'+rem_dir+'/'+outfile+' .'
spawn,cmd
      
; Erasing the files on the remote machine
prime=string(byte(39))
cmd=rsh_cmd+' '+rem_user+'@'+rem_machine+' "cd '+rem_dir+'; rm '+infile+' '+outfile+' '+commandfile+'"'
spawn,cmd

restore,outfile

; Erasing temporary files
cmd = 'rm '+commandfile+' '+infile+' '+outfile
spawn,cmd

                                                   
if (not retval) then begin
  ret = 'Error running program on remote machine: '+err_message
  if (not keyword_set(silent)) then print,ret
  return,ret
endif
  
return,ret

end
