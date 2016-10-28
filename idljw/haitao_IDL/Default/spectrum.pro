pro spectrum

file1='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\carbon lines\2013 August 08 13_28_41.spe'
read_spe, file1, lam, t,d,texp=texp,str=str,fac=fac
d_514=mean(d,dimension=3)
d_514=d_514/max(d_514)
lam_514=lam
d_514_ind=where((lam_514 lt 518)  and (lam_514 gt 509))
d_514=d_514(d_514_ind)
lam_514=lam_514(d_514_ind)
n_514=n_elements(d_514)



file2='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\carbon lines\2013 August 08 13_29_21.spe'
read_spe, file2, lam, t,d,texp=texp,str=str,fac=fac
d_658=mean(d,dimension=3)
d_658=d_658/max(d_658)
lam_658=lam
d_658_ind=where((lam_658 lt 660)  and (lam_658 gt 655))
d_658=d_658(d_658_ind)
lam_658=lam_658(d_658_ind)
n_658=n_elements(d_514)



filter_514='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\spectrum\514 filter.spe'
read_spe, filter_514, lam, t,d,texp=texp,str=str,fac=fac
d_fil_514=d/max(d)
lam_fil_514=lam
fil_514_ind=where((lam_fil_514 lt 518)  and (lam_fil_514 gt 509) )
int_514=d_fil_514(fil_514_ind)
int_lam_514=lam_fil_514(fil_514_ind)
int_514=congrid(int_514, n_514)
;p=plot(lam_514,d_514, title='Carbon II 514 nm spectrum',xtitle='wavelength/nm', ytitle='Intensity', color='blue',name='Spectrum',xrange=[509,518])
;p1=plot(lam_514,int_514, title='Carbon II 514 nm spectrum',xtitle='wavelength/nm', ytitle='Intensity', color='red',name='Filter response',xrange=[509,518],/current)
;l=legend(target=[p,p1],position=[0.42,0.84,0.45,0.88])
filter_range_514=where((lam_fil_514 lt 525)  and (lam_fil_514 gt 505))
filter_range_lam_514=lam_fil_514(filter_range_514)
filter_514=d_fil_514(filter_range_514)
filter_element_514=n_elements(filter_range_514)

filter_658='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\spectrum\658 filter.spe'
read_spe, filter_658, lam, t,d,texp=texp,str=str,fac=fac
d_fil_658=d/max(d)
lam_fil_658=lam
fil_658_ind=where((lam_fil_658 lt 660)  and (lam_fil_658 gt 655) )
int_658=d_fil_658(fil_658_ind)
int_lam_658=lam_fil_658(fil_658_ind)
int_658=congrid(int_658, n_658)
;p=plot(lam_658,d_658, title='Carbon II 658 nm spectrum',xtitle='wavelength/nm', ytitle='Intensity', color='blue',name='Spectrum',xrange=[655,660])
;p1=plot(lam_658,int_658, title='Carbon II 658 nm spectrum',xtitle='wavelength/nm', ytitle='Intensity', color='red',name='Filter response',xrange=[655,660],/current)
;l=legend(target=[p,p1],position=[0.40,0.85,0.43,0.89])
filter_range_658=where((lam_fil_658 lt 665)  and (lam_fil_658 gt 655))
filter_range_lam_658=lam_fil_658(filter_range_658)
filter_658=d_fil_658(filter_range_658)
filter_element_658=n_elements(filter_range_658)



zn_lamp='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\spectrum\Zn lamp.spe'
read_spe, zn_lamp, lam, t,d,texp=texp,str=str,fac=fac
d_zn=mean(d,dimension=2)
d_zn=d_zn/max(d_zn)
lam_zn=lam
;int_zn_ind_514=where((lam_zn gt 505) and (lam_zn lt 525))
;int_zn_d_514=d_zn(int_zn_ind_514)
;int_zn_lam=lam_zn(int_zn_ind_514)
;int_zn_d_514=interpol(int_zn_d_514,filter_element_514)
;p1=plot(filter_range_lam_514,int_zn_d_514,title='Zn lamp response to 514 nm',xtitle='wavelenth/nm',ytitle='Intensity',xrange=[505,525],yrange=[0,1], name='lamp spectrum',color='red')
;p2=plot(filter_range_lam_514,filter_514,xtitle='wavelenth/nm',ytitle='Intensity',xrange=[505,525],yrange=[0,1], name='Filter response',color='blue',/current)
;l=legend(target=[p1,p2],position=[0.40,0.85,0.43,0.89])

;int_zn_ind_658=where((lam_zn gt 655) and (lam_zn lt 665))
;int_zn_d_658=d_zn(int_zn_ind_658)
;int_zn_lam=lam_zn(int_zn_ind_658)
;int_zn_d_658=interpol(int_zn_d_658,filter_element_658)
;p1=plot(filter_range_lam_658,int_zn_d_658,title='Zn lamp response to 658 nm',xtitle='wavelenth/nm',ytitle='Intensity',xrange=[655,665],yrange=[0,1], name='lamp spectrum',color='red')
;p2=plot(filter_range_lam_658,filter_658,xtitle='wavelenth/nm',ytitle='Intensity',xrange=[655,665],yrange=[0,1], name='Filter response',color='blue',/current)
;l=legend(target=[p1,p2],position=[0.90,0.85,0.93,0.89])


k_lamp='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\spectrum\K lamp.spe'
read_spe, k_lamp, lam, t,d,texp=texp,str=str,fac=fac
d_k=mean(d,dimension=2)
d_k=d_k/max(d_k)
lam_k=lam

;int_k_ind_514=where((lam_k gt 505) and (lam_k lt 525))
;int_k_d_514=d_k(int_k_ind_514)
;int_k_lam=lam_k(int_k_ind_514)
;int_k_d_514=interpol(int_k_d_514,filter_element_514)
;p1=plot(filter_range_lam_514,int_k_d_514,title='K lamp response to 514 nm',xtitle='wavelenth/nm',ytitle='Intensity',xrange=[505,525],yrange=[0,1], name='lamp spectrum',color='red')
;p2=plot(filter_range_lam_514,filter_514,xtitle='wavelenth/nm',ytitle='Intensity',xrange=[505,525],yrange=[0,1], name='Filter response',color='blue',/current)
;l=legend(target=[p1,p2],position=[0.40,0.85,0.43,0.89])

;int_k_ind_658=where((lam_k gt 655) and (lam_k lt 665))
;int_k_d_658=d_k(int_k_ind_658)
;int_k_lam=lam_k(int_k_ind_658)
;int_k_d_658=interpol(int_k_d_658,filter_element_658)
;p1=plot(filter_range_lam_658,int_k_d_658,title='K lamp response to 658 nm',xtitle='wavelenth/nm',ytitle='Intensity',xrange=[655,665],yrange=[0,1], name='lamp spectrum',color='red')
;p2=plot(filter_range_lam_658,filter_658,xtitle='wavelenth/nm',ytitle='Intensity',xrange=[655,665],yrange=[0,1], name='Filter response',color='blue',/current)
;l=legend(target=[p1,p2],position=[0.90,0.85,0.93,0.89])

he_lamp='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\spectrum\He lamp.spe'
read_spe, he_lamp, lam, t,d,texp=texp,str=str,fac=fac
d_he=mean(d,dimension=2)
d_he=d_he/max(d_he)
lam_he=lam

;int_k_ind_514=where((lam_k gt 505) and (lam_k lt 525))
;int_k_d_514=d_k(int_k_ind_514)
;int_k_lam=lam_k(int_k_ind_514)
;int_k_d_514=interpol(int_k_d_514,filter_element_514)
;p1=plot(filter_range_lam_514,int_k_d_514,title='K lamp response to 514 nm',xtitle='wavelenth/nm',ytitle='Intensity',xrange=[505,525],yrange=[0,1], name='lamp spectrum',color='red')
;p2=plot(filter_range_lam_514,filter_514,xtitle='wavelenth/nm',ytitle='Intensity',xrange=[505,525],yrange=[0,1], name='Filter response',color='blue',/current)
;l=legend(target=[p1,p2],position=[0.40,0.85,0.43,0.89])


h_lamp='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\spectrum\H lamp.spe'
read_spe, h_lamp, lam, t,d,texp=texp,str=str,fac=fac
d_H=mean(d,dimension=2)
d_h=d_h/max(d_h)
lam_H=lam

;int_h_ind_658=where((lam_h gt 655) and (lam_h lt 665))
;int_h_d_658=d_h(int_h_ind_658)
;int_h_lam=lam_k(int_h_ind_658)
;int_h_d_658=interpol(int_h_d_658,filter_element_658)
;p1=plot(filter_range_lam_658,int_h_d_658,title='H lamp response to 658 nm',xtitle='wavelenth/nm',ytitle='Intensity',xrange=[655,665],yrange=[0,1], name='lamp spectrum',color='red')
;p2=plot(filter_range_lam_658,filter_658,xtitle='wavelenth/nm',ytitle='Intensity',xrange=[655,665],yrange=[0,1], name='Filter response',color='blue',/current)
;l=legend(target=[p1,p2],position=[0.40,0.85,0.43,0.89])






cd_lamp='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\spectrum\Cd lamp.spe'
read_spe, Cd_lamp, lam, t,d,texp=texp,str=str,fac=fac
d_Cd=mean(d,dimension=2)
d_cd=d_cd/max(d_cd)
lam_Cd=lam


Cs_lamp='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\spectrum\Cs lamp.spe'
read_spe, Cs_lamp, lam, t,d,texp=texp,str=str,fac=fac
d_cs=mean(d,dimension=2)
d_cs=d_cs/max(d_cs)
lam_cs=lam
;int_cs_ind_514=where((lam_cs gt 505) and (lam_cs lt 525))
;int_cs_d_514=d_cs(int_cs_ind_514)
;int_cs_lam=lam_cs(int_cs_ind_514)
;int_cs_d_514=interpol(int_cs_d_514,filter_element_514)
;p1=plot(filter_range_lam_514,int_cs_d_514,title='Cs lamp response to 514 nm',xtitle='wavelenth/nm',ytitle='Intensity',xrange=[505,525],yrange=[0,1], name='lamp spectrum',color='red')
;p2=plot(filter_range_lam_514,filter_514,xtitle='wavelenth/nm',ytitle='Intensity',xrange=[505,525],yrange=[0,1], name='Filter response',color='blue',/current)
;l=legend(target=[p1,p2],position=[0.40,0.85,0.43,0.89])

;int_cs_ind_658=where((lam_cs gt 655) and (lam_cs lt 665))
;int_cs_d_658=d_cs(int_cs_ind_658)
;int_cs_lam=lam_cs(int_cs_ind_658)
;int_cs_d_658=interpol(int_cs_d_658,filter_element_658)
;p1=plot(filter_range_lam_658,int_cs_d_658,title='Cs lamp response to 658 nm',xtitle='wavelenth/nm',ytitle='Intensity',xrange=[655,665],yrange=[0,1], name='lamp spectrum',color='red')
;p2=plot(filter_range_lam_658,filter_658,xtitle='wavelenth/nm',ytitle='Intensity',xrange=[655,665],yrange=[0,1], name='Filter response',color='blue',/current)
;l=legend(target=[p1,p2],position=[0.90,0.85,0.93,0.89])




Cu_k_hollow8_lamp='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\spectrum\Cu K hollow cathode 8mA.spe'
read_spe, Cu_k_hollow8_lamp, lam, t,d,texp=texp,str=str,fac=fac
d_cu_k=mean(d,dimension=2)
d_cu_k=d_cu_k/max(d_cu_k)
lam_cu_k=lam
;int_cu_k_ind_658=where((lam_cu_k gt 655) and (lam_cu_k lt 665))
;int_cu_k_d_658=d_cu_k(int_cu_k_ind_658)
;int_cu_k_lam=lam_cu_k(int_cu_k_ind_658)
;int_cu_k_d_658=interpol(int_cu_k_d_658,filter_element_658)
;p1=plot(filter_range_lam_658,int_cu_k_d_658,title='Cu-k lamp response to 658 nm',xtitle='wavelenth/nm',ytitle='Intensity',xrange=[655,665],yrange=[0,1], name='lamp spectrum',color='red')
;p2=plot(filter_range_lam_658,filter_658,xtitle='wavelenth/nm',ytitle='Intensity',xrange=[655,665],yrange=[0,1], name='Filter response',color='blue',/current)
;l=legend(target=[p1,p2],position=[0.90,0.85,0.93,0.89])












Cu_hollow3_lamp='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\spectrum\Cu hollow cathode 3mA.spe'
read_spe, Cu_hollow3_lamp, lam, t,d,texp=texp,str=str,fac=fac
d_cu_hollow=mean(d,dimension=2)
lam_cu_hollow=lam

;int_cu_hollow_ind_658=where((lam_cu_hollow gt 655) and (lam_cu_hollow lt 665))
;int_cu_hollow_d_658=d_cu_hollow(int_cu_hollow_ind_658)
;int_cu_hollow_lam=lam_cu_k(int_cu_hollow_ind_658)
;int_cu_hollow_d_658=interpol(int_cu_hollow_d_658,filter_element_658)
;p1=plot(filter_range_lam_658,int_cu_hollow_d_658,title='Cu-Hollow lamp response to 658 nm',xtitle='wavelenth/nm',ytitle='Intensity',xrange=[655,665],yrange=[0,1], name='lamp spectrum',color='red')
;p2=plot(filter_range_lam_658,filter_658,xtitle='wavelenth/nm',ytitle='Intensity',xrange=[655,665],yrange=[0,1], name='Filter response',color='blue',/current)
;l=legend(target=[p1,p2],position=[0.90,0.85,0.93,0.89])






Cs_hollow10_lamp='C:\haitao\papers\study topics\H-1 projection\data and results\winpec data\spectrum\Cs hollow cathode 10mA.spe'
read_spe, Cs_hollow10_lamp, lam, t,d,texp=texp,str=str,fac=fac
d_cs_hollow=mean(d,dimension=2)
d_cs_hollow=d_cs_hollow/max(d_cs_hollow)
lam_cs_hollow=lam
int_cs_hollow_ind_658=where((lam_cs_hollow gt 655) and (lam_cs_hollow lt 665))
int_cs_hollow_d_658=d_cs_hollow(int_cs_hollow_ind_658)
int_cs_hollow_lam=lam_cs_hollow(int_cs_hollow_ind_658)
int_cs_hollow_d_658=interpol(int_cs_hollow_d_658,filter_element_658)
p1=plot(filter_range_lam_658,int_cs_hollow_d_658,title='Cs-Hollow lamp response to 658 nm',xtitle='wavelenth/nm',ytitle='Intensity',xrange=[655,665],yrange=[0,1], name='lamp spectrum',color='red')
p2=plot(filter_range_lam_658,filter_658,xtitle='wavelenth/nm',ytitle='Intensity',xrange=[655,665],yrange=[0,1], name='Filter response',color='blue',/current)
l=legend(target=[p1,p2],position=[0.90,0.85,0.93,0.89])



stop
end