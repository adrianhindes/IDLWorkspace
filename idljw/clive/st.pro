@lkece
;sh=9323 & ch=47-5

goto,a
sh=10997 & ch=37
getece, sh,res,v,t,r
a:
;imgplot,res.v,res.t,-res.r,pos=posarr(/next),/cb,xr=!x.crange,/noer
pos=posarr(1,1,0)
erase
plot,t,smooth(v(*,ch),30),xsty=1,pos=posarr(/curr),/noer,/yno,title='ece temperature ch'+string(ch,format='(I0)'),xtitle='time',xr=xr
vs=smooth(v(*,ch,*),1000)
;oplot,t,vs,col=2
plot,t,smooth(v(*,ch),100)-vs,xr=!x.crange,pos=posarr(/curr),/noer,col=4,xsty=4+1,ysty=4
end
