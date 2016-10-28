read_spe,'~/share/alex/abscal  1.spe',l,t,d1 &d1=total(d1*1L,3)
read_spe,'~/share/alex/abscal  4.spe',l,t,d0 &d0=total(d0*1L,3)
;this is for 500ms, shots are for 50.

d=d1-d0

imgplot,d,/cb
end

