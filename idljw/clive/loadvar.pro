function loadvar,var,n
openr,lun,var,/get_lun
d=dblarr(n)
readu,lun,d
close,lun
free_lun,lun
return,d
end
