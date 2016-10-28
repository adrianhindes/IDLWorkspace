pro writecsva, file,y
openw,lun,file,/get_lun,width=80
nr=n_elements(y(0,*))
nc=n_elements(y(*,0))
fmts='('+string(nc-1,format='(I0)')+'(A,","),A)'
for i=0L,nr-1 do begin
printf,lun,(y(*,i)),format=fmts
endfor
close,lun
free_lun,lun
print, 'saved text data to ',file
print,fmts
end
