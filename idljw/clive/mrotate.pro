pro mrotate,img,g,ang
imgtmp=img
img(*,*,1)=imgtmp(*,*,1)* cos(2*ang) + imgtmp(*,*,2) * sin(2*ang)
img(*,*,2)=-imgtmp(*,*,1)* sin(2*ang) + imgtmp(*,*,2) * cos(2*ang)
;img(*,*,1)=imgtmp(*,*,1)* cos(2*ang) - imgtmp(*,*,2) * sin(2*ang)
;img(*,*,2)=imgtmp(*,*,1)* sin(2*ang) + imgtmp(*,*,2) * cos(2*ang)

g=g+ang
end

