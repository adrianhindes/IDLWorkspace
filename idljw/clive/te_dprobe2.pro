@pr_prof2


;tw=[.035,.04];-0.005
tw=[0.038,0.043]

if ii eq 0 then begin&
pos=138&sh1=83863&sh2=83865;138 (core)
endif
if ii eq 1 then begin&
pos=188&sh1=83860&sh2=83867;188(mid)
pos=188&sh1=83860&sh2=83867;188(mid)
endif
if ii eq 2 then begin&
pos=231&sh1=83858&sh2=83868;231(edge)
pos=231&sh1=83858&sh2=83869;231(edge)
endif
vfl=getpar(sh1,'vfloat',tw=tw,y=yvfl)
vpl=getpar(sh1,'vplasma',tw=tw,y=yvpl)
vplus=getpar(sh2,'vplusfork',tw=tw,y=yvplus)
print,vfl,vplus
temp=(vplus-vfl) / alog(2)
temp_bp3 = (vpl-vfl) / 3.76
temp_bp2 = (vpl-vfl) / 2.5




probe_charnew,sh1,tavg=tw,varthres=7.*3*(-1),filterbw=0,qty='tesw',/doplot,qavg=dum,qst=dum2 ,/recalc,yval=y,/rfoff


print,'rad=',(1112+pos)/10.,'cm'
print,'tripe prrobe temp=',temp
print,'swept temp=',dum
print,'ball pen probe 3.76 temp=',temp_bp3
print,'ball pen probe 2.5 temp=',temp_bp2


 ytemp=(yvplus.v-yvfl.v) / alog(2)
 ytempbp3=(yvpl.v - yvplus.v)/3.76

wset2,0
; tr=40e-3 + [-1e-3,3e-3]
 plot,yvpl.t,ytempbp3,xr=tw,yr=[-2,30],xsty=1
 oplot,yvpl.t,ytemp,col=2
 oplot,y.t,y.v,col=3
wset2,1

probe_charnew,sh1,tavg=tw,varthres=7.*3*0,filterbw=0,qty='cur2',/doplot,qavg=dum,qst=dum2 ,yval=y,/rfoff,/recalc

;plot,yvplus.t,yvplus.v,xr=tw,xsty=1
;oplot,yvfl.t,yvfl.v,col=2
plot,y.t,y.v,xr=tw,xsty=1

 stop

end

