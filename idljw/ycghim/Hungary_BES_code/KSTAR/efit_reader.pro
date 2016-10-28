;******************************************************
;* EFIT_READER       Cs. Buday   2011                 *
;******************************************************
;* Reads an EFIT file and returns data in a structure *
;* function efit_reader,filename,errormess=errormess  *
;* INPUT:                                             *
;*   filaneme: The file name                          *
;* OUPUT:                                             *
;*   errormess: Error message or ''                   *
;*   Return value is structure                        *
;******************************************************

; Partial derivations.
function partial_X, matrix, axisX
    S=size(matrix,/dimensions);
    m=S[1]
    n=S[0]
    dx=fltarr(m,n)
    for i=0,m-1 do begin
       j=0
       dx[j,i]=(matrix[j+1,i]-matrix[j,i])/(axisX[j+1]-axisX[j]);
       for j=1,n-2 do begin
         dx[j,i]=(matrix[j+1,i]-matrix[j-1,i])/(axisX[j+1]-axisX[j-1]);
       endfor
       j=n-1
       dx[j,i]=(matrix[j,i]-matrix[j-1,i])/(axisX[j]-axisX[j-1]);
    endfor

    return, dx
end

function partial_Y, matrix, axisY
    S=size(matrix,/dimensions);
    m=S[1]
    n=S[0]
    dy=fltarr(m,n)
    for j=0,n-1 do begin
       i=0
       dy[j,i]=(matrix[j,i+1]-matrix[j,i])/(axisY[i+1]-axisY[i]);
       for i=1,m-2 do begin
         dy[j,i]=(matrix[j,i+1]-matrix[j,i-1])/(axisY[i+1]-axisY[i-1]);
       endfor
       i=m-1
       dy[j,i]=(matrix[j,i]-matrix[j,i-1])/(axisY[i]-axisY[i-1]);
    endfor

    return, dy
end

; Interpolation on a uniform grid.
function unigrid_interp, X_min,X_range,Y,X_i
    n=N_elements(Y)
    X_step=X_range/n
    nearest=fix(n*(X_i-X_min)/(X_range))
    if (nearest lt 0) then begin
       nearest=0
    endif
    if (nearest gt n-2) then begin
       nearest=n-2
    endif
    X_nearest=fix(nearest*X_step+X_min)
    beta=(X_i-X_nearest)/X_step
    return, (1.0-beta)*Y[nearest]+beta*Y[nearest+1]
end

; The efit_reader function itself.
function efit_reader,filename,errormess=errormess,silent=silent
    errormess = ''
    openr, eqfile, filename,/get_lun,error=e
    if (e ne 0) then begin
      errormess = 'Error opening file: '+filename
      if (not keyword_set(silent)) then print,errormess
      return,0
    endif

    on_ioerror,err_read

    header_format='(6a8, 3i4)'
    body_format='(5e16.9)'
    boundary_format = '(2i5)'


    strheader=strarr(6)

    readf, eqfile, format=header_format, strheader, undef_var, mesh_width, mesh_height
    readf, eqfile, format=body_format, R_dim, Z_dim, R_0, R_min, Z_center
    readf, eqfile, format=body_format, R_axis, Z_axis, axis_flux, limiter_flux, B_t_nom
    readf, eqfile, format=body_format, I_pl
    readf, eqfile, format=body_format

    flux_cnt=mesh_width


    F=fltarr(flux_cnt)
    dF=fltarr(flux_cnt)
    p=fltarr(flux_cnt)
    dp=fltarr(flux_cnt)

    Psi=fltarr(mesh_width,mesh_height)
    q_psi = fltarr(flux_cnt)

    readf, eqfile, format=body_format, F
    readf, eqfile, format=body_format, p
    readf, eqfile, format=body_format, dF
    readf, eqfile, format=body_format, dp
    readf, eqfile, format=body_format, Psi
    readf, eqfile, format=body_format,q_psi
    readf, eqfile, format=boundary_format,nboundary,nlimiter
    boundary = fltarr(nboundary*2)
    readf, eqfile, format=body_format, boundary
    boundary_r = boundary[indgen(nboundary)*2]
    boundary_z = boundary[indgen(nboundary)*2+1]

    close, eqfile
    free_lun,eqfile

;   All primary data has been read by this point.
;   The following are only calculated.

    R=fltarr(mesh_width)
    Z=fltarr(mesh_height)
    psi_values=fltarr(flux_cnt)

    for i=0,mesh_width-1 do begin
       R[i]=R_min+i/mesh_width*R_dim
    endfor
    for i=0,mesh_height-1 do begin
       Z[i]=Z_center+(i/mesh_height-0.5)*Z_dim
    endfor
    for i=0,flux_cnt-1 do begin
       psi_values[i]=axis_flux+(i/flux_cnt)*(limiter_flux-axis_flux)
    endfor

    B_t=fltarr(mesh_width,mesh_height)
    F_grid=fltarr(mesh_width,mesh_height)
    B_r=fltarr(mesh_width,mesh_height)
    B_z=fltarr(mesh_width,mesh_height)
    J_t=fltarr(mesh_width,mesh_height)
    J_r=fltarr(mesh_width,mesh_height)
    J_z=fltarr(mesh_width,mesh_height)

    dPsi_dR=partial_X(Psi,R)
    dPsi_dZ=partial_Y(Psi,Z)

    MU_0=1.2566370614E-7

    for i=0,mesh_width-1 do begin
       for j=0,mesh_height-1 do begin
         F_grid[i,j]=unigrid_interp(axis_flux,limiter_flux-axis_flux,F,Psi[i,j])
         B_r[i,j]=-dPsi_dZ[i,j]/R[i]
         B_t[i,j]=F_grid[i,j]/R[i]
         B_z[i,j]=dPsi_dR[i,j]/R[i]
       endfor
    endfor

    dF_dr=partial_X(F_grid,R)
    dB_t_dZ=partial_Y(B_t,Z)
    dB_r_dZ=partial_Y(B_r,Z)
    dB_z_dR=partial_X(B_z,R)

    for i=0,mesh_width-1 do begin
       for j=0,mesh_height-1 do begin
         J_r[i,j]=-dB_t_dZ[i,j]/MU_0
         J_t[i,j]=(dB_r_dZ[i,j]-dB_z_dR[i,j])/MU_0
         J_z[i,j]=((dF_dr[i,j])/R[i])/MU_0
       endfor
    endfor

    eqdskdata = { R:R, Z:Z, psi_values:psi_values, Psi:Psi, F:F, dF:dF,$
    p:p, dp:dp, mw:mesh_width, mh:mesh_height, fc:flux_cnt,$
    R_dim:R_dim, Z_dim:Z_dim, R_0:R_0, R_min:R_min, Z_center:Z_center,$
    R_axis:R_axis, Z_axis:Z_axis, axis_flux:axis_flux,$
    limiter_flux:limiter_flux, B_t_nom:B_t_nom ,I_pl:I_pl,$
    B_t:B_t, B_r:B_r, B_z:B_z, J_t:J_t, J_r:J_r, J_z:J_z, q_psi:q_psi, boundary_r:boundary_r, boundary_z:boundary_z }

    close,eqfile & free_lun,eqfile
    return, eqdskdata

    err_read:
    close,eqfile & free_lun,eqfile
    errormess = 'Error reading file: '+filename
    if (not keyword_set(silent)) then print,errormess
    return,0
end
