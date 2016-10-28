function create_structarr, nam, val
n=n_elements(nam)
for i=0,n-1 do begin
   nam2=STRJOIN(STRSPLIT(nam(i),':', /EXTRACT))
   if i eq 0 then str=create_struct(nam2,val(i)) else str=create_struct(str,nam2,val(i))
endfor

return,str
end



FUNCTION xml_to_struct2::Init

common cbbxx, rlevel, rvalue
max_lev=100
rlevel=0
rvalue=ptrarr(max_lev)
   RETURN, self->IDLffxmlsax::Init()
END



PRO xml_to_struct2::characters, data
;   self.charBuffer = self.charBuffer + data
common cbbxx, rlevel, rvalue
if ptr_valid(rvalue(rlevel)) then begin
   dum=create_struct(*rvalue(rlevel),'data',data)
   ptr_free,rvalue(rlevel)
   rvalue(rlevel)=ptr_new(dum)
endif else rvalue(rlevel)=ptr_new(create_struct('data',data))

print,data
END

PRO xml_to_struct2::startElement, URI, local, strName, attrName, attrValue

common cbbxx, rlevel, rvalue
rlevel++
print,'start ',strname,rlevel
if n_elements(attrname) ne 0 then begin
   n=n_elements(attrname)
   for i=0,n-1 do print,'attr ',attrname(i),'=',attrvalue(i)
   dum=create_structarr(attrname,attrvalue)
;help,dum
   rvalue(rlevel)=ptr_new(dum)
;   print, attrname
;   print,attrvalue
endif

END


PRO xml_to_struct2::EndElement, URI, Local, strName
common cbbxx, rlevel, rvalue

common cbyy, dupindex
;if ptr_valid(rvalue(rlevel)) eq 0 then rvalue(rlevel)=ptr_new(
print,'end ',strname,rlevel
rlevel--
if  ptr_valid(rvalue(rlevel+1)) eq 1 then begin
   if ptr_valid(rvalue(rlevel)) then begin
      idx=where(strupcase(strname) eq tag_names(*rvalue(rlevel)),count)
      if idx(0) eq -1 then begin
         strnametmp = strname 
         dupindex = 0
      endif else begin
         dupindex=dupindex+1
         strnametmp=strname + string(dupindex,format='(I0)')
      endelse

      dum=create_struct(*rvalue(rlevel),strnametmp,*rvalue(rlevel+1)) 
   endif else $
      dum=create_struct(strname,*rvalue(rlevel+1)) 

   ptr_free,rvalue(rlevel+1)
   rvalue(rlevel+1)=ptr_new()
   if ptr_valid(rvalue(rlevel)) then ptr_free,rvalue(rlevel)
   rvalue(rlevel)=ptr_new(dum)
endif




END


FUNCTION xml_to_struct2::GetArray

print,'called getarray'

common cbbxx, rlevel, rvalue
;stop
;      RETURN, -1 
return, *rvalue(0)
END


PRO xml_to_struct2__define
   void = {xml_to_struct2, $u
            INHERITS IDLffXMLSAX ,pstr:ptr_new() }

END
;help,dum.speformat.datahistories.datahistory.origin.experiment.devices.cameras.camera.intensifier.gain
