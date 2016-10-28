pro fft_sine
   TT=50000
   Npts=10000
   x=findgen(10000)
   t=findgen(Npts)/(Npts-1)*TT
   stop
   f_t=sin(4.*!pi*t/TT)
   !p.multi=[0,2,3]
   plot,t,f_t, title='f(t) vs t'
   A_n=fft(f_t,-1) ; complex fourier coefficients

   plot,float(A_n),yrange=[-.5,.5],title='float(A_n)'
   plot,imaginary(A_n),yrange=[-.5,.5],title='imaginary(A_n)'

   a=findgen(Npts/2+1)
   b=-reverse(findgen(Npts/2-1)+1)
   c=[a,b] ; c=[-N/2+1,-N/2+2, ...,-1,0,1,...,N/2]
   print,c
   sub=sort(c)
   plot,c(sub),float(A_n(sub)),yrange=[-.5,.5],title='float(A_n) vs n'
   plot,c(sub),imaginary(A_n(sub)),yrange=[-.5,.5], $
           title='imaginary(A_n) vs n'
   plot,c(sub),imaginary(A_n(sub)),xrange=[-5,5],$
           title='imaginary(An) vs n' ; finer x scale
           stop
   end
