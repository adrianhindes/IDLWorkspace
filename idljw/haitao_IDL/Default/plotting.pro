pro plotting

restore,'1.5 mt and 400 A freq.save'
p=plot(freqv/1000.0,yrange=[15,25])
restore,'1.5 mt and 600 A freq.save'
p1=plot(freqv/1000.0,yrange=[15,25],/current)
restore,'1.5 mt and 800 A freq.save'
p2=plot(freqv/1000.0,yrange=[15,25],/current)
stop
end


restore, 'contrast for 2.0 mm savart.save'
p=plot(findgen(400)+50,cal_contrast(50:450,250),xtitle='X pixel',ytitle='Y pixel', title='Contrast for different k',name='2.0 mm Savart plate',xrange=[50,450],yrange=[0.4,1.2])
restore, 'contrast for 2.5 mm savart.save'
p1=plot(findgen(400)+50,cal_contrast(50:450,250),xtitle='X pixel',ytitle='Y pixel', title='Contrast for different k',name='2.5 mm Savart plate',xrange=[50,450],yrange=[0.4,1.2],color='red',/current)
restore, 'contrast for 6.0 mm savart.save'
p2=plot(findgen(400)+50,cal_contrast(50:450,250),xtitle='X pixel',ytitle='Y pixel', title='Contrast for different k',name='6.0 mm Savart plate',xrange=[50,450],yrange=[0.4,1.2],color='blue',/current)
restore, 'contrast for 8.0 mm savart.save'
p3=plot(findgen(400)+50,cal_contrast(50:450,250),xtitle='X pixel',ytitle='Y pixel', title='Contrast for different k',name='8.0 mm Savart plate',xrange=[50,450],yrange=[0.4,1.2],color='orange',/current)
l=legend(target=[p,p1,p2,p3],position=[0.9,0.9,0.95,0.95])

restore, 'contrast for 4.0 mm displacer.save'
p4=plot(findgen(400)+50,cal_contrast(50:450,250),xtitle='X pixel',ytitle='Y pixel', title='Contrast for different k',xrange=[50,450],yrange=[0.4,1.2],color='green',/current)
restore, 'contrast for 3.0 mm displacer.save'
p5=plot(findgen(400)+50,cal_contrast(50:450,250),xtitle='X pixel',ytitle='Y pixel', title='Contrast for different k',xrange=[50,450],yrange=[0.4,1.2],color=136,/current)
restore, 'contrast for 5.0 mm displacer.save'
p6=plot(findgen(400)+50,cal_contrast(50:450,250),xtitle='X pixel',ytitle='Y pixel', title='Contrast for different k',xrange=[50,450],yrange=[0.4,1.2],color=152,/current)
stop
end

restore,'contrast for two 3 mm displacer.save'
 p=plot(findgen(481)+20,cal_contrast(20:500,63),xtitle='X pixel',ytitle='Contrast',title='Contrast for different k',name='Two 3 mm displacer',color='red',yrange=[0,1])
 restore,'contrast for two 5 mm displacer.save'
 p1=plot(findgen(481)+20,cal_contrast(20:500,63),xtitle='X pixel',ytitle='Contrast',title='Contrast for different k',name='Two 5 mm displacer',color='blue',yrange=[0,1],/current)
 restore,'calibration 2.save'
 p2=plot(findgen(481)+20,cal2_c(20:500,63),xtitle='X pixel',ytitle='Contrast',title='Contrast for different k',name='4.5 mm Savart',yrange=[0,1],/current)
 l=legend(target=[p,p1,p2],position=[0.90,0.90,0.95,0.95])

stop
end



fil464='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\spec\shaun_81733.spe'
read_spe, fil464, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
d464=d
lam464=lam
;p=plot(reverse(lam464), d464(*,3,3), title='Spectrum centered at 464 nm',xtitle='Wavelength/nm',ytitle='Intensity')
;p.save, 'Spectrum centered at 464 nm.png',resolution=100

fil489='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\spec\shaun_81723.spe'
read_spe, fil489, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
d489=d
lam489=lam
;p=plot(reverse(lam489), d489(*,3,3), title='Spectrum centered at 489 nm',xtitle='Wavelength/nm',ytitle='Intensity')
;p.save, 'Spectrum centered at 489 nm.png',resolution=100

fil514='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\spec\shaun_81721.spe'
read_spe, fil514, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
d514=d
lam514=lam
;p=plot(reverse(lam514), d514(*,3,3), title='Spectrum centered at 514 nm',xtitle='Wavelength/nm',ytitle='Intensity')
;p.save, 'Spectrum centered at 514 nm.png',resolution=100

fil539='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\spec\shaun_81724.spe'
read_spe, fil539, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
d539=d
lam539=lam
;p=plot(reverse(lam539), d539(*,3,5), title='Spectrum centered at 539 nm',xtitle='Wavelength/nm',ytitle='Intensity')
;p.save, 'Spectrum centered at 539 nm.png',resolution=100

fil564='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\spec\shaun_81725.spe'
read_spe, fil564, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
d564=d
lam564=lam
p=plot(reverse(lam564), d564(*,3,3), title='Spectrum centered at 564 nm',xtitle='Wavelength/nm',ytitle='Intensity')
p.save, 'Spectrum centered at 564 nm.png',resolution=100

fil589='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\spec\shaun_81726.spe'
read_spe, fil589, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
d589=d
lam589=lam
p=plot(reverse(lam589), d589(*,3,3), title='Spectrum centered at 589 nm',xtitle='Wavelength/nm',ytitle='Intensity')
p.save, 'Spectrum centered at 589 nm.png',resolution=100

fil588='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\spec\shaun_81734.spe'
read_spe, fil588, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
d588=d
lam588=lam


fil614='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\spec\shaun_81727.spe'
read_spe, fil614, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
d614=d
lam614=lam
p=plot(reverse(lam614), d614(*,3,5), title='Spectrum centered at 614 nm',xtitle='Wavelength/nm',ytitle='Intensity')
p.save, 'Spectrum centered at 614 nm.png',resolution=100

fil639='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\spec\shaun_81728.spe'
read_spe, fil639, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
d639=d
lam639=lam
p=plot(reverse(lam639), d639(*,3,3), title='Spectrum centered at 639 nm',xtitle='Wavelength/nm',ytitle='Intensity')
p.save, 'Spectrum centered at 639 nm.png',resolution=100

fil634='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\spec\shaun_81735.spe'
read_spe, fil634, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
d634=d
lam634=lam

fil664='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\spec\shaun_81729.spe'
read_spe, fil664, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
d664=d
lam664=lam
p=plot(reverse(lam664), d664(*,3,3), title='Spectrum centered at 664 nm',xtitle='Wavelength/nm',ytitle='Intensity')
p.save, 'Spectrum centered at 664 nm.png',resolution=100

fil689='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\spec\shaun_81730.spe'
read_spe, fil689, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
d689=d
lam689=lam
p=plot(reverse(lam689), d689(*,3,3), title='Spectrum centered at 689 nm',xtitle='Wavelength/nm',ytitle='Intensity')
p.save, 'Spectrum centered at 689 nm.png',resolution=100

fil714='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\spec\shaun_81731.spe'
read_spe, fil714, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
d714=d
lam714=lam
p=plot(reverse(lam714), d714(*,3,3), title='Spectrum centered at 714 nm',xtitle='Wavelength/nm',ytitle='Intensity')
p.save, 'Spectrum centered at 714 nm.png',resolution=100

fil739='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\spec\shaun_81732.spe'
read_spe, fil739, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
d739=d
lam739=lam
p=plot(reverse(lam739), d739(*,3,3), title='Spectrum centered at 739 nm',xtitle='Wavelength/nm',ytitle='Intensity')
p.save, 'Spectrum centered at 739 nm.png',resolution=100


stop
end




fil='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\SPE 2014\extra_spec.txt
sd=read_ascii(fil)
stop
r=(findgen(100)+1.0)*0.1
restore, 'Ratio data for filter 658.0 with 1 nm width with 3 cavity.save'
d=sc1r/sc2r
p3=plot(1.0/r,d(*,255), title='Contrast change with line ratio I1/I2 ',xtitle='Carbon line ratio I1/I2',ytitle=' Contrast',color='red',name='center at 658.0 nm width width 1.0nm ')
restore, 'Ratio data for filter 658.0 with 0.8 nm width with 3 cavity.save'
d=sc1r/sc2r
p4=plot(1.0/r,d(*,255), title='Contrast change with line ratio I1/I2 ',xtitle='Carbon line ratio I1/I2',ytitle='Contrast',color='blue',name='center at 658.0 nm width width 0.8nm ',/overplot)
l=legend(target=[p3,p4],position=[0.90,0.58,0.94,0.63],/AUTO_TEXT_COLOR)

stop


restore, 'Ratio data for filter 659 with 3 nm width.save'
p=plot(sc2r(*,255), title='658.288nm ratio for 659nm with 3 nm width filters ',xtitle='X pixel',ytitle='H alpha ratio',color='red',name='3 cavity')
restore, 'Ratio data for filter 659 with 3 nm width with 4 cavity.save'
p1=plot(sc2r(*,255), title='658.288 nm ratio for 659nm with 3 nm width filters ',xtitle='X pixel',ytitle='H alpha ratio',color='blue',name='4 cavity',/overplot)
restore, 'Ratio data for filter 659 with 3 nm width with 5 cavity.save'
p2=plot(sc2r(*,255), title='658.288 nm for 659nm with 3 nm width filters ',xtitle='X pixel',ytitle='H alpha ratio',name='5 cavity',/overplot)
l=legend(target=[p,p1,p2],position=[0.90,0.88,0.94,0.93],/AUTO_TEXT_COLOR)




stop
end