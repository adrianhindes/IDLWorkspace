pro nebula_read_pinigrid,xpini,ypini, pn=pn
PINI=fltarr(2,131)
pgrfile='~/idl/clive/knebula/GRID_MKIII.dat'
str1=''
get_lun,unit1         
  openr,unit1, pgrfile
  readf,unit1,str1              
  readf,unit1,a
  readf,unit1,xoffset
  readf,unit1,yoffset
  readf,unit1,d
  readf,unit1,e
  readf,unit1,f
  readf,unit1,str1 
  readf,unit1,str1           
  readf,unit1,str1 
  readf,unit1,PINI
  free_lun,unit1              
  close,unit1          

xpini=(PINI[1,*]-xoffset)*1e-1 ;from mm to cm
ypini=(PINI[0,*]-yoffset)*1e-1


end
