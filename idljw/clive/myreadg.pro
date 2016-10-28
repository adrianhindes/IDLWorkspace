function myreadg,arg,arg2,runid=runid,force=force
path='~/idl'
fil=path+'/'+string(arg,"_",arg2,format='(I0,A,I0)')+'.sav'
dum=file_search(fil,count=cnt)
if keyword_set(force) then cnt=0
if cnt ne 0 then begin
    restore,file=fil
    return,g
endif 
spawn,'hostname',host
if host ne 'ikstar.nfri.re.kr' then mdsconnect,'172.17.250.100:8005'
mdsopen,'kstar',arg
g=readg(arg,arg2,runid=runid)
mdsclose
mdsdisconnect
save,g,file=fil,/verb
return,g
end

;info=efit_read_setinfo(7427,3000,type='G') 
;d=efit_read_mdsreadall(info,/verbose)      
