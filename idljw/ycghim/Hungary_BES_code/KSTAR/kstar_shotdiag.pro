pro kstar_shotdiag,shot,timerange=timerange,store=store,noerase=noerase,nolegend=nolegend,$
            yrange_ip=yrange_ip,thick=thick,charsize=charsize

default,thick,1
default,charsize,0.8
default,timerange,[-0.5,15.5]

if (not defined(shot)) then return

ncol=4
nrow =3
pos = [0.1,0.1,0.9,0.9]
xstep = (pos[2]-pos[0])/ncol
ystep = (pos[3]-pos[1])/nrow
yplot = 0.6
xplot = 0.7

if (not keyword_set(noerase)) then erase
if (not keyword_set(nolegend)) then time_legend,'kstar_shotdiag.pro'

row = 1 & col= 1
pos_act = [pos[0]+(col-1)*xstep, pos[3]-row*ystep, pos[0]+(col-1+xplot)*xstep, pos[3]-(row-yplot)*ystep]
get_rawsignal,shot,'KSTAR/IP',timerange=timerange,store=store,t,d,errormess=e
if (e ne '') then return
d =d*1000
default,yrange_ip,[0,max(d)*1.05]
plot,t,d,xrange=timerange,xtitle='Time [s]',xstyle=1,xthick=thick,$
               yrange=yrange_ip,ystyle=1,ytitle='[kA]',ythick=thick,title=i2str(shot)+' I!Dp!N',$
               charsize=charsize,thick=thick,charthick=thick,pos=pos_act,/noerase

row = 1 & col= 2
pos_act = [pos[0]+(col-1)*xstep, pos[3]-row*ystep, pos[0]+(col-1+xplot)*xstep, pos[3]-(row-yplot)*ystep]
get_rawsignal,shot,'KSTAR/P_NBI1',timerange=timerange,store=store,t,d,errormess=e
if (e eq '') then begin
  default,yrange_pnb1,[0,max(d)*1.05]
  plot,t,d,xrange=timerange,xtitle='Time [s]',xstyle=1,xthick=thick,$
               yrange=yrange_pnb1,ystyle=1,ytitle='[MW]',ythick=thick,title=i2str(shot)+' P!DNB1!N',$
               charsize=charsize,thick=thick,charthick=thick,pos=pos_act,/noerase
endif else begin
  xyouts,pos_act[0], (pos_act[3]+pos_act[1])/2,'No NBI1',/norm
endelse

row = 1 & col= 3
pos_act = [pos[0]+(col-1)*xstep, pos[3]-row*ystep, pos[0]+(col-1+xplot)*xstep, pos[3]-(row-yplot)*ystep]
get_rawsignal,shot,'KSTAR/P_NBI2',timerange=timerange,store=store,t,d,errormess=e
if (e eq '') then begin
  default,yrange_pnb2,[0,max(d)*1.05]
  plot,t,d,xrange=timerange,xtitle='Time [s]',xstyle=1,xthick=thick,$
               yrange=yrange_pnb1,ystyle=1,ytitle='[MW]',ythick=thick,title=i2str(shot)+' P!DNB2!N',$
               charsize=charsize,thick=thick,charthick=thick,pos=pos_act,/noerase
endif else begin
  xyouts,(pos_act[2]+pos_act[0])/2, (pos_act[3]+pos_act[1])/2,'No NBI2',/norm
endelse

row = 1 & col= 4
pos_act = [pos[0]+(col-1)*xstep, pos[3]-row*ystep, pos[0]+(col-1+xplot)*xstep, pos[3]-(row-yplot)*ystep]
get_rawsignal,shot,'KSTAR/P_NBI3',timerange=timerange,store=store,t,d,errormess=e
if (e eq '') then begin
  default,yrange_pnb2,[0,max(d)*1.05]
  plot,t,d,xrange=timerange,xtitle='Time [s]',xstyle=1,xthick=thick,$
               yrange=yrange_pnb1,ystyle=1,ytitle='[MW]',ythick=thick,title=i2str(shot)+' P!DNB3!N',$
               charsize=charsize,thick=thick,charthick=thick,pos=pos_act,/noerase
endif else begin
  xyouts,(pos_act[2]+pos_act[0])/2, (pos_act[3]+pos_act[1])/2,'No NBI3',/norm
endelse

row = 2 & col= 1
pos_act = [pos[0]+(col-1)*xstep, pos[3]-row*ystep, pos[0]+(col-1+xplot)*xstep, pos[3]-(row-yplot)*ystep]
get_rawsignal,shot,'KSTAR/\POL_HA03',timerange=timerange,store=store,t,d,errormess=e
if (e eq '') then begin
  default,yrange_HA03,[0,max(d)*1.05]
  order = fix(alog10(yrange_HA03[1]))
  plot,t,d/10.^order,xrange=timerange,xtitle='Time [s]',xstyle=1,xthick=thick,$
               yrange=yrange_HA03/10.^order,ystyle=1,ytitle='x10!U'+i2str(order)+'!N [a. u.]',ythick=thick,title=i2str(shot)+'Pol. H!X!Da!X!N  (HA03)',$
               charsize=charsize,thick=thick,charthick=thick,pos=pos_act,/noerase
endif else begin
  xyouts,pos_act[0], (pos_act[3]+pos_act[1])/2,'No HA03',/norm
endelse

row = 2 & col= 2
pos_act = [pos[0]+(col-1)*xstep, pos[3]-row*ystep, pos[0]+(col-1+xplot)*xstep, pos[3]-(row-yplot)*ystep]
get_rawsignal,shot,'KSTAR/\POL_HA02',timerange=timerange,store=store,t,d,errormess=e
if (e eq '') then begin
  default,yrange_HA02,[0,max(d)*1.05]
  order = fix(alog10(yrange_HA02[1]))
  plot,t,d/10.^order,xrange=timerange,xtitle='Time [s]',xstyle=1,xthick=thick,$
               yrange=yrange_HA02/10.^order,ystyle=1,ytitle='x10!U'+i2str(order)+'!N [a. u.]',ythick=thick,title=i2str(shot)+'Pol. H!X!Da!X!N  (HA02)',$
               charsize=charsize,thick=thick,charthick=thick,pos=pos_act,/noerase
endif else begin
  xyouts,pos_act[0], (pos_act[3]+pos_act[1])/2,'No HA02',/norm
endelse

row = 2 & col= 3
pos_act = [pos[0]+(col-1)*xstep, pos[3]-row*ystep, pos[0]+(col-1+xplot)*xstep, pos[3]-(row-yplot)*ystep]
get_rawsignal,shot,'KSTAR/\POL_HA09',timerange=timerange,store=store,t,d,errormess=e
if (e eq '') then begin
  default,yrange_HA09,[0,max(d)*1.05]
  order = fix(alog10(yrange_HA09[1]))
  plot,t,d/10.^order,xrange=timerange,xtitle='Time [s]',xstyle=1,xthick=thick,$
               yrange=yrange_HA09/10.^order,ystyle=1,ytitle='x10!U'+i2str(order)+'!N [a. u.]',ythick=thick,title=i2str(shot)+'Tor. H!X!Da!X!N  (HA09)',$
               charsize=charsize,thick=thick,charthick=thick,pos=pos_act,/noerase
endif else begin
  xyouts,pos_act[0], (pos_act[3]+pos_act[1])/2,'No HA09',/norm
endelse

row = 3 & col= 1
pos_act = [pos[0]+(col-1)*xstep, pos[3]-row*ystep, pos[0]+(col-1+xplot)*xstep, pos[3]-(row-yplot)*ystep]
get_rawsignal,shot,'KSTAR/NEL',timerange=timerange,store=store,t,d,errormess=e
if (e eq '') then begin
  default,yrange_mw,[0,max(d)*1.05]
  plot,t,d,xrange=timerange,xtitle='Time [s]',xstyle=1,xthick=thick,$
               yrange=yrange_mw,ystyle=1,ytitle='x10!U19!N[m!U-2!N]',ythick=thick,title=i2str(shot)+'  MW interferometer',$
               charsize=charsize,thick=thick,charthick=thick,pos=pos_act,/noerase
endif else begin
  xyouts,pos_act[0], (pos_act[3]+pos_act[1])/2,'No MW interferometer',/norm
endelse




row = 3 & col= 3
pos_act = [pos[0]+(col-1)*xstep, pos[3]-row*ystep, pos[0]+(col-1+xplot)*xstep, pos[3]-(row-yplot)*ystep]
;get_rawsignal,shot,'(ECH_VFWD1:FOO-0.23)*105/1000.',timerange=timerange,store=store,t,d,errormess=e
get_rawsignal,shot,'\EC1_rffwd1/1E3',timerange=timerange,store=store,t,d,errormess=e
if (e eq '') then begin
  default,yrange_ECH,[0,max(d)*1.05]
  plot,t,d,xrange=timerange,xtitle='Time [s]',xstyle=1,xthick=thick,$
               yrange=yrange_ECH,ystyle=1,ytitle='[kW]',ythick=thick,title=i2str(shot)+'  ECH Power',$
               charsize=charsize,thick=thick,charthick=thick,pos=pos_act,/noerase
endif else begin
  xyouts,pos_act[0], (pos_act[3]+pos_act[1])/2,'No ECH signal',/norm
endelse

end
