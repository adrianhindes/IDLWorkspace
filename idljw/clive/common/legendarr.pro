pro legendarr, txt1, txt2, col=col,linesty=linesty,psym=psym,_extra=_extra

n1=n_elements(txt1)
n2=n_elements(txt2)

txt=strarr(n1*n2)
cola=fltarr(n1*n2)
lsa=fltarr(n1*n2)
k=0
if n_elements(psym) ne 0 then psa=fltarr(n1*n2)
for j=0,n2-1 do for i=0,n1-1 do  begin
    txt(k)=txt1(i)+' '+txt2(j)
    cola(k)=col(i)
    lsa(k)=linesty(j)
    if n_elements(psym) ne 0 then psa(k)=psym(j)
k=k+1
endfor


legend,txt,col=cola,linesty=lsa,textcolor=cola,psym=psa,_extra=_extra

end
