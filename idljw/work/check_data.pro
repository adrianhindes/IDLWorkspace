pro check_data
shot1 = 6826 ;6826
shot2 = 6906 ;6974

isat1 = magpie_data('probe_isat',shot1)
vplus1  = magpie_data('probe_vplus',shot1)
vfloat1  = magpie_data('probe_vfloat',shot1)

isat2 = magpie_data('probe_isat',shot2)
vplus2  = magpie_data('probe_vplus',shot2)
vfloat2  = magpie_data('probe_vfloat',shot2)

;vfloat_rot  = magpie_data('probe_vfloat_rot',shot)


ycplot,isat1.tvector,isat1.vvector,title='isat'
ycplot,isat2.tvector,isat2.vvector,title='isat b'

stop
ycplot,vplus1.tvector,vplus1.vvector,title='vplus'
ycplot,vplus2.tvector,vplus2.vvector,title='vplus side'

stop
ycplot,vfloat1.tvector,vfloat1.vvector,title='vfloat'
ycplot,vfloat2.tvector,vfloat2.vvector,title='vfloat side'


stop
;plot,vfloat_rot.vvector,title='vfloat rot'

end