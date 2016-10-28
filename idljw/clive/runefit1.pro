pro runefit1, sh=sh,tw=tw,dirmod=dirmod,kff=kff,kpp=kpp,fwtcur=fwtcur
default,fwtcur,1.

default,kff,4
default,kpp,2
spawn,'hostname',hostname
if hostname ne 'ikstar.nfri.re.kr' then begin
   cmd0 ='ssh -p 2201 cmichael@172.17.250.100 idl -e '
   cmd1='runefit1,sh='+string(sh,format='(I0)')+',tw='+string(tw,format='(G0)')+',kff='+string(kff,format='(I0)')+',kpp='+string(kpp,format='(I0)')+',fwtcur='+string(fwtcur,format='(G0)')
   cmd=cmd0+cmd1
;   print,cmd
;   spawn,cmd

   cmdfile='/home/cam112/ikstar/idl/clive/listenrun.cmd'
   cmdfile2='/home/cam112/ikstar/idl/clive/listenrundone'

   file_delete,cmdfile2,/quiet

   openw,lun,cmdfile,/get_lun
   printf,lun,cmd1
   close,lun & free_lun,lun
   again:
   dum=file_search(cmdfile2,count=cnt)
   if cnt eq 0 then begin
      wait,1
      print,'there'
      goto,again
   endif
   print,'done'

   return
endif



cd,current=curr
default,dirmod,''
dir='/home/users/cmichael/my2/EXP00'+string(sh,format='(I0)')+'_k'+dirmod


cd,dir

fspec=string(sh,tw*1000,format='(I6.6,".",I6.6)')

runstr='cat k'+fspec+' msenl_'+fspec+' > kk'+fspec
print,runstr
spawn,runstr

if kpp eq -1 then kpp=0
print,'hello matthew'
;runstrb='~/my2/modk.sh kk'+fspec+' '+string(kff,format='(I0)')+' '+string(kpp,format='(I0)')
runstrb='~/my2/modk2.sh kk'+fspec+' '+string(kff,format='(I0)')+' '+string(kpp,format='(I0)')+' '+string(fwtcur,format='(G0)')
print,runstrb
spawn,runstrb


openw,lun,'input.txt',/get_lun
printf,lun,'2'
printf,lun,'1'
printf,lun,'kk'+fspec
close,lun
free_lun,lun

runstr2='~/EFIT/efitbuild_k/efitd6565d < input.txt > bdat.txt'

spawn,runstr2
spawn,'cat bdat.txt'

cd,curr


end

