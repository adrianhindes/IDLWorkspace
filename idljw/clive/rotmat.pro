function rotmat,ang
mat=identity(4)
mat(1,1)=cos(2*ang)
mat(1,2)=sin(2*ang)
mat(2,1)=-sin(2*ang)
mat(2,2)=cos(2*ang)
return,mat
end
