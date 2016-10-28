pro pco_cmos_linearity_check
  cd, 'D:\KFKI\Camera comparison'
restore, 'cmos_meas_analysis.sav'
error=dblarr(15)
error[*]=0.01
p=mpfitfun('linear_fit',cmos_exp,cmos_aver,error,[10,0.0033])
stop
restore, 'pco_meas_analysis.sav'


restore, 'good_phofoc_meas.sav'


end