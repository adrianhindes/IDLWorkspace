function eplot,x,y,name=name

if(n_params()ne 2) then begin
 message, 'usage:eplot,x,y'
 endif

if(n_elements(x)eq 0) then $
message, 'argument x is undefined'

if(n_elements(y)eq 0) then $

message, 'argument y is undefined'

If(n_elements(name)eq 0) then name='haitao'
q=plot(x,y)
date=systime()
xyouts, 0.0,0.8,name, align=0.0, /normal
xyouts, 0.0,0.0, date,align=0.0, /normal
return,q
end