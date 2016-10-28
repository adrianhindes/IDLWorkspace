function myrest2,fil
obj = OBJ_NEW('IDL_Savefile', fil)  
;sContents = sObj->Contents()  
;PRINT, sContents.N_VAR  

names = obj->Names()  
;PRINT, names
n=n_elements(names)
for i=0,n-1 do obj->Restore, names(i)
obj_destroy,obj

strng='str={'

for i=0,n-1 do begin
    strng=strng+''+names(i)+':'+names(i)+','
endfor
strng=strmid(strng,0,strlen(strng)-1)+'}'
;print,strng
dum=execute(strng)
return,str
;return,0

end

;s=myrest2('~/pol_new1_.sav')

;end

