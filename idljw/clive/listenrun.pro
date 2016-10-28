file='~/idl/clive/listenrun.cmd'
file2='~/idl/clive/listenrundone'
again:
dum=file_search(file,count=cnt)
if cnt eq 0 then begin
   wait, 2
goto,again
endif
wait,2
openr,lun,file,/get_lun
cmd=''
readf,lun,cmd
close,lun
free_lun,lun
dum=execute(cmd)

file_delete,file
openw,lun,file2,/get_lun
printf,lun,''
close,lun & free_lun,lun

goto,again

end
