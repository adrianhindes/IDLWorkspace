pro intensity_profile,sam_col



fil0='C:\haitao\papers\study topics\H-1 projection\data\plasma data\md_79567.SPE'
fil1='C:\haitao\papers\study topics\H-1 projection\data\plasma data\md_79568.SPE'
fil2='C:\haitao\papers\study topics\H-1 projection\data\plasma data\md_79569.SPE'
fil3='C:\haitao\papers\study topics\H-1 projection\data\plasma data\md_79570.SPE'
fil4='C:\haitao\papers\study topics\H-1 projection\data\plasma data\md_79571.SPE'
fil5='C:\haitao\papers\study topics\H-1 projection\data\plasma data\md_79572.SPE'
fil6='C:\haitao\papers\study topics\H-1 projection\data\plasma data\md_79573.SPE'
fil7='C:\haitao\papers\study topics\H-1 projection\data\plasma data\md_79574.SPE'
fil8='C:\haitao\papers\study topics\H-1 projection\data\plasma data\md_79575.SPE'
fil9='C:\haitao\papers\study topics\H-1 projection\data\plasma data\md_79576.SPE'
fil10='C:\haitao\papers\study topics\H-1 projection\data\plasma data\md_79582.SPE'
fil11='C:\haitao\papers\study topics\H-1 projection\data\plasma data\md_79583.SPE'
fil12='C:\haitao\papers\study topics\H-1 projection\data\plasma data\md_79584.SPE'
fil13='C:\haitao\papers\study topics\H-1 projection\data\plasma data\md_79585.SPE'
rf_power=[7.61703821695,8.94723475586,10.4326805409,12.0189409568,13.7188882858,15.536441573,17.3804824302,19.3535879459,21.4806851988,23.6084755658,24.1024513949,27.2255987063,30.2034336239,33.6868954557]
fil_arr=[fil0,fil1,fil2,fil3,fil4,fil5,fil6,fil7,fil8,fil9,fil10,fil11,fil12,fil13]

sam_arr=make_array(128,5,14)
for i=0,13 do begin
read_spe, fil_arr(i), lam, t,d,texp=texp,str=str,fac=fac & & d=float(d)
   for j=0,4 do begin
   sam_arr(*,j,i)=d(sam_col,*,j+17)-d(sam_col,*,0)
   endfor
   endfor
;x=findgen(1000)*0.05
y=findgen(128)
;sam_arr1= transpose(sam_arr(*,*,13))
;int_time=image(rebin(sam_arr1,1000,1280),x,y,title='Intensity variation with time of shotno 77585 ',rgb_table=4,axis_style=1,xtitle='Time/ms',ytitle='Y pixel',aspect_ratio=0.2)


sam_arr2= transpose(reform(sam_arr(*,4,*)))
;int_time=image(sam_arr2,title='Intensity variation with time of shotno 77585 ',rgb_table=4,axis_style=1,xtitle='Time/ms',ytitle='Y pixel',aspect_ratio=0.5)
;c=colorbar(target=int_time)
imgplot, sam_arr2,rf_power,y,title='Intensity variation with power of 5 frame',/cb
mdsconnect,'h1ds'  
mdsopen, 'h1data',79567  
y=mdsvalue('\H1DATA::TOP.RF:P_RF_NET')
t=mdsvalue('DIM_of(\H1DATA::TOP.RF:P_RF_NET)')   
   
   
   
stop


end
   