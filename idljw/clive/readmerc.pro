fil='/home/cmichael/fromboyd/from_berhnard/VMEC_kh+0.730_kv+1.000_pe+0.066_free_D20150916_T164656/mercier.VMEC_kh+0.730_kv+1.000_pe+0.066_free_D20150916_T164656

fil='/home/cmichael/fromboyd/myruns/VMEC_kh+0.720_kv+1.000_pe+0.066_free_D20150918_T004612/mercier.VMEC_kh+0.720_kv+1.000_pe+0.066_free_D20150918_T004612'

;fil='/home/cmichael/fromboyd/myruns/VMEC_kh+0.730_kv+1.000_pe+0.066_free_D20150918_T000853/mercier.VMEC_kh+0.730_kv+1.000_pe+0.066_free_D20150918_T000853'

fil='/home/cmichael/fromboyd/myruns/VMEC_kh+0.720_kv+1.000_pe+0.066_free_D20151019_T203017/mercier.VMEC_kh+0.720_kv+1.000_pe+0.066_free_D20151019_T203017'

d=(read_ascii(fil,data_start=2)).(0)
tab1=d(*,0:96)
;      S          PHI         IOTA        SHEAR        VP         WELL        ITOR       ITOR'       PRES       PRES'
s1=tab1(0,*)
well=tab1(5,*)
iota=tab1(2,*)
tab2=d(*,99:*)
;    S        DMerc        DShear       DCurr       DWell       Dgeod
s2=tab2(0,*)
dmerc=tab2(1,*)
plot,s2,dmerc,yr=[-10,10]

plot,s1,iota,/yno,col=2;,/noer
plot,s1,well,/noer,col=3
;plotm,transpose(tab2),yr=[-10,10]   

end
