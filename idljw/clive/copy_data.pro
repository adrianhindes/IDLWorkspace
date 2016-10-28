;pro doit,num
dirout='D:\MDSPLUS_DATA\PLL2_DATA\'

dir1='X:\papers\Labview\data\calibration data\experiments\'
fil1a='pll'
fil1b='pll'
ext1a='.lvm';tdms'
ext1b='.tdms_index'
dir2='Y:\'
fil2='test'
ext2='.SPE'

;goto,af
num=0
restore,file=dirout+'shotnum.sav'
num=num+1
print,'shot to be saved is',num
read,'enter number',num
nums=string(num,format='(I0)')


file_copy,dir1+fil1a+ext1a,dirout+fil1a+nums+ext1a;,/over
;file_copy,dir1+fil1b+ext1b,dirout+fil1b+nums+ext1b,/over
;file_copy,dir2+fil2+ext2,dirout+fil2+nums+ext2;,/over
file_delete,dir1+fil1a+ext1a
;file_delete,dir1+fil1b+ext1b
save,num,file=dirout+'shotnum.sav',/verb
yn=''
read,'do you want to convert (y/n)',yn
if yn ne 'y' then retall
af:

nums=string(num,format='(I0)')
dum=read_ascii(dirout+fil1a+nums+ext1a,data_start=23,delim=string(byte(9)))
data=dum.(0)
save,data,file=dirout+fil1a+nums+'.sav',/verb
;21 first real one
;22 with delay seq-good
;23 next wider filter
t=data(0,*)
dc=data(1,*)
sq=data(2,*)
gate=data(3,*)
osc=data(4,*)
plot,t,dc,pos=posarr(1,4,0),title='dc'
plot,t,sq,pos=posarr(/next),/noer,title='sq'
plot,t,gate,pos=posarr(/next),/noer,title='gate'
plot,t,osc,pos=posarr(/next),/noer,title='osc'
end

;for sh=32,40 do doit,sh
;end
