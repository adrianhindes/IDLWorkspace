pro read_mydatapco,d,path=path,shotno=no,angstep=step,theta0=theta0,flipper=status

;default,path,'C:\Users\Admin\Documents\Visual Studio 2015\Projects\Myapp1\Myapp1\';~/share/vs/Projects/ConsoleApplication2/x64/Release/'
;default,path,'./'
default,path,'/data/mse_2015_tests/'
file='clive_'
ext='.dat'

default,no,1


fname=path+file+string(no,format='(I0)')+ext

openr,lun,fname,/get_lun

nx=fix(0)
ny=fix(0)
nfr=long(0)
step=0.
theta0=0.
status=long(0)

readu,lun,nx
readu,lun,ny
readu,lun,nfr

if no ge 45 then begin
readu,lun,step
readu,lun,theta0
readu,lun,status
endif


nreadout=long(nx)*long(ny)*nfr
d=uintarr(nreadout)
readu,lun,d
close,lun & free_lun,lun
d=reform(d,nx,ny,nfr)

status = status and 1


end

;read_mydatapco,d,shotno=2



;end

