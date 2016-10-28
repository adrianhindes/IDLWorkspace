v1=[-414,-1739,-285.]
v2=[-700,-1863,-285.]
v3=[-1088,-2038,-285.]

v1/=norm(v1)
v2/=norm(v2)
v3/=norm(v3)
;redefine middle

v2=(v1+v3)/2
v2/=norm(v2)

C_k=v2
C_l      = crossp([0.,0.,1.],C_k)	; and the other 2 vectors of the collection lens coordinate system:
C_l      = C_l/norm(C_l)		;   the 'horizontal' vector: l=zxk/|zxk|
C_m      = crossp(C_k,C_l)		;   the 'vertical' vector  : m= kxl
C_m      = C_m/norm(C_m)

efl=100.

cl=[ total(v1 * C_l), total(v3 * C_l) ]*efl
cm=[ total(v1 * C_m), total(v3 * C_m) ]*efl

np=5
print,'k='
print,C_k
print,'l='
print,linspace(cl(0),cl(1),np)
print,'m='
print,linspace(cm(0),cm(1),np)


end


