function totaldim, var, dim,transpose=transpose
nvdim=size(var,/n_dim)
nd=n_elements(dim)
rval=var
for i=nd-1,0,-1 do begin
    if dim(i) ge 1 then begin
        if i+1 le nvdim then rval=total(rval,i+1)
    endif
endfor
rv=reform(rval)
if keyword_set(transpose) then rv=transpose(rv)
return,rv
end

