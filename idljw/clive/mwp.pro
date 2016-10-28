pro mwp,img,delay
imgtmp=img
img(*,*,2)=imgtmp(*,*,2)*cos(delay) + imgtmp(*,*,3) * sin(delay)
img(*,*,3)=-imgtmp(*,*,2)*sin(delay) + imgtmp(*,*,3) * cos(delay)
;img(*,*,2)=imgtmp(*,*,2)*cos(delay) - imgtmp(*,*,3) * sin(delay)
;img(*,*,3)=imgtmp(*,*,2)*sin(delay) + imgtmp(*,*,3) * cos(delay)
end


