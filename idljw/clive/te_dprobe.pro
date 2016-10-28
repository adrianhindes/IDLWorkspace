@pr_prof2


tw=[.035,.04];-0.005

if ii eq 0 then begin&
pos=138&sh1=83863&sh2=83865;138 (core)
endif
if ii eq 1 then begin&
pos=188&sh1=83860&sh2=83867;188(mid)
endif
if ii eq 2 then begin&
pos=231&sh1=83858&sh2=83869;231(edge)
endif
vfl=getpar(sh1,'vfloat',tw=tw,y=yvfl)
vpl=getpar(sh1,'vplasma',tw=tw,y=yvpl)
vplus=getpar(sh2,'vplusfork',tw=tw,y=yvplus)
print,vfl,vplus
temp=(vplus-vfl) / alog(2)
temp_bp3 = (vpl-vfl) / 3.76
temp_bp2 = (vpl-vfl) / 2.5


;; ytemp=(yvplus.v-yvfl.v) / alog(2)
;; ytempbp3=(yvpl.v - yvplus.v)/3.76

;; tr=40e-3 + [-1e-3,1e-3]
;; plot,yvpl.t,ytempbp3,xr=tr,yr=[-2,10]
;; oplot,yvpl.t,ytemp,col=2

;; stop


probe_charnew,sh1,tavg=tw,varthres=7.*3,filterbw=0,qty='tesw',/doplot,qavg=dum,qst=dum2 ,/recalc
print,'rad=',(1112+pos)/10.,'cm'
print,'tripe prrobe temp=',temp
print,'swept temp=',dum
print,'ball pen probe 3.76 temp=',temp_bp3
print,'ball pen probe 2.5 temp=',temp_bp2

end

