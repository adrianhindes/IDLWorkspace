pro testlock
pid=getpid()
collision=0
aaa:
print,'collision:'+i2str(collision)
lock,'aaa',20

print,'Doing job....'
openr,unit,'aaa_test',/get_lun,error=error
if (error eq 0) then begin
  collision=collision+1
  close,unit
  free_lun,unit
  print,'New collision. collision:'+i2str(collision)
endif
openw,unit,'aaa_test',/get_lun,error=error
printf,unit,pid
close,unit
free_lun,unit
for i=0,8 do begin
   wait,1
   print,'************* '+i2str(i)+' *******************'
endfor
spawn,'rm aaa_test'   
print,'..............done'

unlock,'aaa'

r=randomu(seed)*3
wait,3
goto,aaa
end
   

pro main
testlock
end
