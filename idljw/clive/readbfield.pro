pro readbfield, nf=nf
default, nf, 114

openr, lun, string('/users/prl/cam112/gourdon/Data/unit17_j',nf,$
                   format='(A,I0)'),/get_lun

readf, lun, r0,r1,nr
readf, lun, z0,z1,nz
readf, lun, p0,p1,np

r=linspace(r0,r1,nr)
z=linspace(z0,z1,nz)
p=linspace(p0,p1,np)

br=fltarr(nr,nz,np)
bz=br
bphi=br

for i=0,np-1 do for j=0,nr-1 do for k=0,nz-1 do begin
    
    readf, lun, dbr,dbphi,dbz
    br(j,k,i)=dbr
    bphi(j,k,i)=dbphi
    bz(j,k,i)=dbz
endfor
bmod = sqrt(br^2+bphi^2+bz^2)
beta = atan(sqrt(br^2+bz^2),bphi)

close,lun
free_lun,lun
save, br,bz,bphi,r,z,p,file='~/prlvax/idl/gourd/bvec2.sav'
print, 'hello2'
stop
end

