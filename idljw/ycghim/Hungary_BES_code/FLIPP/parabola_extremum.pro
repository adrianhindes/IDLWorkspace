function parabola_extremum,x_array=x_array,y_array=y_array,minimum=minimum,$
fit_parabola=fit_parabola, fit_points=fit_points,y_errors=y_errors,max_error=max_error


      ; parabola_extremum.pro
      ; Calculates the extremeum point and value of a parabola fitted to the three maximum (minimum) points
      ; of an array.
      ; INPUT:
      ;   x_array->independent variable
      ;   y_arrray->input data array
      ;   y_errors: input errors (optional)
      ;   /minimum: select minimum (default is maximum)
      ;   /fit_parabola: fits all correlation points within taurange with a parabola
      ;   fit_points: number of points to fit parabola around the maximum (default value 3)
      ; OUTPUT:
      ;   [extremum_place,extremum_value]-> place and value of extremum
      ;   max_error: The error of the maximum place
      ; Returns [-1,0] if no extremeum found
      ;


max_error = 0 

 if keyword_set(fit_parabola) then begin

  p=poly_fit(x_array,y_array,2,status=s,measure_er=y_errors,covar=cov)
  if ((p[2] le 0) and not keyword_set(minimum)) or ((p[2] ge 0) and keyword_set(minimum)) then begin
   return,[x_array[0],0]
  endif
  val=(-p[1]/(2*p[2])<x_array[n_elements(x_array)-1])>x_array[0]
  max_error = sqrt(1./(4*p[2]^2)*cov[1,1]-2*p[1]/(4*p[2]^3)*cov[1,2]+p[1]^2/(4*p[2]^4)*cov[2,2])
  return,[val,p[0]+p[1]*val+p[2]*val^2]
 endif



 if not keyword_set(fit_parabola) then begin
      max_error = 0
      x=dblarr(4)
      if (keyword_set(minimum)) then begin
        x[2]=min(where(y_array eq min(y_array)))
      endif else begin
        x[2]=min(where(y_array eq max(y_array)))
      endelse
      if (x[2] eq 0) then begin
        return,[x_array[0],y_array[0]]
      endif
      if (x[2] eq n_elements(x_array)-1) then begin
        return,[x_array[n_elements(x_array)-1],y_array[n_elements(x_array)-1]]
      endif

      if (keyword_set(fit_points) or defined(y_errors)) then begin
         
         default,fit_points,3
         fit_ind=indgen(fit_points)+x[2]-fix(fit_points/2)

         fit_ind_valid=where((fit_ind ge 0) and (fit_ind le n_elements(x_array)))

         fit_ind=fit_ind[fit_ind_valid]

         x_array1=x_array(fit_ind)
         y_array1=y_array(fit_ind)
         if (defined(y_errors)) then begin
           y_errors1 = y_errors[fit_ind]
         endif  
         p=poly_fit(x_array1,y_array1,2,status=s,measure_er=y_errors,covar=cov)
          
          if ((p[2] le 0) and keyword_set(minimum)) or ((p[2] ge 0) and not keyword_set(minimum)) $
          then begin
            return,[x_array[0],0]
          endif
        val=(-p[1]/(2*p[2])<x_array[n_elements(x_array)-1])>x_array[0]
        max_error = sqrt(1./(4*p[2]^2)*cov[1,1]-2*p[1]/(4*p[2]^3)*cov[1,2]+p[1]^2/(4*p[2]^4)*cov[2,2])
        return,[val,p[0]+p[1]*val+p[2]*val^2]

      endif



      x[1]=x[2] - 1
      x[3]=x[2] + 1



      y = dblarr(4)
      y[1:3] = y_array[x[1:3]]
      x[1:3]=x_array[x[1:3]]

      Det=0*dblarr(4)
      Det[0]=(x[2]*(x[3])^2+x[1]*(x[2])^2+x[3]*(x[1])^2)-(x[2]*(x[1])^2+x[3]*(x[2])^2+x[1]*(x[3])^2)
      Det[1]=(y[1]*x[2]*x[3]^2+y[3]*x[1]*x[2]^2+y[2]*x[3]*x[1]^2)-(y[3]*x[2]*x[1]^2+y[2]*x[1]*x[3]^2+y[1]*x[3]*x[2]^2)
      Det[2]=(y[2]*x[3]^2+y[1]*x[2]^2+y[3]*x[1]^2)-(y[2]*x[1]^2+y[3]*x[2]^2+y[1]*x[3]^2)
      Det[3]=(x[2]*y[3]+x[1]*y[2]+x[3]*y[1])-(x[2]*y[1]+x[3]*y[2]+x[1]*y[3])
      if (Det[0] eq 0) then begin
        return,[-1,0]
      endif
      av=0*dblarr(4)
      av[1]=Det[1]/Det[0];
      av[2]=Det[2]/Det[0];
      av[3]=Det[3]/Det[0];

      if (Det[3] eq 0) then begin
        return,[x_array[0],0]
      endif

      extremum_place=-0.5*(Det[2]/Det[3]);
      extremum_value=av[1]+av[2]*extremum_place+av[3]*extremum_place^2;

      ;testing=0
      ;if testing eq 1 then begin
       ;plot,x_array,y_array,yrange=[min(y_array),extremum_value*1.05],ystyle=1,font=10
    ;   oplot,[extremum_place,x[1:3]],[extremum_value,y[1:3]],psym=2
    ;   print,'ext(place,value): ',[extremum_place,extremum_value]
    ;   wait,1
       ;print,y_array
    ;   wait,1
    ;
    ;  endif
     return,[extremum_place,extremum_value]
endif ;if not keyword_set(fit_parabola)

end
