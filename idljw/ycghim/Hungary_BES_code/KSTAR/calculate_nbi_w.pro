function calculate_nbi_w, shot, timerange=timerange, fourcord=fourcord
  
;************************************************
;**             calculate_nbi_w                **
;************************************************
;* This function calculates the nbi weight      *
;* for the spatial calibration.                 *
;*WARNING: This software needs to be updated    *
;*  after the 3rd NBI is installed              *
;*  The calculation is only valid for shots     *
;*  after 9110.                                 *
;*  At the momment there are only 2 NBIs on     *
;*  KSTAR when the third is commisioned, the    *
;*  software needs to be updated.               *
;************************************************
;* INPUTs:                                      *
;*   shot: shotnumber                           *
;*   timerange: [t1,t2] the timerange in which  *
;*     the weight factors are calculated based  *
;*     upon the nbi energy and power            *
;*   fourcord: the four coordinates of the      *
;*     fiducial points in pixel [4,2]           *
;* OUTPUT:                                      *
;*   Returns the weight factors as a [3] vector *
;************************************************

if not defined(timerange) then begin
  get_rawsignal, shot, 'P_NBI1',t,pnbi1
  get_rawsignal, shot, 'P_NBI2',t,pnbi2
  get_rawsignal, shot, 'E_NBI1',t,enbi1
  get_rawsignal, shot, 'E_NBI2',t,enbi2
  pnbi1=max(pnbi1)
  pnbi2=max(pnbi2)
  enbi1=max(enbi1)
  enbi2=max(enbi2)
endif else begin
  get_rawsignal, shot, 'P_NBI1',t,pnbi1, timerange=timerange
  get_rawsignal, shot, 'P_NBI2',t,pnbi2, timerange=timerange
  get_rawsignal, shot, 'E_NBI1',t,enbi1, timerange=timerange
  get_rawsignal, shot, 'E_NBI2',t,enbi2, timerange=timerange
endelse

if not defined(fourcord) then begin
  fourcord=lonarr(4,2)
  fourcord[0,*]=[660,665]
  fourcord[1,*]=[688,763]
  fourcord[2,*]=[624,722]
  fourcord[3,*]=[724,706]
endif

principal_ray_point_cat=[45.3,2751.6,-245.3]
a_point_nbi_cat=[1607.5,-3238.4,0.0]
b_point_nbi_cat=[1573.2192,-2316.2630,0.0]
restore, 'Andover_660nmfilter_spectra.sav'

filter_trans_nbi=dblarr(2)
for i =0,1 do begin
  case i of
    0: begin
      ebeam=mean(enbi1)
      nbi_w=[1,0,0]
    end
    1: begin 
      ebeam=mean(enbi2)
      nbi_w=[0,1,0]
    end
  end
  
  ;preliminary calculation of the optical axis on the NBI for the doppler shift
  calc_nbi_oa, fourcord=fourcord, nbi_w=nbi_w, oa_nbi=oa_nbi 
  oa_nbi=xyztocyl(oa_nbi,/inv)
  a_vec=a_point_nbi_cat-b_point_nbi_cat
  b_vec=oa_nbi-principal_ray_point_cat
  angle_beam=(acos(transpose(a_vec) # b_vec/(length(a_vec)*length(b_vec))))[0]
  v_beam = sqrt(2*ebeam[0]*1000.*1.6e-19/(2*1.6e-27))
  w_doppler = (1.+v_beam*cos(angle_beam)/3e8)*656.1
  a=min(abs(wavelength-w_doppler),ind)
  filter_trans_nbi[i]=data[ind,0]
endfor

nbi_w=dblarr(3)
nbi_w[0]=mean(pnbi1)*filter_trans_nbi[0]
nbi_w[1]=mean(pnbi2)*filter_trans_nbi[1]
nbi_w[2]=0
nbi_w=nbi_w/total(nbi_w)

return, nbi_w
end