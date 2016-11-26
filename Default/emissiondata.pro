pro emissionData

path='/media/adrian/Elements/camware'
cd,path
shot = '41'
shotLength = 50 ;ms
shotLength = 0.001*shotLength

backShot = '55'

backShotLength = 5 ;seconds

timeScale = shotLength/backShotLength

background = read_tiff(backShot+'.tif') ;calibration
shotImage = read_tiff(shot+'.tif')

background = background * timeScale
;Calculation
emission = shotImage/background


radiance = 3.617E15*4.*!pi
;fwhm = 3E-9 of filter
ionPathL = 0.05 ;size of plasma
sxb = 10
emission = radiance*3*emission*sxb/ionPathL

;Emission is the ionization rate

x = 700
y = 520

ionizationRate = emission[x,y]



stop

end