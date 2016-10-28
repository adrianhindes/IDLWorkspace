pro fqdemod, sh, test=test,nocal=nocal

demodtype='basicqcell'
db='cnew'
lam=529.e-9

if keyword_set(nocal) then goto,af
if keyword_set(test) then begin
   cal=getimgnew(47,0,db='calnew')*1.
   calblack=cal*0
endif else begin
   cal=getimgnew(sh,0,db='calnew')*1.
   calblack=getimgnew(sh,0,db='calbgnew')*1.
endelse
cal=cal-calblack
newdemod, cal,carscal,sh=sh,db=db,lam=lam,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy,doplot=0,kx=kx,ky=ky,kz=kz
carscal(*,*,1)/=carscal(*,*,0)/2;contrast

af:


dum=getimgnew(sh,0,db=db,info=info,/getinfo)
nfr=info.num_images
;if keyword_set(test) then nfr=2
for i=0,nfr-1 do begin
   img=getimgnew(sh,i,db=db)
   newdemod,img,cars,sh=sh,db=db,lam=lam,demodtype=demodtype,ix=ix,iy=iy,p=str,thx=thx,thy=thy ;,/doplot
;stop
   cars(*,*,1)/=cars(*,*,0)/2   ;contrast
   if not keyword_set(nocal) then cars(*,*,1) /= carscal(*,*,1)

   if i eq 0 then begin
      sz=size(cars,/dim)
      cars2=complexarr(sz(0),sz(1),nfr,2)
   endif
   cars2(*,*,i,*) = reform(cars,[sz(0),sz(1),1,2])
   print, 'done frame ',i,'of ',nfr
endfor


tree='cxrs_2014'
shotno=sh
mdsedit, tree, shotno
find_or_create_node, '.ANALYSIS'
;find_or_create_node, '.ANALYSIS:INTENISTY', usage='signal'

put_image_array,tree,shotno,'.ANALYSIS:INTENSITY',float(cars2(*,*,*,0)),findgen(nfr)

put_image_array,tree,shotno,'.ANALYSIS:CONTRAST',abs(cars2(*,*,*,1)),findgen(nfr)

put_image_array,tree,shotno,'.ANALYSIS:PHASE',atan2(cars2(*,*,*,1)),findgen(nfr)

;mdsput, '.ANALYSIS:INTENISTY', '*',cars(*,*,*,0)

;mdswrite, tree, shotno


    

end




fqdemod,47,/test
end
