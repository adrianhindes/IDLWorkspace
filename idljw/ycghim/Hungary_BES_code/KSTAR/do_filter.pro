pro do_filter

default,ebeam,90.
for angle_count=0,0 do begin
  divergence_max = 5

angle = 0
rhos = [0.4,0.6,0.8,0.9]

filter = 'Andover_3.0nm'
;hardon
;find_kstar_filter,filter=filter+'.dat',limit1=1,trans_li=1,limit2=2000,thick=3,chars=1.5,angle=angle,divergence_max=divergence_max,rhos=rhos,ebeam=ebeam
;hardfile,filter+'_SBR_Da_angle'+i2str(angle)+'.ps'

;hardon
;find_kstar_filter,filter=filter+'.dat',limit1=500,trans_li=1,limit2=1,thick=3,chars=1.5,angle=angle,divergence_max=divergence_max,rhos=rhos,ebeam=ebeam
;hardfile,filter+'_SBR_CII_angle'+i2str(angle)+'.ps'

;hardon
;find_kstar_filter,filter=filter+'.dat',limit1=1,trans_li=60,limit2=1,thick=3,chars=1.5,angle=angle,divergence_max=divergence_max,rhos=rhos,ebeam=ebeam
;hardfile,filter+'_Trans_angle'+i2str(angle)+'.ps'

hardon
find_kstar_filter,filter=filter+'.dat',limit1=100,trans_li=25,limit2=2000,thick=3,chars=1.5,angle=angle,divergence_max=divergence_max,rhos=rhos,ebeam=ebeam
hardfile,filter+'_All_limits_angle'+i2str(angle)+'.ps'

endfor

end