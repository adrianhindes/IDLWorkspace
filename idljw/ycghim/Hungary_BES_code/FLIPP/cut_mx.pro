pro cut_mx,Mn,channels
; 
; cuts out those parts of the M matrix which are needed for channels
; listed in <channels>

mx_chn=sqrt((size(mn))(1))
c=fltarr(mx_chn)
chn=(size(channels))(1)
ind=where(channels gt mx_chn)
if ((size(ind))(0) ne 0) then begin
  print,'M matric contains no elements for channels:',channels(ind)
  print,'Exiting.'
  retall
endif
c(channels-1)=1
c2=fltarr(mx_chn,mx_chn)
for i=0,mx_chn-1 do c2(*,i)=c
for i=0,mx_chn-1 do c2(i,*)=transpose(c2(i,*)*c)
c1=cross2to1(c2)
ind=where(c1 ne 0)
Mn=Mn(ind,*)
end
