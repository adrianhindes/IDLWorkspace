pro compeps2, iharm1, iharm2, harm, eps1, eps2,doplot=doplot
nh=n_elements(iharm1)
harm2=harm
if keyword_set(doplot) then !p.multi=[0,ceil(sqrt(nh)),ceil(sqrt(nh))]
for i=0,nh-1 do begin
    harm2(*,i)=harm(*,i)*exp(-complex(0,1)*(eps1*iharm1(i) + eps2*iharm2(i)))
if keyword_set(doplot) then plot, float(harm(*,i)),imaginary(harm(*,i)),psym=3,xr=max(abs(harm(*,i)))*[-1,1],yr=max(abs(harm(*,i)))*[-1,1],title=string(iharm1(i),iharm2(i),format='(I0,",",I0)');,charsize=2
if keyword_set(doplot) then oplot,float(harm2(*,i)),imaginary(harm2(*,i)),col=2,psym=3
endfor
if keyword_set(doplot) then !p.multi=0
harm=harm2
end
