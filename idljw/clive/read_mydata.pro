pro read_mydata,d0,path=path,shotno=no,duration=duration,timestamps=d1

default,path,'~/share/vs/Projects/ConsoleApplication2/x64/Release/'
;default,path,'./'
file='clive_'
ext='.dat'

default,no,1


fname=path+file+string(no,format='(I0)')+ext

openr,lun,fname,/get_lun

h=lonarr(4)
readu,lun,h

nfr=h(0)
nreadout=h(1)

xdim=h(2)
ydim=h(3)


duration=lonarr(nfr)

readu,lun,duration


d=uintarr(nreadout/2,nfr)
readu,lun,d

close,lun & free_lun,lun


d0=d(0:xdim*ydim-1,*)
d0=reform(d0,xdim,ydim,nfr)
if xdim*ydim*2 lt nreadout then d1=d(xdim*ydim:*,*)

;imgplot,d(*,*,0)


end


