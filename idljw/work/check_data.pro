pro check_data
shot1 = 7760  ;6826
shot2 = 7789 ;6974

isat1 = magpie_data('probe_isat',shot1)
vplus1  = magpie_data('probe_vplus',shot1)
vfloat1  = magpie_data('probe_vfloat',shot1)

isat2 = magpie_data('probe_isat',shot2)
vplus2  = magpie_data('probe_vplus',shot2)
vfloat2  = magpie_data('probe_vfloat',shot2)

;vfloat_rot  = magpie_data('probe_vfloat_rot',shot)



ycplot,isat1.tvector,isat1.vvector,title='isat '+string(shot1)
ycplot,isat2.tvector,isat2.vvector,title='isat '+string(shot2)

stop
ycplot,vplus1.tvector,vplus1.vvector,title='vplus '+string(shot1)
ycplot,vplus2.tvector,vplus2.vvector,title='vplus '+string(shot2)

stop
ycplot,vfloat1.tvector,vfloat1.vvector,title='vfloat '+string(shot1)
ycplot,vfloat2.tvector,vfloat2.vvector,title='vfloat '+string(shot2)


stop
;plot,vfloat_rot.vvector,title='vfloat rot'

end