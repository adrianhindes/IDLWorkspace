function nonan,x
idx=where(finite(x) eq 0)
y=x
if idx(0) ne -1 then y(idx)=0.
return,y
end

e=myrest2('/scratch/cam112/demod/pcmb102.sav')
t=myrest2('/scratch/cam112/demod/pcmb1009.sav')

ta=fltarr(104,24)
ea=ta

for j=0,23 do begin


ea(*,j)=e.phxs(66,*,j)-e.phxs(66,50,j)
ta(*,j)=t.phxs(66,*,j)-t.phxs(66,50,j)

;ea(*,j)=deriv(smooth(reform(nonan(e.phxs(66,*,j))),10))
;ta(*,j)=deriv(smooth(reform(nonan(t.phxs(66,*,j))),5))
plot,ea(*,j);,yr=[-.1,.1]*.1
oplot,ta(*,j),col=2


awx=1376*6.5e-6 
nx=1376
ny=1040
awy=awx * ny/nx

nyy=n_elements(e.ph1s(0,*,j))
y1=linspace(-awy/2,awy/2,nyy)

f2=50e-3 
lambda=656e-9



thy=y1/f2
;oplot,2*thy,col=4



a=''&read,'',a
endfor

contourn2,ea-ta,/cb,zr=[-.1,.1],pal=-2

end

