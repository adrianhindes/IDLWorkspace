pro emissionData

path='/media/adrian/Elements/camware'

shot = '41'
shotLength = 50 ;ms
shotLength = 0.001*shotLength

backShot = '55'

backShotLength = 5 ;seconds

timeScale = shotLength/backShotLength

background = read_tiff(backShot+'.tif')
shotImage = read_tiff(shot+'.tif')

background = background * timeScale
;Calculation
emission = shotImage/background


radiance = 3.617E15
;fwhm = 3E-9 of filter
ionPathL = 0.05
sxb = 10
emission = radiance*3*emission*sxb


print,emission



stop

end