;________________________________________________________
function nebula_modulus, v
sz=size(v)
if sz[0] eq 1 then begin        ;process a single vector

  return, sqrt(nebula_dot(v,v))

end else if sz[0] eq 2 then begin       ;process an array of vectors

    modv=fltarr(sz[2])
    for i=0, sz[2]-1 do modv[i]=modulus(reform(v[*,i],3))
    return, modv

end else if sz[0] eq 3 then begin

  return, sqrt(v[*,*,0]^2 + v[*,*,1]^2 + v[*,*,2]^2)

end else stop,'Cannot obtain modulus of vector array'

end
