pro 4qdemod, sh, test=test

if keyword_set(test) then begin
   cal=getimgnew(47,0,db='calnew')*1.
   calblack=cal*0
endif else begin

if keyword_set(test) then begin
   cal=getimgnew(sh,0,db='calnew')*1.
   calblack=getimgnew(sh,0,db='calbgnew')*1.
endif else begin

cal=cal-calblack


demodtype='basicqcell'
db='cnew'
lam=529.e-9

newdemod, cal,carscal,sh=sh,db=db,lam=lam,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,/doplot

stop
;,/doplot
;for i=0,4 do if i ne 1 then carscal(*,*,i)=carscal(*,*,i)/carscal(*,*,1)


dum=getimgnew(sh,0,info=info,/get_info)
nfr=info.num_images
for i=0,nfr-1 do begin
   img=getimgnew(sh,i)
   newdemod,img,cars,sh=sh,db=db,lam=lam,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy ;,/doplot
;stop
for i=0,4 do if i ne 1 then cars(*,*,i)=cars(*,*,i)/cars(*,*,1)


endfor


end


4qdemod,47,/test
end
