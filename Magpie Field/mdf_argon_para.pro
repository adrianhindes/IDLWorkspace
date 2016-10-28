pro mdf_argon_para, I0, I1
;I0,source current
;I1, mirror current
;constant 
c =     { c: 299792458.,$
          e: 1.60217646d-19, $
          me: 9.1093897d-31, $
          re: 2.8179403267d-15, $
          mp: 1.67262158d-27, $
          mu0: 4*!pi*1d-7, $
          h: 6.626068d-34, $
          eps0: 8.854187817d-12, $
          kB: 1.380658d-23, $
          alpha: 0.d,$
          uB: 0.d0, $
          a0: 5.2917721092d-11}
c.alpha = c.e^2 * c.c * c.mu0/(2*c.h)   ; fine structure
c.uB = c.e * c.h / (4d0*!dpi*c.me) 
mratio=40.0 ;for argon ion, the ion mass/proton mass is 40.0
; magpie parameters
n_e=5*1d12
n_i=5*1d12
radius=5.0
t_e=5.0
st_i=1.0
mt_i=0.2
mag_field=Magpie_field(I0,I1,r=r,z=z,scale=scale)
bz0=mag_field.bz0*1.d4
;frequency
f_egyro=2.80*1d6*bz0
f_igyro=1.52*1d3/mratio*bz0
;print, 'ion gyrofrequecny=', f_egyro, 'Hz'
f_epla=8.98*1d3*sqrt(n_e)
;print, 'electron plasma frequecny=', f_egyro, 'Hz'
f_ipla=2.10*1d2*1.0/sqrt(mratio)*sqrt(n_i)
;print, 'ion plasma frequecny=', f_egyro, 'Hz'

;gyroradius
nu=n_elements(z)
t_i=range(st_i,mt_i,npts=nu)
e_r=2.38*sqrt(t_e)/bz0
;print, 'electron gyroradius',e_r,'cm'
i_r=1.02*100.0*sqrt(mratio)*sqrt(t_i)/bz0
;print, 'electron gyroradius',e_r,'cm'
;collision rate
ee_coll=2.91*1d-6*n_e*6.8*t_e^(-1.5)
print, ee_coll,'electron-electron collison rate=', 'Hz'
ii_coll=4.80*1.0*1d-8/sqrt(mratio)*n_i*6.8*t_i^(-1.5)
;print, ii_coll,'ion-ion collison rate=', 'Hz'
!p.multi=[0,2,3]
!p.charsize=2
plot, z*100., f_egyro,title='electron gyrofrequency',xtitle='Axis(cm)',ytitle='Frequency (Hz)',xrange=[0,60.]
plot, z*100., f_igyro,title='ion gyrofrequency',xtitle='Axis(cm)',ytitle='Frequency (Hz)',xrange=[0,60.]
plot, z*100., e_r,title='electron gyroradius',xtitle='Axis(cm)',ytitle='Radius(cm)',xrange=[0,60.]
plot, z*100., i_r,title='ion gyroradius',xtitle='Axis(cm)',ytitle='Radius(cm)',xrange=[0,60.]
plot,z*100., ii_coll,title='ion-ion collision rate',xtitle='Axis(cm)',ytitle='Frequency(Hz)',xrange=[0,60.]
plot, z*100,bz0,title='Magnetic field amplitude(Gauss)',xtitle='Axis(cm)',ytitle='Magnetic(Gauss)',xrange=[0,60.]
!p.multi=0
stop
end
