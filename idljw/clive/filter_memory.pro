pro filter_memory, sh,nmedian=nmedian,nstddev=nstddev,istart=istart,iend=iend
common cbfilter, sh1, seq,frarr
;sh=13218

d=getimgnew(sh,-1,info=info,/getinfo,/noxbin)
db='k'
;stop
;n=info.num_images
default,istart,0
default,iend,info.num_images-1
frarr=long(intspace(istart,iend))
n=n_elements(frarr)
   for i=0,n-1 do begin
      print, 'getting image',i,'out of ',n,frarr(i)
    ;stop
      dum=getimgnew( sh,frarr(i),twant=twant,str=str,info=info,getinfo=getinfo,nostop=nostop,noloadstr=noloadstr,roi=roi,db=db, noread=noread,copy_tdms=copy_tdms,noxbin=1, nosubindex=nosubindex,getflc=getflc)

      if i eq 0 then begin
         sz=size(dum,/dim)
         seq=intarr(sz(0),sz(1),n)
      endif
      seq(*,*,i)=dum
   endfor


      for i=0,sz(0)-1 do begin
         print,i,sz(0)
         for j=0,sz(1)-1 do seq(i,j,*)=adaptive_median(reform(seq(i,j,*)),nmedian=nmedian,nstddev=nstddev)
      endfor

sh1=seq
print,'done'

end
