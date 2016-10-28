pro ds_profile, set, tw, rad, prof
if set eq '1st' then begin
sharr=[414,415,418,427,428,429]+86000L
rad=[190,180,210,220,230,240]
endif

if set eq '2nd' then begin
sharr=[73,81,93,101]+87700L
rad=[230,240,250,260]
endif

if set eq '3rd' then begin
sharr=[1,2,3,4,5,6,7]+87720L
rad=[260,260,230,240,230,220,210]
endif


if set eq '4th' then begin
sharr=[22,23,24,25,26,27]+87700L
rad=[260,250,240,230,220,210]
endif


n=n_elements(sharr)
prof=fltarr(n)
for i=0,n-1 do begin
prof(i)= getpar( sharr(i), 'isat', tw=tw);,y=y,st=st,data=data
;prof(i)= getpar( sharr(i), 'vplasma', tw=tw);,y=y,st=st,data=data
endfor

end

pro dscmp
;tw=[.08,.09]
tw=[.02,.03]
ds_profile,'3rd',tw,rad,prof
ds_profile,'1st',tw,rad3,prof3
;ds_profile,'4th',tw,rad4,prof4
plot,rad,prof,psym=4,xr=[200,320]
oplot,rad3+45,prof3*3.5,col=2,psym=4
;oplot,rad4,prof4,col=4,psym=4
stop
end

;sh=87773 & tw=[.03,.04];230
;sh=87781 & tw=[.03,.04]; 240
;sh=87793 & tw=[.03,.04]; 250 ; in .015to.025 is cleraly out, what is rotation?
;sh=87801 & tw=[.01,.02]; 260
