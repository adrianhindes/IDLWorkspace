;befit1,10536,10.64,-1,/norun ,db='kl',field=2.5;,/lut


;befit1,11082,1.525,-1,/norun ,db='k',field=3.0,/lut


;befit1,11003,5.95,-1 ,db='k',field=(3.0 + 2.2),/lut
;befit1,11003,3.95,-1 ,db='k',field=(3.0 + 2.2),/lut
;befit1,11003,3.45,-1 ,db='k',field=(3.0 + 2.2),/lut,wt=3.,rrng=[160,222]
befit1,11003,3.7,-1 ,db='k',field=(3.0 + 2.2),/lut,wt=3.,rrng=[160,222],/norun
;befit1,11003,3.45,-1 ,db='k',field=(3.0 + 2.2),/lut,wt=5.,rrng=[160,222],drcm=3
;befit1,11003,3.7,-1 ,db='k',field=(3.0 + 2.2),/lut,wt=5.,rrng=[160,222],drcm=3
;befit1,11003,4.2,-1 ,db='k',field=(3.0 + 2.2),/lut,wt=3.,rrng=[160,222]
;at=5.135
;at=5.345
;at=4.565 ; off 176ish.  what the hell?
;at=4.745 ; on ; 177ish
;befit1,11433,at,-1 ,db='k',field=(2.0 + 0.5 + 2.4),/lut,rrng=[160,222],kff=3,kpp=2,fwtcur=3,wt=1.
;befit1,11433,at,-1 ,db='k',field=(2.0 + 0.5 + 2.4),/lut,rrng=[160,222],kff=3,kpp=2,fwtcur=3
;befit1,11433,at,-1 ,db='k',field=(2.0 + 0.5 + 2.2),/lut,rrng=[160,222],kff=2,kpp=2,fwtcur=3


retall

nt=80
tarr=findgen(nt) * 50e-3 + 2.0
for i=0,nt-1 do begin
if i eq 9 then continue
catch,err
if err ne 0 then continue
befit1,11003,tarr(i),-1 ,db='k',field=(3.0 + 2.2),/lut,wt=5.,rrng=[160,222],drcm=3,fwtcur=10.

;t,wt=3.;,rrng=[166,222]
endfor
;; 2.2 seeming fioeld offset (deg/t so about 4.4deg) for earlier eccd 2014 results


;befit1,9323,1.925,1.950,field=3.,/norun



end
