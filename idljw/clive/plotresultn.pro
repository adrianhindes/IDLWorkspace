pro plotresultn,sh,path=path

if !version.os eq 'Win32' then default,path,'D:\MSE_2015_IMAGES'
mdsopen,'mse_2015_prc',sh
print,1
y=mdsvalue('ANGLESLICE')
print,2
t=mdsvalue('DIM_OF(ANGLESLICE,0)')
r=mdsvalue('DIM_OF(ANGLESLICE,1)')
if !version.release eq '6.1' then begin


endif else begin
  
;  y=abs(y)
a=contour((transpose(y))>(-20)<20,t,r,/fill,rgb_table=70,xtitle='time (s)',ytitle='R (cm)',buffer=1,c_value=linspace(-20,20,41),title=string('#',sh,format='(A,I0)'))
c=colorbar()
default,path,'.'
a.save, path+'/angle_'+string(sh,format='(I0)')+'.png'
endelse


end

