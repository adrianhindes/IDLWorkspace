Pro nebula_adaselements,element,fileadf21,fileadf22,fileadf22e

fileadf21=strarr(n_elements(element)+1)
fileadf22=fileadf21
fileadf22e=fileadf21

hm=getenv('HOME')

fileadf21[0]=hm+'/adas/adas/adf21/bms98#h/bms98#h_h1.dat'
fileadf22[0]=hm+'/adas/adas/adf22/bmp97#h/bmp97#h_2_h1.dat'
;fileadf22e[0]='/home/adas/adas/adf22/bme97#h/bme97#h_h1.dat'       ;stu
;fileadf22e[0]=hm+'/adas/adas/adf22/bme98#h/bme98#h_h1.dat'       
fileadf22e[0]=hm+'/adas10/bes_adas310_h1_h_n3_n2.dat'
for i=0,n_elements(element)-1 do begin       
 if(element[i] eq 'he')then begin
  fileadf21(i+1)=hm+'/adas/adas/adf21/bms97#h/bms97#h_he2.dat'
  fileadf22(i+1)=hm+'/adas/adas/adf22/bmp97#h/bmp97#h_2_he2.dat'
  fileadf22e(i+1)= hm+'/adas/adas/adf22/bme97#h/bme97#h_h1.dat'   
 endif 
 if(element[i] eq 'c')then begin
  fileadf21(i+1)=hm+'/adas/adas/adf21/bms97#h/bms97#h_c6.dat'
  fileadf22(i+1)= hm+'/adas/adas/adf22/bmp97#h/bmp97#h_2_c6.dat'
  fileadf22e(i+1)= hm+'/adas/adas/adf22/bme97#h/bme97#h_h1.dat'   
 endif
 if(element[i] eq 'be')then begin
  fileadf21(i+1)=hm+'/adas/adas/adf21/bms97#h/bms97#h_be4.dat'
  fileadf22(i+1)= hm+'/adas/adas/adf22/bmp97#h/bmp97#h_2_be4.dat'
 endif
 if(element[i] eq 'f')then begin
  fileadf21(i+1)=hm+'/adas/adas/adf21/bms97#h/bms97#h_f9.dat'
  fileadf22(i+1)= hm+'/adas/adas/adf22/bmp97#h/bmp97#h_2_c6.dat'
 endif
 if(element[i] eq 'li')then begin
  fileadf21(i+1)=hm+'/adas/adas/adf21/bms97#h/bms97#h_li3.dat'
  fileadf22(i+1)= hm+'/adas/adas/adf22/bmp97#h/bmp97#h_2_li3.dat'
 endif
 if(element[i] eq 'n')then begin
  fileadf21(i+1)=hm+'/adas/adas/adf21/bms97#h/bms97#h_n7.dat'
  fileadf22(i+1)= hm+'/adas/adas/adf22/bmp97#h/bmp97#h_2_n7.dat'
 endif
 if(element[i] eq 'ne')then begin
  fileadf21(i+1)=hm+'/adas/adas/adf21/bms97#h/bms97#h_ne10.dat'
  fileadf22(i+1)= hm+'/adas/adas/adf22/bmp97#h/bmp97#h_2_ne10.dat'
 endif
 if(element[i] eq 'o')then begin
  fileadf21(i+1)=hm+'/adas/adas/adf21/bms97#h/bms97#h_o8.dat'
  fileadf22(i+1)= hm+'/adas/adas/adf22/bmp97#h/bmp97#h_2_o8.dat'
 endif
  if(element[i] eq 'b')then begin
  fileadf21(i+1)=hm+'/adas/adas/adf21/bms97#h/bms97#h_b5.dat'
  fileadf22(i+1)= hm+'/adas/adas/adf22/bmp97#h/bmp97#h_2_c6.dat'
 endif
endfor
       
End
