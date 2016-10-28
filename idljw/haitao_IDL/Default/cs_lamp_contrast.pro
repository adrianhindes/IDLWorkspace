pro cs_lamp_contrast
fil1='C:\haitao\papers\study topics\H-1 projection\data and results\savart plate data\adding 15mm delay.tif'
fil2='C:\haitao\papers\study topics\H-1 projection\data and results\savart plate data\adding 20mm delay.tif'
fil3='C:\haitao\papers\study topics\H-1 projection\data and results\savart plate data\adding 25mm delay.tif'
fil4='C:\haitao\papers\study topics\H-1 projection\data and results\savart plate data\adding 35mm delay.tif'
fil5='C:\haitao\papers\study topics\H-1 projection\data and results\savart plate data\adding 40 mm delay with savart plate.tif'
fil6='C:\haitao\papers\study topics\H-1 projection\data and results\savart plate data\adding 45 mm delay with savart plate.tif'
back='C:\haitao\papers\study topics\H-1 projection\data and results\savart plate data\black picture 4.tif'
fil=[fil1,fil2,fil3,fil4, fil5,fil6]
raw_data=make_array(2560,2160,6,/float)

for i=0,5 do begin
  raw_data(*,*,i)=read_tiff(fil(i));-read_tiff(back)
endfor
contrast_arr=make_array(6,/float)
pick_data=reform(raw_data(1000, 1000:1100,*))
for j=0,5 do begin
  contrast_arr(j)=(max(pick_data(*,j))-min(pick_data(*,j)))/(max(pick_data(*,j))+min(pick_data(*,j)))
endfor
length=[15,20,25,35,40,45]
p=plot(length,contrast_arr,xtitle='LiNO3 thickness/mm',ytitle='Contrast', title='Contrast variation with wave plate thickness')
stop
end