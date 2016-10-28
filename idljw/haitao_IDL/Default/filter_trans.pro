pro filter_trans

bi=read_tiff('C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 22-01-2014\before3.tif')
ai=read_tiff('C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 22-01-2014\after3.tif')
bi1=read_tiff('C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 22-01-2014\before4.tif')
ai1=read_tiff('C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 22-01-2014\after4_1.tif')
bi2=read_tiff('C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 22-01-2014\before5.tif')
ai2=read_tiff('C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 22-01-2014\after5.tif')

b=read_tiff('C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 22-01-2014\background3.tif')
b1=read_tiff('C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 22-01-2014\background4.tif')
b2=read_tiff('C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 22-01-2014\background5.tif')
bi=float(bi-b)
ai=float(ai-b)
c=bi-ai
bi1=float(bi1-b1)
ai1=float(ai1-b1)
c1=bi1-ai1
bi2=float(bi2-b2)
ai2=float(ai2-b2)
c2=bi2-ai2
p=plot(c(*,1138)/bi(*,1138), xtitle='X pixel', ytitle='Percentage of transmission decrease', title='Transmission decrease distribution')
;p1=plot(c1(*,1138)/bi1(*,1138), xtitle='X pixel', ytitle='Percentage of transmission decrease', title='Transmission decrease distribution')
p2=plot(c2(*,1020)/bi2(*,1020), xtitle='X pixel', ytitle='Percentage of transmission decrease', title='Transmission decrease distribution')
stop
end