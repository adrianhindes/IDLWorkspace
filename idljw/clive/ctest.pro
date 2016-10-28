function mmod,x
return,(x+!pi) mod (2*!pi) - !pi
end




psi=linspace(0,2*!pi,100)
epsilon=replicate(25*!dtor,100)
cv2non,psi,epsilon,chi,delta
plot,cos(chi)
oplot,cos(psi)*cos(epsilon),col=2
wait,1
plot,sin(chi)*cos(delta)
oplot,sin(psi)*cos(epsilon),col=2
wait,2
plot,sin(chi)*sin(delta)
oplot,sin(epsilon),col=2
;plot,delta,psym=-4
end

