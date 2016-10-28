function calibrate_cmos_li_2014, x, y

;**********************************************************************
;****  CALIBRATE_CMOS_2014     created by M. Lampert 2015 03. 05   ****
;**********************************************************************
;*                                                                    *
;* Returns the radial, vertical and toroidal coordinates for a given  *
;* CMOS x,y pixel coordinate from a 2014 Lithium beam measurement.    *
;*                                                                    *
;**********************************************************************
;*                                                                    *
;*INPUTs:                                                             *
;*        x: x coordinate of the pixel                                *
;*        y: y coordinate of the pixel                                *
;*OUTPUTs:                                                            *
;*        Returns an array of [r,z,t]=[radial,vertical,toroidal]      *
;*          radial: major radius in mm                                *
;*          vertical: vertical coordinate from midplane in mm         *
;*          toroidal: toroidal coordinate in radian from Mport center *
;*                                                                    *
;**********************************************************************

coeff=[[-0.12280565,     -0.12280565,     -0.21611147],$
       [-0.00030956993,  -0.00030956993,  1.4188985e-005],$
       [0.32000938,      0.32000938,     -0.49752044],$
       [1577.5927,       1577.5927,       410.07543]]
       
m_port_middle_cat=[0,729.7,0]               
xyz=dblarr(3)
rzt=dblarr(3)

xyz[0]=coeff[0,0]*x + coeff[0,1]*x*y + coeff[0,2]*y + coeff[0,3]
xyz[1]=coeff[1,0]*x + coeff[1,1]*x*y + coeff[1,2]*y + coeff[1,3]
xyz[2]=coeff[2,0]*x + coeff[2,1]*x*y + coeff[2,2]*y + coeff[2,3]

rzt[0]=sqrt((xyz[0])^2+(xyz[1])^2)
rzt[1]=xyz[2]

;The following section calculates the toroidal angle from the M-port's center

nvec_1=m_port_middle_cat/length(m_port_middle_cat)
nvec_2=reform(xyz[0:1])/length(reform(xyz[0:1]))
nvec_2=[nvec_2[0],nvec_2[1],0]
cvec=(cross_prod(nvec_1,nvec_2))
dir=-(cvec/length(cvec))[2]
rzt[2]=acos((transpose(nvec_2) # nvec_1))*dir
return, rzt
end