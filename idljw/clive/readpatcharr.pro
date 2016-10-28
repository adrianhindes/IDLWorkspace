pro readpatcharr,strarr2
path=getenv('HOME')+'/idl/clive/settings/'
readtextc,path+'log_probe.csv',data0,nskip=0
data=data0
head=data[*,0]
data=data[*,1:*]

idx=where(data[0,*] ne '')
shl = long(data[0,idx])
rng=minmax(shl)
n=rng(1)-rng(0)+1
strtmp={shot:0.,rad:0.,kh:0.,satsw:'',good:'',date:''}
strarr2=replicate(strtmp,n)
for i=0,n-1 do begin
;   print,rng(0)+i
   readpatchpr,rng(0)+i,dum,data=data0
   strtmp={shot:0.,rad:0.,kh:0.,satsw:'',good:'',date:''}
   dum.shot=rng(0)+i
   if n_elements(dum) ge 1 then begin
      for j=0,4 do begin
         strtmp.(j)=dum.(j)
;         print,dum.(j),strtmp.(j)
      endfor
      mdsopen,'h1data',rng(0)+i
      dtt=mdsvalue('DATE_TIME(GETNCI(.OPERATIONS:A14_1:INPUT_1,"TIME_INSERTED"))',/quiet)
      mdsclose
      strtmp.(5)=strmid(dtt,0,11)

      strarr2(i)=strtmp
   endif

endfor

end

   
