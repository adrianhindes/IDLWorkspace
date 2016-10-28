filtstr={nref:2.05}
thetao=atan(2570*6.5e-3/2/50.)
;thetao=sqrt(8.^2+6.^2)/200.

dlol=1-sqrt(filtstr.nref^2-sin(thetao)^2)/filtstr.nref
dl=529 * dlol

print,dl
ms=2*[8.647,7.297]
print,ms
end
