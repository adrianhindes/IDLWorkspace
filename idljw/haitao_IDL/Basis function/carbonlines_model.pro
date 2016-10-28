pro carbonlines_model

;carbon ii lines
r3=0.01 ;h alpha ratio
r1=(800.0/(800+570.0))*(1.0-r3)
r2=(570.0/(800+570.0))*(1.0-r3) ;theoretical ratio of two carbonII lines
cl658=[[657.805,r1],[658.288 ,r2],[656.279,r3]]
cl465=[[464.742, 0.555366],[465.025, 0.333592],[465.147, 0.111044]];theoretaical lines and ratios of carbonIII
cl514=[[513.294, 0.1417],$
            [513.328 ,0.1417],$
            [513.726 ,0.0493],$
            [513.917 ,0.0495],$
            [514.349 ,0.1359],$
            [514.516 ,0.3275],$
            [515.109 ,0.1544]]   ;carbon 514 nm lines and ratios
;constant            
k=1.38*1e-23
ms=12*1.67*1e-27
c=3*1e8           
            
;sigle line and contrast simulation
wavel=cl658(0,0)
n=200
n1=9000
tem=findgen(n)*0.1+0.1
thickness=findgen(n1)*0.1+1.0
delb=bbo(wavel,kapa=kapa)
kapab=kapa
dell=linbo3(wavel,kapa=kapa)
kapal=kapa
wave_num=abs(thickness*1e-3*delb/(wavel*1e-9)*kapab)
tc=ms*(wavel*1e-9)^2*c^2/k/2/(!pi*kapal*dell*thickness*1e-3)^2/11600 ;charicterristic temperature
contrast=make_array(n1,n)
for i=0,n-1 do begin
  for j=0,n1-1 do begin
    contrast(j,i)=exp(-tem(i)/tc(j))
    endfor   
endfor


;complex spectrum coherence imaging
contrast_658=make_array(n1/8+1,n,/double)
phase_658=make_array(n1/8+1,n,/double)
c658_ref=cl658(0,1)
waverange=range(655.0,665.0,npts=n1)
c658_1co=(waverange-cl658(0,0))/c658_ref
c658_2co=(waverange-cl658(0,1))/c658_ref
halpha_co=(waverange-cl658(0,2))/c658_ref
for i=0,n-1 do begin
c658_fun1=r1*exp(-c658_1co^2/2/tem(i)*1.68*1d8*12.0*8.0*double(alog(2.0)))
c658_fun2=r2*exp(-c658_2co^2/2/tem(i)*1.68*1d8*12.0*8.0*double(alog(2.0)))
halpha_fun=r3*exp(-halpha_co^2/2/tem(i)*1.68*1d8*1.0*8.0*double(alog(2.0)))
fun658=c658_fun1+c658_fun2+halpha_fun
fft_658=fft(fun658)
phase=atan(fft_658,/phase)
cn=n1/8.0
phase_658=phase(0:cn)
fft_658=abs(fft_658)
contrast_658(*,i)=fft_658(0:cn)
endfor

stop
end