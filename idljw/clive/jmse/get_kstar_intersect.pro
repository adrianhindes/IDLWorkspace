function get_kstar_intersect, shotno, bin=bin, beam=beam

    default, beam, 0
    case beam of
    0:  path = '.mse.intersect'
    1:  path = '.mse.intersect1'
    2:  path = '.mse.intersect2'
    end
    
    geom = read_kstar_intersect( shotno, bin=bin, path=path )
    interp = read_interpolation_arrays( shotno, path=path )

    geom = create_struct(geom, 'interp', interp) ; copy interp to geom
    
    if keyword_set(bin) then $
      geom = rebin_interpolation_grid( geom, bin ) ; rebin the interpolation grid if required

; helpstr = ['(R,phi) are the radius and toroidal angle of the intersect point (projected onto the midplane)', $
;        '(X,Y,Z) are the intersection coordinates in the machine coord system]',$
;        '(i,j,k) are the unit vectors in the machine coord system.  i points from observer to beam, j is horizontal',$
;        'gamma is the angle between i projected onto x-y (horizontal) plane and velocity vector',$
;        'psi is the vertical angle of the viewing ray i: asin(i[2])*!radeg',$
;        'theta is the angle between i and the beam direction - positive from i',$
;        'alpha is the angle between phi_hat and the beam direction - positive from phi_hat',$
;        'omega is the angle between phi_hat and proj of i onto midplane - positive from phi_hat'] 
 
return, geom

end

