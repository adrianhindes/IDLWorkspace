pro writecsv, x,yp,file=file,titles=titles
y=yp
ii=where(finite(yp) eq 0)
if ii(0) ne -1 then y(ii)=0.

openw,lun,file,/get_lun,width=80
nt=n_elements(x)
nd=size(y,/n_dim)
ntit=n_elements(y(0,*))+1
fmt='('+string(ntit-1,format='(I0)')+'(G0.10,","),G0.0)' ;,"'+string(byte(10))+'")'
fmts='('+string(ntit,format='(I0)')+'(A,","),A)'

if n_elements(titles) ne 0 then printf,lun,titles,format=fmts

for i=0L,nt-1 do begin
    if nd eq 2 then printf,lun,x(i),transpose(y(i,*)),format=fmt else $
      printf,lun,x(i),y(i),format=fmt
endfor
close,lun
free_lun,lun
print, 'saved text data to ',file
print,fmt
end
