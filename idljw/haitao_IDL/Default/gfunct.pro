PRO gfunct, X, A, F,pder
   
  pix=480+findgen(1024)*12/1023
  t=pix[480:600]
  cons=(pix(600)-pix(480))/(2*120)
  beg_exp=A(0)*exp((x-A(2)-t(0))^2)/(2*A(1))
  end_exp=A(0)*exp((x-A(2)-t(120))^2)/(2*A(1))
  term0=cons*(beg_exp+A(3))
  termn=cons*(end_exp+A(3))
 term=make_array(119,/float)
  for i=1,119 do begin
    p=A(0)*exp((x-A(2)-t(i))^2)/(2*A(1))
    j=i-1
    term(j)=2*cons*(p+A(3))
    endfor
 s=total(term)   
 F =term0+termn+s
 
 
 df0_term0=cons*exp((x-A(2)-t(0))^2)/(2*A(1))
 df0_termn=cons*exp((x-A(2)-t(120))^2)/(2*A(1))
 df0_term=make_array(119,/float)
 for i=1,199 do begin
 q=exp((x-A(2)-t(i))^2)/(2*A(1))
 df0_term(i-1)=2*cons*q
 endfor
 s0=total(df0_term)
df0=df0_term0+df0_termn+df0_term

df1_term0=-cons*A(0)*exp((x-A(2)-t(0))^2)/(2*A(1))*(x-A(2)-t(0))^2/(2*A(1)^2)
df1_termn=-cons*A(0)*exp((x-A(2)-t(120))^2)/(2*A(1))*(x-A(2)-t(120))^2/(2*A(1)^2)
df1_term=make_array(119,/float)
for i=1,119 do begin
  h=A(0)*exp((x-A(2)-t(i))^2)/(2*A(1))*(x-A(2)-t(i))^2/(2*A(1)^2)
  df1_term(i-1)=-2*cons*h
  endfor
 s1=total(df1_term) 
 df1=df1_term0+df1_termn+s1
 
 
 df2_term0=-2*cons*A(0)*exp((x-A(2)-t(0))^2)/(2*A(1))*(x-A(2)-t(0))
 df2_termn=-2*cons*A(0)*exp((x-A(2)-t(120))^2)/(2*A(1))*(x-A(2)-t(120))
 df2_term=make_array(119,/float)
 for i=1,199 do begin
  k=A(0)*exp((x-A(2)-t(i))^2)/(2*A(1))*(x-A(2)-t(i))
  df2_term(i-1)=-4*cons*k
  endfor
 s2=total(df2_term)
 df2=df2_term0+df2_termn+s2
 
IF N_PARAMS() GE 4 THEN $

    pder = [[df0], [df1],[df2], [replicate(1.0, N_ELEMENTS(X))]]

END




  stop

END

