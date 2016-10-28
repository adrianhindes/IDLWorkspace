pro mdftomo,m,theta
;phase checking
;shot='376'
;restore, 'result'+shot+'.save'
;mdata=result.ippha
;mdata_dc=result.i
;intphase=atan(result.ippha,/phase)
;flowphase=atan(result.fppha,/phase)
;phdif=atan(result.fppha/result.ippha,/phase)
;!p.multi=[0.,2,2]
;!p.charsize=1
;plot,findgen(512)*10.0/511.0-5.0,flowphase(*,3),title='Radial phase shift of flow integration of shot376',xtitle='Radius(cm)',ytitle='Phase(radius)'
;plot, findgen(512)*10.0/511.0-5.0,phdif(*,3),title='Phase shift between flow and intensity of shot376',xtitle='Radius(cm)',ytitle='Phase(radius)'
;stop
f=0.135  ;camera focus
radius=0.05 ;plasma radius
sz=24.0*1e-6 ;camera sensor size
pn=512  ;pixel number

;-----------------------------------------------------------------------------
;generating tomography view
;rgrid=findgen(20)*0.05/19
;angle=findgen(100)*!pi*2.0/99.0
;ram=make_array(100,value=rgrid(5))
;p=polarplot(ram,angle,xrange=[-0.06,0.06],yrange=[-0.06,0.06])
;ax = p.AXES
;ax[0].hide = 1
;ax[1].hide = 1
;for i=1,19 do begin
  ;angle=findgen(100)*!pi*2/99.0
 ;ram=make_array(100,value=rgrid(i))
 ;p=polarplot(ram,angle,overplot=1)
 ;endfor
;center=[0.0,1.12]
;for j=0,30 do begin
;vec=[(j-30/2.0)*sz*512.0/30.0,f]
;vec=vec/sqrt(total(vec^2))
;lefts=-1.5
;rights=1.5
;nlat=1.0
;para=findgen(5000.0*nlat)*(rights-lefts)/(5000.0*nlat-1.0)+lefts  ;parameters
;deltat=para(1)-para(0)
;x=vec(0)*para+center(0)
;y=vec(1)*para+center(1)
;r=sqrt(x^2+y^2)
;index=where(r^2 le (radius+0.01)^2)
;index=where(y le (radius+0.02))
;para=para(index)
;x=vec(0)*para+center(0)
;y=vec(1)*para+center(1)
;if (n_elements(x) gt 1.0)then begin
;p=plot(x,y,/overplot,color='blue')
;endif
;endfor
;------------------------------------------------------------------------------------
;stop
;generating spline function
npts=200 ;sampling points
rv=range(0,radius,npts=npts)
nn=48;knots number
;knots=findgen(nn+1)*radius/nn
knots=[0.0,0.05*radius,(findgen(nn-1)+1)*0.95*radius/(nn-2)+0.05*radius];0.92 is good for testing the algorithm
;knots=[0.0,0.05*radius,(findgen(nn-1)+1)*0.95*radius/(nn-2)+0.05*radius]
bfu=splin(radius,npts,knots)
da0=bfu.order0  ;zero-order spline function
da1=bfu.order1
da2=bfu.order2
da3=bfu.order3
;da2=reverse(da2)

;xp=range(-0.05,0.05,npts=npts)
;delsam=xp(1)-xp(0)
;unit = replicate(1.,npts)
;xx = xp#unit
;yy = transpose(xx)
;rr = (xx^2+yy^2)^0.5
;theta=atan(yy,xx)

i_csec=make_array(npts,npts,nn,/float)
i_csec_num=make_array(npts,npts,nn,/float)
i_pro=make_array(pn,nn,/float)
i_pro_num=make_array(pn,8,/float)

flow_csec_x=make_array(npts,npts,nn,/float)
flow_csec_y=make_array(npts,npts,nn,/float)
flow_csec_numx=make_array(npts,npts,nn,/float)
flow_csec_numy=make_array(npts,npts,nn,/float)
flow_pro=make_array(pn,nn,/float)
flow_pro_num=make_array(pn,nn,/float)

ip_csec_c=make_array(npts,npts,nn,/float)
ip_csec_s=make_array(npts,npts,nn,/float)
ip_csec_numc=make_array(npts,npts,nn,/float)
ip_csec_nums=make_array(npts,npts,nn,/float)

ip_pro_c=make_array(pn,nn,/float);spline function real_part projectin
ip_pro_s=make_array(pn,nn,/float);spline functin imaginary part projection
ip_pro_numc=make_array(pn,8,/float)
ip_pro_nums=make_array(pn,8,/float)

pot_csec_c=make_array(npts,npts,nn,/float)
pot_csec_s=make_array(npts,npts,nn,/float)
pot_csec_numc=make_array(npts,npts,nn,/float)
pot_csec_nums=make_array(npts,npts,nn,/float)
vel_csec_numx=make_array(npts,npts,nn,/float)
vel_csec_numy=make_array(npts,npts,nn,/float)

pot_pro_numc=make_array(pn,8,/float)
pot_pro_nums=make_array(pn,8,/float)
pot_pro_c=make_array(pn,nn,/float)
pot_pro_s=make_array(pn,nn,/float)

vel_pro_c=make_array(pn,nn,/float)
vel_pro_s=make_array(pn,nn,/float)
vel_pro_numc=make_array(pn,8,/float)
vel_pro_nums=make_array(pn,8,/float)

vel_resi_num=make_array(pn,8,/float)
vel_resi=make_array(pn,8,/float)

impara=make_array(pn)
xc=range(-radius,radius,npts=npts)
yc=range(-radius,radius,npts=npts)
;potential response function of different spline fucntions
for k=0,nn-1 do begin
 for p=0,npts-1 do begin
  for q=0,npts-1 do begin
    dis=sqrt(xc(p)^2+yc(q)^2)
    if (dis^2 le radius^2) then begin 
      rd_i=interpol(da0(*,k),rv,dis, /LSQUADRATIC)
      i_csec(p,q,k)=rd_i
      i_csec_num(p,q,k)=exp(-(dis-0.0)^2/0.02^2)
    
    rd_fl=interpol(da0(*,k),rv,dis, /LSQUADRATIC)
    flow_csec_x(p,q,k)=rd_fl*sin(atan(yc(q),xc(p)))
    flow_csec_y(p,q,k)=-rd_fl*cos(atan(yc(q),xc(p)))
    flow_csec_numx(p,q,k)=125*(1-cos(!pi*2.0*dis/0.07))*sin(atan(yc(q),xc(p)));8000.0*dis*sin(atan(yc(q),xc(p)));
    flow_csec_numy(p,q,k)=-125*(1-cos(!pi*2.0*dis/0.07))*cos(atan(yc(q),xc(p)));-8000.0*dis*cos(atan(yc(q),xc(p)));
      
    rd_ip=interpol(da0(*,k),rv,dis, /LSQUADRATIC)
    ip_csec_c(p,q,k)=rd_ip*cos(m*atan(yc(q),xc(p)))
    ip_csec_s(p,q,k)=rd_ip*sin(m*atan(yc(q),xc(p)))
      
    rd_pot=interpol(da0(*,k),rv,dis, /LSQUADRATIC)
    pot_csec_c(p,q,k)=rd_pot*cos(m*atan(yc(q),xc(p)))
    pot_csec_s(p,q,k)=rd_pot*sin(m*atan(yc(q),xc(p)))
    
    pot_csec_numc(p,q,k)=0.4*(1.0-cos(dis/0.05*!pi*2.0))*cos(m*atan(yc(q),xc(p))+!pi/4.0*k+!pi/16.0)
    pot_csec_nums(p,q,k)=0.4*(1.0-cos(dis/0.05*!pi*2.0))*sin(m*atan(yc(q),xc(p))+!pi/4.0*k+!pi/16.0)
   
    ip_csec_numc(p,q,k)=0.02*(1.0-cos(dis/0.05*!pi*2.0))*cos(m*atan(yc(q),xc(p))+!pi/4.0*k+!pi/16.0)
    ip_csec_nums(p,q,k)=0.02*(1.0-cos(dis/0.05*!pi*2.0))*sin(m*atan(yc(q),xc(p))+!pi/4.0*k+!pi/16.0)
    
    endif else begin
      i_csec(p,q,k)=0.0
      i_csec_num(p,q,k)=0.0
      flow_csec_x(p,q,k)=0.0
      flow_csec_y(p,q,k)=0.0
      flow_csec_numx(p,q,k)=0.0
      flow_csec_numy(p,q,k)=0.0
      pot_csec_c(p,q,k)=0.0
      pot_csec_s(p,q,k)=0.0
      pot_csec_numc(p,q,k)=0.0
      pot_csec_nums(p,q,k)=0.0
      endelse
    endfor
    endfor
     vel_csec_num=-gradient(reform(pot_csec_numc(*,*,k)),/vector)*npts/0.1
     vel_csec_numx(*,*,k)=vel_csec_num(*,*,1)
     vel_csec_numy(*,*,k)=-vel_csec_num(*,*,0)
    endfor

restore,'shot364 intensity reconstruction profiles.save'
intcs=tomoresult.ics
;intcs=i_csec_num
intcs=mean(intcs,dimension=3)
intcs_num=mean(i_csec_num,dimension=3)
intpcs=tomoresult.ipcs
intpcs_num=ip_csec_numc(*,*,0:7)
;intpcs=ip_csec_numc
restore,'shot364 intensity and flow reconstruction profile.save'
flcsx=tomoresult1.flcsx
;flcsx=flow_csec_numx
flcsx=mean(flcsx,dimension=3)
flcsx_num=mean(flow_csec_numx,dimension=3)
flcsy=tomoresult1.flcsy
;flcsy=flow_csec_numy
flcsy=mean(flcsy,dimension=3)
flcsy_num=mean(flow_csec_numy,dimension=3)
   
intn=make_array(pn,/float)
 center1=[npts/2.0,1.09*npts/2.0/radius+npts/2.0]   
 n=50000
para=findgen(n)*npts/0.04/(n-1)-npts/0.08
 for u=0,nn-1 do begin
  for v=0,pn-1 do begin
   vec=[(v-pn/2.0)*sz,f]
   vec=vec/sqrt(total(vec^2))
   x=vec(0)*para+center1(0)
   y=vec(1)*para+center1(1)
    dis=sqrt((x-npts/2.0)^2+(y-npts/2.0)^2)
    ind=where(dis le npts/2.0)
   para1=para(ind)
   intn(v)=n_elements(ind)
   x=vec(0)*para1+center1(0)
    y=vec(1)*para1+center1(1)
  inten1=interpolate(intcs,x,y,missing=0.0,CUBIC=-0.5)
  inten1_num=interpolate(intcs_num,x,y,missing=0.0,CUBIC=-0.5)
  flx=interpolate(flcsx,x,y,missing=0.0,CUBIC=-0.5)
  flx_num=interpolate(flcsx_num,x,y,missing=0.0,CUBIC=-0.5)
  fly=interpolate(flcsy,x,y,missing=0.0,CUBIC=-0.5)
   fly_num=interpolate(flcsy_num,x,y,missing=0.0,CUBIC=-0.5)
  fl_l=flx*cos(atan(vec(1),vec(0)))+fly*sin(atan(vec(1),vec(0)))
  fl_l_num=flx_num*cos(atan(vec(1),vec(0)))+fly_num*sin(atan(vec(1),vec(0)))
    if (u eq 0) then begin
     impara(v)=(center1(1)-npts/2.0)*cos(atan(vec(1),vec(0)))/(npts/0.1)
     endif
   if (u lt 8) then begin
    ip_resi=interpolate(reform(intpcs(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
    ip_resi_num=interpolate(reform(intpcs_num(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
   if (total(inten1)ne 0.0)then begin
    vel_resi(v,u)=total(ip_resi*fl_l)/total(inten1)-total(inten1*fl_l)/total(inten1)*total(ip_resi)/total(inten1)
    vel_resi_num(v,u)=total(ip_resi_num*fl_l_num)/total(inten1_num)-total(inten1_num*fl_l_num)/total(inten1_num)*total(ip_resi_num)/total(inten1_num)
        endif else begin
      vel_resi(v,u)=0.0
      vel_resi_num(v,u)=0.0
      endelse
    
    i_num_c=interpolate(reform(i_csec_num(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
    i_pro_num(v,u)=total(i_num_c)
    
    flow_numx=interpolate(reform(flow_csec_numx(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
    flow_numy=interpolate(reform(flow_csec_numy(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
    ;flow_pro_num(v,u)=total(flow_numx*cos(atan(vec(1),vec(0)))+flow_numy*sin(atan(vec(1),vec(0))))
    flow_num_lc=flow_numx*cos(atan(vec(1),vec(0)))+flow_numy*sin(atan(vec(1),vec(0)))
    if (total(inten1_num) eq 0.0)then begin
    flow_pro_num(v,u)=0.0
    endif else begin 
    flow_pro_num(v,u)=total(flow_num_lc*inten1_num)/total(inten1_num*1.0)
    endelse
    
    ip_num_c=interpolate(reform(ip_csec_numc(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
    ip_pro_numc(v,u)=total(ip_num_c)
    ip_num_s=interpolate(reform(ip_csec_nums(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
    ip_pro_nums(v,u)=total(ip_num_s)
    
    pot_num_c=interpolate(reform(pot_csec_numc(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
    pot_pro_numc(v,u)=total(pot_num_c)
    pot_num_s=interpolate(reform(pot_csec_nums(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
    pot_pro_nums(v,u)=total(pot_num_s)
    
    vel_num_c=-gradient(reform(pot_csec_numc(*,*,u)),/vector)*npts/0.1
    vel_num_xc=vel_num_c(*,*,1)
    vel_num_yc=-vel_num_c(*,*,0)
    vel_num_xlc=interpolate(vel_num_xc,x,y,missing=0.0,CUBIC=-0.5)
    vel_num_ylc=interpolate(vel_num_yc,x,y,missing=0.0,CUBIC=-0.5)
    vel_num_lc=vel_num_xlc*cos(atan(vec(1),vec(0)))+vel_num_ylc*sin(atan(vec(1),vec(0)))
    vel_num_lc=vel_num_lc*inten1_num*1.0
    if (total(inten1_num) eq 0.0)then begin
    vel_pro_numc(v,u)=0.0
    endif else begin 
    vel_pro_numc(v,u)=total(vel_num_lc)/total(inten1_num*1.0);+vel_resi_num(v,u)
    endelse
    
    vel_num_s=-gradient(reform(pot_csec_nums(*,*,u)),/vector)*npts/0.1
    vel_num_xs=vel_num_s(*,*,1)
    vel_num_ys=-vel_num_s(*,*,0)
    vel_num_xls=interpolate(vel_num_xs,x,y,missing=0.0,CUBIC=-0.5)
    vel_num_yls=interpolate(vel_num_ys,x,y,missing=0.0,CUBIC=-0.5)
    vel_num_ls=vel_num_xls*cos(atan(vec(1),vec(0)))+vel_num_yls*sin(atan(vec(1),vec(0)))
    vel_num_ls=vel_num_ls*i_num_c*1.0
    if (i_pro_num(v,u) eq 0.0)then begin
    vel_pro_nums(v,u)=0.0
    endif else begin 
    vel_pro_nums(v,u)=total(vel_num_ls)/total(i_num_c*1.0)
    endelse
    
   
  endif
    inten=interpolate(reform(i_csec(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
    i_pro(v,u)=total(inten)
    
    flow_x=interpolate(reform(flow_csec_x(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
   flow_y=interpolate(reform(flow_csec_y(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
   flow_l=flow_x*cos(atan(vec(1),vec(0)))+flow_y*sin(atan(vec(1),vec(0)))
   if (total(inten1*1.0)ne 0.0)then begin
    flow_pro(v,u)=total(flow_l*inten1)/total(inten1)
     endif else begin
      flow_pro(v,u)=0.0
      endelse
    
    
    ip_c=interpolate(reform(ip_csec_c(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
    ip_pro_c(v,u)=total(ip_c)
    ip_s=interpolate(reform(ip_csec_s(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
    ip_pro_s(v,u)=total(ip_s) 
    
    
    pot_c=interpolate(reform(pot_csec_c(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
    pot_pro_c(v,u)=total(pot_c)
    pot_s=interpolate(reform(pot_csec_s(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
    pot_pro_s(v,u)=total(pot_s) 
    
    
    
    vel_c=-gradient(reform(pot_csec_c(*,*,u)),/vector)*npts/0.1
    vel_xc=vel_c(*,*,1)
    vel_yc=-vel_c(*,*,0)
    vel_xlc=interpolate(vel_xc,x,y,missing=0.0,CUBIC=-0.5)
    vel_ylc=interpolate(vel_yc,x,y,missing=0.0,CUBIC=-0.5)
    vel_lc=vel_xlc*cos(atan(vec(1),vec(0)))+vel_ylc*sin(atan(vec(1),vec(0)))
    if (total(inten1*1.0)ne 0.0)then begin
    vel_pro_c(v,u)=total(vel_lc*inten1*1.0)/total(inten1*1.0)
    endif else begin
      vel_pro_c(v,u)=0.0
      endelse

   vel_s=-gradient(reform(pot_csec_s(*,*,u)),/vector)*npts/0.1
   vel_xs=vel_s(*,*,1)
   vel_ys=-vel_s(*,*,0)
   vel_xls=interpolate(vel_xs,x,y,missing=0.0,CUBIC=-0.5)
   vel_yls=interpolate(vel_ys,x,y,missing=0.0,CUBIC=-0.5)
   vel_ls=vel_xls*cos(atan(vec(1),vec(0)))+vel_yls*sin(atan(vec(1),vec(0)))
   if (total(inten1*1.0)ne 0.0)then begin
   vel_pro_s(v,u)=total(vel_ls*inten1*1.0)/total(inten1*1.0)
   endif else begin
      vel_pro_s(v,u)=0.0
      endelse
endfor
endfor

;plot for thesis in forward modeling part
;imgpos=[0.15,0.15,0.80,0.80]
;colorpos=[0.82,0.25,0.85,0.65]
;;intensity
;p=plot(rv*100.0,exp(-rv^2/0.02^2),xtitle='Radius(cm)',ytitle='Intensity(arb)',font_size=16,position=imgpos)
;p.save, 'Radial_profile_intensity_model.png',resolution=100
;p1=plot(findgen(512),i_pro_num(*,0),xtitle='Camera pixel',ytitle='Intensity(arb)',font_size=16,position=imgpos)
;p1.save, 'Intensity_integral_profile.png',resolution=100
;i_csec_mod=mean(i_csec_num,dimension=3)
;g=image(i_csec_mod,findgen(200)*10.0/200-5.0,findgen(200)*10/200.0-5,xtitle='X(cm)',$
;  ytitle='Y(cm)',axis_style=1,rgb_table=4,font_size=16,position=imgpos)
;c=colorbar(target=g,textpos=1,title='Intensity(arb)',position=colorpos,font_size=16,orientation=1)
;g.save, 'Intensity_crossection_profile.png',resolution=100
;g1=image(i_pro_num,xtitle='Camera pixel',ytitle='Frame NO.',aspect_ratio=50,axis_style=1,rgb_table=4,font_size=16,position=imgpos)
;c1=colorbar(target=g1,textpos=1,title='Intensity(arb)',position=colorpos,font_size=16,orientation=1)
;g1.save, 'Intensity_integral_sequence.png',resolution=100
;
;;intensity perturbation
;p2=plot(rv*100.0,0.02*(1.0-cos(rv/0.05*!pi*2.0)),xtitle='Radius(cm)',ytitle='Intensity(arb)',font_size=16,position=imgpos)
;p2.save, 'Radial_profile_intensity_pertur_model.png',resolution=100
;p3=plot(findgen(512),ip_pro_numc(*,0),xtitle='Camera pixel',ytitle='Intensity(arb)',font_size=16,position=imgpos)
;p3.save, 'Intensity_pertur_integral_profile.png',resolution=100
;g2=image(reform(ip_csec_numc(*,*,0)),findgen(200)*10.0/200-5.0,findgen(200)*10/200.0-5,xtitle='X(cm)',$
;  ytitle='Y(cm)',axis_style=1,rgb_table=4,font_size=16,position=imgpos)
;c2=colorbar(target=g2,textpos=1,title='Intensity(arb)',position=colorpos,font_size=16,orientation=1)
;g2.save, 'Intensity_pertur_crossection_profile.png',resolution=100
;g3=image(ip_pro_numc,xtitle='Camera pixel',ytitle='Frame NO.',aspect_ratio=50,axis_style=1,rgb_table=4,font_size=16,position=imgpos)
;c3=colorbar(target=g3,textpos=1,title='Intensity(arb)',position=colorpos,font_size=16,orientation=1)
;g3.save, 'Intensity_pertur_integral_sequence.png',resolution=100
;;flow 
;flow_pot=125.0*(rv-0.07/2.0/!pi*sin(2.0*!pi/0.07*rv))
;p4=plot(rv*100.0,flow_pot,xtitle='Radius(cm)',ytitle='Intensity(arb)',font_size=16,position=imgpos)
;p4.save, 'Radial_profile_flow_potential.png',resolution=100
;p5=plot(findgen(512),flow_pro_num(*,0),xtitle='Camera pixel',ytitle='Intensity(arb)',font_size=16,position=imgpos)
;p5.save, 'Flow_integral_profile.png',resolution=100
;flow_crossx=rebin(reform(flow_csec_numx(*,*,0)),20,20)
;flow_crossy=rebin(reform(flow_csec_numy(*,*,0)),20,20)
;g4=vector(flow_crossx,flow_crossy,findgen(20)*10.0/20-5.0,findgen(20)*10/20.0-5,xtitle='X(cm)',ytitle='Y(cm)',axis_style=1,$
;  auto_color=1,length_scale=2,rgb_table=4,font_size=16,position=imgpos)
;c4=colorbar(target=g4,textpos=1,title='Amplitude(arb)',position=colorpos,font_size=16,orientation=1)
;g4.save, 'Flow_crossection_profile.png',resolution=100
;g5=image(flow_pro_num(*,0:7),xtitle='Camera pixel',ytitle='Frame NO.',aspect_ratio=50,axis_style=1,$
;  rgb_table=4,font_size=16,position=imgpos)
;c5=colorbar(target=g5,textpos=1,title='Intensity(arb)',position=colorpos,font_size=16,orientation=1)
;g5.save, 'Flow_integral_sequence.png',resolution=100
;
;; flow perturbation
;p6=plot(rv*100.0,0.4*(1.0-cos(rv/0.05*!pi*2.0)),xtitle='Radius(cm)',ytitle='Intensity(arb)',font_size=16,position=imgpos)
;p6.save, 'Radial_profile_flow_pertur_model.png',resolution=100
;p7=plot(findgen(512),vel_pro_numc(*,0),xtitle='Camera pixel',ytitle='Intensity(arb)',font_size=16,position=imgpos)
;p7.save, 'Flow_pertur_integral_profile.png',resolution=100
;flow_pertur_crossx=rebin(reform(vel_csec_numx(*,*,0)),20,20)
;flow_pertur_crossy=rebin(reform(vel_csec_numy(*,*,0)),20,20)
;g6=vector(flow_pertur_crossx,flow_pertur_crossy,findgen(20)*10.0/20-5.0,findgen(20)*10/20.0-5,xtitle='X(cm)',ytitle='Y(cm)',axis_style=1,$
;  auto_color=1,length_scale=2,rgb_table=4,font_size=16,position=imgpos)
;c6=colorbar(target=g6,textpos=1,title='Amplitude(arb)',position=colorpos,font_size=16,orientation=1)
;g6.save, 'Flow_pertur_crossection_profile.png',resolution=100
;
;g7=image(vel_pro_numc,xtitle='Camera pixel',ytitle='Frame NO.',aspect_ratio=50,axis_style=1,rgb_table=4,font_size=16,position=imgpos)
;c7=colorbar(target=g7,textpos=1,title='Intensity(arb)',position=colorpos,font_size=16,orientation=1)
;g7.save, 'Flow_pertur_integral_sequence.png',resolution=100


;;intensity and intensity perturbation integration of different spline functions
;center=[0.0,1.12]
;for i=0,nn-1 do begin
  ;for j=0,pn-1 do begin
;vec=[(j-pn/2.0)*sz,f]
;vec=vec/sqrt(total(vec^2))
;lefts=-1.5
;rights=1.5
;nlat=1.0
;para=findgen(5000.0*nlat)*(rights-lefts)/(5000.0*nlat-1.0)+lefts  ;parameters
;deltat=para(1)-para(0)
;x=vec(0)*para+center(0)
;y=vec(1)*para+center(1)
;r=sqrt(x^2+y^2)
;index=where(r^2 le radius^2)
;intn(j,i)=n_elements(index)
;para=para(index)
;x=vec(0)*para+center(0)
;y=vec(1)*para+center(1)
;r=sqrt(x^2+y^2)
;num_rfuc_dc=0.5*exp(-(r-0.015)^2.0/0.01^2)+0.5*exp(-(r-0.0)^2/0.01^2);0.5*exp(-(r)^2.0/0.02^2)+0.5*exp(-(r-0.02)^2/0.02^2)
;num_rfuc=(0.5*exp(-(r-0.015)^2.0/0.01^2)+0.5*exp(-(r-0.0)^2/0.01^2))*dcomplex(cos(m*atan(y,x)+!pi/8.0*i),sin(m*atan(y,x)+!pi/8.0*i))
;num_data(j,i)=total(real_part(num_rfuc)) ;numerical simulation of intensity perturbation
;num_data_dc(j,i)=total(num_rfuc_dc)      ;numerical simulation of DC intensity distribution
;rfuc=interpol(reform(da0(*,i)),rv,r,/LSQUADRATIC)
;rfuc_dc=interpol(reform(da0(*,i)),rv,r)
;intper=rfuc*dcomplex(cos(m*atan(y,x)+theta),sin(m*atan(y,x)+theta))
;proarrc(j,i)=0.5*total(real_part(intper))
;proarrs(j,i)=0.5*total(imaginary(intper))
;proarr_dc(j,i)=total(rfuc_dc)
;;if ((j eq 256) and (i eq 5)) then stop
;endfor
;endfor
;;stop

;construct response martrix
i_rm=make_array(nn,pn,/float)
flow_rm=make_array(nn,pn,/float)
ip_rm=make_array(2.0*nn,2.0*pn,/float)
pot_rm=make_array(2.0*nn,pn,/float)
vel_rm=make_array(2.0*nn,2.0*pn,/float)
for i=0,nn-1 do begin
for j=0,pn-1 do begin
data=reform(i_pro(*,i))
i_rm(i,j)=data(j)
data1=reform(flow_pro(*,i))
flow_rm(i,j)=data1(j)
  
rdata=reform(ip_pro_c(*,i))
idata=reform(ip_pro_s(*,i))
ip_rm(2*i,j*2)=rdata(j)
ip_rm(2*i,j*2+1)=idata(j)
ip_rm(2*i+1,j*2)=-idata(j)
ip_rm(2*i+1,j*2+1)=rdata(j) 

rdata1=reform(vel_pro_c(*,i))
idata1=reform(vel_pro_s(*,i))
vel_rm(2*i,j*2)=rdata1(j)
vel_rm(2*i,j*2+1)=idata1(j)
vel_rm(2*i+1,j*2)=-idata1(j)
vel_rm(2*i+1,j*2+1)=rdata1(j)

rdata2=reform(pot_pro_c(*,i))
idata2=reform(pot_pro_s(*,i))
pot_rm(2*i,j)=rdata2(j)
pot_rm(2.0*i+1,j)=-idata2(j)
endfor
endfor

;peudo inverse
;dc
la_svd,i_rm, w_i,u_i,v_i,status=status,/double
status_i=status
ffd=u_i##diag_matrix(w_i)##transpose(v_i)
index_i=where(w_i lt 1.0) ;delete extrme sigular value
w1_i=1.0/w_i
fi_i=finite(w1_i,/infinity)
index_i1=where(fi_i eq 1)
w1_i(index_i1)=0.0
w2_i=w1_i
w2_i(index_i)=0.0
ivfd_i=v_i##diag_matrix(w2_i)##transpose(u_i)
ivfd_num_i=v_i##diag_matrix(w1_i)##transpose(u_i)

; Dc flow
la_svd,flow_rm, w_flow,u_flow,v_flow,status=status,/double
status_flow=status
ffd=u_flow##diag_matrix(w_flow)##transpose(v_flow)
index_flow=where(w_flow lt 0.2) ;delete extrme sigular value
w1_flow=1.0/w_flow
fi_flow=finite(w1_flow,/infinity)
index_flow1=where(fi_flow eq 1)
w1_flow(index_flow1)=0.0
w2_flow=w1_flow
w2_flow(index_flow)=0.0
ivfd_flow=v_flow##diag_matrix(w2_flow)##transpose(u_flow)
ivfd_num_flow=v_flow##diag_matrix(w1_flow)##transpose(u_flow)

;
;ac
la_svd,ip_rm, w_ip,u_ip,v_ip,status=status,/double
status_ip=status
ffd=u_ip##diag_matrix(w_ip)##transpose(v_ip)
index_ip=where((w_ip lt 1.0) or (w_ip gt 10000.0)) ;delete extrme sigular value
w1_ip=1.0/w_ip
fi_ip=finite(w1_ip,/infinity)
index_ip1=where(fi_ip eq 1)
w1_ip(index_ip1)=0.0
w2_ip=w1_ip
w2_ip(index_ip)=0.0
ivfd_ip=v_ip##diag_matrix(w2_ip)##transpose(u_ip)
ivfd_num_ip=v_ip##diag_matrix(w1_ip)##transpose(u_ip)

;velocity perturbation
la_svd,vel_rm, w_vel,u_vel,v_vel,status=status,/double
status_vel=status
ffd=u_vel##diag_matrix(w_vel)##transpose(v_vel)
index_vel=where(w_vel lt 1.0) ;delete extrme sigular value
w1_vel=1.0/w_vel

fi_vel=finite(w1_vel,/infinity)
index_vel1=where(fi_vel eq 1)
w1_vel(index_vel1)=0.0
w2_vel=w1_vel
w2_vel(index_vel)=0.0
ivfd_vel=v_vel##diag_matrix(w2_vel)##transpose(u_vel)
ivfd_num_vel=v_vel##diag_matrix(w1_vel)##transpose(u_vel)

;potenital
la_svd,pot_rm, w_pot,u_pot,v_pot,status=status,/double
status_pot=status
ffd=u_pot##diag_matrix(w_pot)##transpose(v_pot)
index_pot=where(w_pot lt 0.1) ;delete extrme sigular value
w1_pot=1.0/w_pot
fi_pot=finite(w1_pot,/infinity)
index_pot1=where(fi_i eq 1)
w1_pot(index_pot1)=0.0
w2_pot=w1_pot
w2_pot(index_pot)=0.0
ivfd_pot=v_pot##diag_matrix(w2_pot)##transpose(u_pot)
ivfd_num_pot=v_pot##diag_matrix(w1_pot)##transpose(u_pot)


;input data 
;simulation data matrix
vel_pro_numc=vel_pro_numc-vel_resi_num
i_input_num=mean(i_pro_num(*,0:7),dimension=2)
flow_input_num=mean(flow_pro_num(*,0:7),dimension=2)
ip_input_num=make_array(pn,8,/dcomplex)
vel_input_num=make_array(pn,8,/dcomplex)
pot_input_num=pot_pro_numc

;experiment data matrix
i_input=make_array(pn,/float)
flow_input=make_array(pn,/float)
ip_input=make_array(pn,8,/dcomplex)
vel_input=make_array(pn,8,/dcomplex)

;shot='364'
;restore, 'result'+shot+'.save'
;exp_i=result.i
;exp_vel=result.fp
;exp_ip=result.ip
;exp_flow=result.f
;exp_t=result.t
;exp_tp=result.tp

restore,filename='Scan data for 50A_800A on 27-06-2014.save'
pos_num=3
exp_i=scandata.i
exp_vel=scandata.fp
exp_ip=scandata.ip
exp_flow=scandata.f
exp_t=scandata.t
exp_tp=scandata.tp


;sort out the measured data
;original
;exp_i_mean=mean(exp_i(*,100:400,*),dimension=2)
;exp_ip_mean=mean(exp_ip(*,100:400,*),dimension=2)
;exp_ip_mean=exp_ip_mean/max(exp_ip_mean)
;exp_vel_mean=mean(exp_vel(*,100:400,*),dimension=2)
;exp_flow_mean0=mean(exp_flow(*,100:400,*),dimension=2)
;exp_flow_mean=mean(exp_flow_mean0,dimension=2)
;exp_t_mean=mean(exp_t(*,100:400,*),dimension=2)
;t_input=mean(exp_t_mean,dimension=2)
;exp_tp_mean=mean(exp_tp(*,100:400,*),dimension=2)


exp_i_mean=reform(exp_i(*,*,pos_num))
i_input=mean(exp_i_mean,dimension=2)
exp_ip_mean=reform(exp_ip(*,*,pos_num))
exp_ip_mean=exp_ip_mean/max(exp_ip_mean)
exp_vel_mean=reform(exp_vel(*,*,pos_num))
exp_flow_mean0=reform(exp_flow(*,*,pos_num))
exp_flow_mean=mean(exp_flow_mean0,dimension=2)
exp_t_mean=reform(exp_t(*,*,pos_num))
t_input=mean(exp_t_mean,dimension=2)
exp_tp_mean=reform(exp_tp(*,*,pos_num))






;modified experimenatal data
pn=512
maxdc=max(i_input,index)
shm=index-pn/2.0
i_input=shift(i_input,-shm)
i_input=i_input/max(i_input)
exp_ipm=shift(exp_ip_mean,-shm)
exp_velm=shift(exp_vel_mean,-shm)
exp_flowm=shift(exp_flow_mean,-shm)
flow_input=smooth(exp_flowm+400,5);+400 for shot364;+0 for shot368;-1000 for shot394
;flip around
;intensityp=shift(intensityp,-shm)
;;ip1=intensityp(256:*,*)
;;ip2=-reverse(ip1)
;;intensityp(0:255,*)=ip2
;;intensityp(256:*,*)=ip1
;
;pick up valid pixel area
indpick=where(i_input le 0.10*max(i_input))
indpick1=where(indpick le pn/2.0)
indpick2=where(indpick ge pn/2.0)
beg_ind=indpick(indpick1)
end_ind=indpick(indpick2)
beg_ind=max(beg_ind)
end_ind=min(end_ind)
val_pix=pn-n_elements(indpick1)-n_elements(indpick2)


exp_velm(0:beg_ind,*)=0.1*exp_velm(0:beg_ind,*)
exp_velm(end_ind:*,*)=0.1*exp_velm(end_ind:*,*)
vel_resi(0:beg_ind,*)=0.1*vel_resi(0:beg_ind,*)
vel_resi(end_ind:*,*)=0.1*vel_resi(end_ind:*,*)
exp_velm=exp_velm-vel_resi
;flow_input(0:beg_ind)=0.1*flow_input(0:beg_ind)
;flow_input(end_ind:*)=0.1*flow_input(end_ind:*)
flow_input(0:beg_ind)=smooth(flow_input(0:beg_ind),20)
flow_input(end_ind:*)=smooth(flow_input(end_ind:*),20)

;plotting for the thesis
;exp_flow_mean0=shift(exp_flow_mean0+400,-shm)
;exp_flow_mean0(0:beg_ind,*)=0.0
;exp_flow_mean0(end_ind:*,*)=0.0
;exp_ipm(0:beg_ind,*)=0.0
;exp_ipm(end_ind:*,*)=0.0
;exp_vel_mod=exp_velm+vel_resi
;exp_vel_mod(0:beg_ind,*)=0.0
;exp_vel_mod(end_ind:*,*)=0.0
;imgpos=[0.1,0.1,0.81,0.81]
;colorpos=[0.82,0.16,0.85,0.76]
;g=image(rebin(exp_flow_mean0,2048,2400),findgen(2048)*0.25,findgen(2400)*8.0/2400,xtitle='Camera pixel',ytitle='Frame NO.',position=imgpos,rgb_table=4,axis_style=1,aspect_ratio=50,$
;FONT_SIZE=16)
;c=colorbar(target=g,orientation=1,position=colorpos,textpos=1,title='Flow(m/s)',font_size=16)
;g.save,'DC_flow_shot364.png',resolution=100
;g1=image(rebin(exp_i_mean,2048,2400),findgen(2048)*0.25,findgen(2400)*8.0/2400,xtitle='Camera pixel',ytitle='Frame NO.',position=imgpos,rgb_table=4,axis_style=1,aspect_ratio=50,font_size=16)
;c1=colorbar(target=g1,orientation=1,position=colorpos,textpos=1,title='Intensity(arb)',font_size=16)
; g1.save,'DC_intensity_shot364.png',resolution=100
;g2=image(rebin(exp_ipm,2048,2400)*0.04,findgen(2048)*0.25,findgen(2400)*8.0/2400,xtitle='Camera pixel',ytitle='Frame NO.',position=imgpos,rgb_table=4,axis_style=1,aspect_ratio=50,font_size=16)
;c2=colorbar(target=g2,orientation=1,position=colorpos,textpos=1,title='Intensity perturbation(arb)',font_size=16)
;g2.save,'Intensity_perturbation_shot364.png',resolution=100
;g3=image(rebin(exp_vel_mod,2048,2400),findgen(2048)*0.25,findgen(2400)*8.0/2400,xtitle='Camera pixel',ytitle='Frame NO.',position=imgpos,rgb_table=4,axis_style=1,aspect_ratio=50,max_value=50,min_value=-50,font_size=16)
;c3=colorbar(target=g3,orientation=1,position=colorpos,textpos=1,title='Flow perturbation(m/s)',font_size=16)
;g3.save,'Flow_perturbation_shot364.png',resolution=100
;g4=image(rebin(exp_t_mean,2048,2400),findgen(2048)*0.25,findgen(2400)*8.0/2400,xtitle='Camera pixel',ytitle='Frame NO.',position=imgpos,rgb_table=4,axis_style=1,aspect_ratio=50,font_size=16)
;c4=colorbar(target=g4,orientation=1,position=colorpos,textpos=1,title='Temperature(eV)',font_size=16)
;g4.save,'DC_temperature_shot364.png',resolution=100
;g5=image(rebin(exp_tp_mean,2048,2400),findgen(2048)*0.25,findgen(2400)*8.0/2400,xtitle='Camera pixel',ytitle='Frame NO.',position=imgpos,rgb_table=4,axis_style=1,aspect_ratio=50,font_size=16)
;c5=colorbar(target=g5,orientation=1,position=colorpos,textpos=1,title='Temperature perturbation(eV)',font_size=16)
;g5.save,'Temperature_perturbation_shot364.png',resolution=100
;stop
ip_pro_numc=ip_pro_numc/max(ip_pro_numc)
for i=0,pn-1 do begin
  ip_num_fft=fft(ip_pro_numc(i,*))
  ip_num_fft(0)=dcomplex(0.0,0.0)
  ip_num_fft(2:*)=dcomplex(0.0,0.0)
  ip_input_num(i,*)=fft(ip_num_fft,/inverse)
  
  ip_fft=fft(exp_ipm(i,*))
  ip_fft(0)=dcomplex(0.0,0.0)
  ip_fft(2:*)=dcomplex(0.0,0.0)
  ip_input(i,*)=fft(ip_fft,/inverse)
  
  vel_num_fft=fft(vel_pro_numc(i,*))
  vel_num_fft(0)=dcomplex(0.0,0.0)
  vel_num_fft(2:*)=dcomplex(0.0,0.0)
  vel_input_num(i,*)=fft(vel_num_fft,/inverse)
  
  vel_fft=fft(exp_velm(i,*))
  vel_fft(0)=dcomplex(0.0,0.0)
  vel_fft(2:*)=dcomplex(0.0,0.0)
  vel_input(i,*)=fft(vel_fft,/inverse)
  endfor

;reconstruction,response vector
i_vec=i_input
ip_vec=make_array(512*2,/float) 
vel_vec=make_array(512*2,/float) 
ip_vec_num=make_array(512*2,/float) 
vel_vec_num=make_array(512*2,/float) 
pot_vec_num=make_array(512,/float) 

ip_weights=make_array(nn,8)
ip_phase=make_array(nn,8)
ip_weights_num=make_array(nn,8)
ip_phase_num=make_array(nn,8)
ip_recon=make_array(npts,8,/float)
ip_recon_arr=make_array(npts,nn,/float)
ip_recon_num=make_array(npts,8,/float)
ip_recon_arr_num=make_array(npts,nn,/float)


vel_weights=make_array(nn,8)
vel_phase=make_array(nn,8)
vel_weights_num=make_array(nn,8)
vel_phase_num=make_array(nn,8)
vel_recon=make_array(npts,8,/float)
vel_recon_arr=make_array(npts,nn,/float)
vel_recon_num=make_array(npts,8,/float)
vel_recon_arr_num=make_array(npts,nn,/float)

pot_weights=make_array(nn,8)
pot_phase=make_array(nn,8)
pot_weights_num=make_array(nn,8)
pot_phase_num=make_array(nn,8)
pot_recon=make_array(npts,8,/float)
pot_recon_arr=make_array(npts,nn,/float)
pot_recon_num=make_array(npts,8,/float)
pot_recon_arr_num=make_array(npts,nn,/float)

i_weights=make_array(nn)
i_weights_num=make_array(nn)
i_recon_num=make_array(npts,8,/float)
i_recon_arr_num=make_array(npts,nn,/float)
i_recon=make_array(npts,8,/float)
i_recon_arr=make_array(npts,nn,/float)

flow_weights=make_array(nn)
flow_weights_num=make_array(nn)
flow_recon_num=make_array(npts,8,/float)
flow_recon_arr_num=make_array(npts,nn,/float)
flow_recon=make_array(npts,8,/float)
flow_recon_arr=make_array(npts,nn,/float)


cb_flow_num=reform(ivfd_num_flow##flow_input_num)
cb_flow=reform(ivfd_flow##flow_input)
flow_weights=cb_flow
flow_weights_num=cb_flow_num

cb_i_num=reform(ivfd_i##i_input_num)
cb_i=reform(ivfd_i##i_input)
i_weights=cb_i
i_weights_num=cb_i_num


for j=0,7 do begin
vel_vec_num(2*findgen(512))=2.0*real_part(vel_input_num(*,j))
vel_vec_num(2*findgen(512)+1)=2.0*imaginary(vel_input_num(*,j)) 
vel_vec(2*findgen(512))=2.0*real_part(vel_input(*,j))
vel_vec(2*findgen(512)+1)=2.0*imaginary(vel_input(*,j))

ip_vec_num(2*findgen(512))=2.0*real_part(ip_input_num(*,j))
ip_vec_num(2*findgen(512)+1)=2.0*imaginary(ip_input_num(*,j)) 
ip_vec(2*findgen(512))=2.0*real_part(ip_input(*,j))
ip_vec(2*findgen(512)+1)=2.0*imaginary(ip_input(*,j))

pot_vec_num=pot_pro_numc(*,j)

cb_vel=reform(ivfd_vel##vel_vec)
;cb_pot=reform(ivfd_pot##pot_vec)
cb_ip=reform(ivfd_ip##ip_vec)

cb_vel_num=reform(ivfd_num_vel##vel_vec_num)
cb_pot_num=reform(ivfd_num_pot##pot_vec_num)
cb_ip_num=reform(ivfd_num_ip##ip_vec_num)

for i=0,nn-1 do begin
  ip_phase(i,j)=atan(cb_ip(2*i+1),cb_ip(2*i))
  ip_weights(i,j)=sqrt((cb_ip(2*i+1))^2+(cb_ip(2*i))^2)
  ip_phase_num(i,j)=atan(cb_ip_num(2*i+1),cb_ip_num(2*i))
  ip_weights_num(i,j)=sqrt((cb_ip_num(2*i+1))^2+(cb_ip_num(2*i))^2)
  
  vel_phase(i,j)=atan(cb_vel(2*i+1),cb_vel(2*i))
  vel_weights(i,j)=sqrt((cb_vel(2*i+1))^2+(cb_vel(2*i))^2)
  vel_phase_num(i,j)=atan(cb_vel_num(2*i+1),cb_vel_num(2*i))
  vel_weights_num(i,j)=sqrt((cb_vel_num(2*i+1))^2+(cb_vel_num(2*i))^2)
  
  ;pot_phase(i,j)=atan(cb_vel(2*i+1),cb_vel(2*i))
  ;pot_weights(i,j)=sqrt((cb_vel(2*i+1))^2+(cb_vel(2*i))^2)
  pot_phase_num(i,j)=atan(cb_pot_num(2*i+1),cb_pot_num(2*i))
  pot_weights_num(i,j)=sqrt((cb_pot_num(2*i+1))^2+(cb_pot_num(2*i))^2)
 endfor 
endfor


;for j=0,7 do begin
  ;for i=0,nn-1 do begin
   ;ip_recon_arr_num(*,i)=ip_weights_num(i,j)*da1(*,i)
   ;ip_recon_arr(*,i)=ip_weights(i,j)*da1(*,i)
   
   ;vel_recon_arr_num(*,i)=vel_weights_num(i,j)*da0(*,i)
   ;vel_recon_arr(*,i)=vel_weights(i,j)*da1(*,i)
   
   ;pot_recon_arr_num(*,i)=pot_weights_num(i,j)*da0(*,i)
   ;pot_recon_arr(*,i)=pot_weights(i,j)*da0(*,i)
   
   ;if (j eq 0) then begin
    ;i_recon_arr_num(*,i)=i_weights_num(i)*da0(*,i)
    ;i_recon_arr(*,i)=i_weights(i)*da0(*,i)
    ;flow_recon_arr_num(*,i)=flow_weights_num(i)*da0(*,i)
    ;flow_recon_arr(*,i)=flow_weights(i)*da0(*,i)
    ;endif   
  ;endfor
    ; i_recon(*,j)=total(i_recon_arr,2)
    ;i_recon_num(*,j)=total(i_recon_arr_num,2)
    ;flow_recon(*,j)=total(flow_recon_arr,2)
    ;flow_recon_num(*,j)=total(flow_recon_arr_num,2)
  
    ;ip_recon(*,j)=total(ip_recon_arr,2)
   ; ip_recon_num(*,j)=total(ip_recon_arr_num,2)
    
    ;vel_recon(*,j)=total(vel_recon_arr,2)
    ;vel_recon_num(*,j)=total(vel_recon_arr_num,2)
    
    ;pot_recon(*,j)=total(pot_recon_arr,2)
    ;pot_recon_num(*,j)=total(pot_recon_arr_num,2)
 ;endfor


;oplot, rden/max(rden),color=4

;check algorithm
;0.5*exp(-(rv-0.015)^2.0/0.01^2)+0.6*exp(-(rv-0.0)^2/0.01^2),test1
;0.0*exp(-(rv-0.015)^2.0/0.01^2)+1.0*exp(-(rv-0.0)^2/0.01^2),test2
;1.0*exp(-(rv-0.015)^2.0/0.01^2)+0.0*exp(-(rv-0.0)^2/0.01^2),test3
;1.0*exp(-(rv-0.015)^2.0/0.01^2)+0.0*exp(-(rv-0.0)^2/0.01^2),test4
;dis=0.5*exp(-(rv-0.015)^2.0/0.01^2)+0.5*exp(-(rv-0.0)^2/0.01^2)
;dis=dis/max(dis)
;p1=plot(rv,dis,xtitle='Radius(m)',ytitle='Normalized intensity(arb)',name='Input DC radial profile',yrange=[0,1])
;p2=plot(rv,smooth(rden_dc,4)/max(smooth(rden_dc,4)),xtitle='Radius(m)',ytitle='Normalized intensity(arb)',name='Reconstructed profile',color='red',/current,yrange=[0,1])
;l=legend(target=[p1,p2],/AUTO_TEXT_COLOR,position=[0.85,0.85,0.88,0.88])
;p3=plot(rv,dis,xtitle='Radius(m)',ytitle='Normalized intensity(arb)',name='Input AC radial profile',yrange=[0,1])
;p4=plot(rv,smooth(rden,4)/max(smooth(rden,4)),xtitle='Radius(m)',ytitle='Normalized intensity(arb)',name='Reconstructed profile',color='red',/current,yrange=[0,1])
;l1=legend(target=[p3,p4],/AUTO_TEXT_COLOR,position=[0.90,0.85,0.93,0.88])



;reconstruction based on tomography profiles and compare with measured data
jumpimg, vel_phase
ip_phase1=smooth(ip_phase,[5,1])
vel_phase1=smooth(vel_phase,[2,1])
ip_phase1_num=smooth(ip_phase_num,[5,1])
vel_phase1_num=smooth(vel_phase_num,[2,1])
for i=0,7 do begin
  ipp=reform(ip_phase1(5:20,i))
  ip_phase1(0:20,i)=interpol(ipp,findgen(16),findgen(21))
  
  ipp_num=reform(ip_phase1_num(0:nn-5,i))
  ip_phase1_num(*,i)=interpol(ipp_num,findgen(nn-4),findgen(nn))
  
  velp=reform(vel_phase1(0:nn-5,i))
  vel_phase1(*,i)=interpol(velp,findgen(nn-4),findgen(nn))
  
  velp_num=reform(vel_phase1_num(0:nn-5,i))
  vel_phase1_num(*,i)=interpol(velp_num,findgen(nn-4),findgen(nn))
endfor
  
knots1=knots(0:nn-1)
knots2=knots(1:nn)
knots_co=(knots1+knots2)/2.0
;valradius=val_pix/2.0/(pn/2.0)*radius
;valind=where(knots_co le valradius)
;valknots=knots_co(valind)

ip_recon=smooth(mean(ip_weights,dimension=2),2)
ip_recon1=interpol(ip_recon(0:nn-3),knots_co(0:nn-3),knots_co)
;ip_recon1=smooth(mean(ip_recon,dimension=2),1)
;ip_recon1=rebin(ip_recon1,1200);for first order spline function
;binn=5.0*nn
;ip_recon1=smooth(rebin(ip_weights,binn),5)
;rvbin=range(0.0,radius,npts=binn)
;iprnp=ip_recon1(0.05*binn:0.95*binn)
;rvip=rvbin(0.05*binn:0.95*binn)
;ip_recon1=interpol(iprnp,rvip,rvbin)
;;knots_co=findgen(nn)*radius/(nn-1)
;ip_weights1=mean(ip_weights,dimension=2)
;;ip_recon1=gaussfit(knots_co,ip_weights1,coff,nterms=6)
;valw_ip=ip_weights1(valind)
;ip_reconv=gaussfit(valknots,valw_ip,coff,nterms=6)
;ip_recon1=make_array(nn,value=0.0,/float)
;ip_recon1(valind)=ip_reconv


;vel_recon1=smooth(mean(vel_recon,dimension=2),1);for first ordr spline fuction
;vel_recon1=rebin(vel_recon1,1200.0)
;
;vrnp=vel_recon1(0.05*binn:0.95*binn)
;vvp=rvbin(0.05*binn:0.95*binn)
;vel_recon1_num=interpol(vrnp,vvp,rvbin)
;vel_weights1=mean(vel_weights,dimension=2)
;vel_recon1=gaussfit(knots_co,vel_weights1,coff,nterms=6)
;valw_vel=vel_weights1(valind)
;vel_reconv=gaussfit(valknots,valw_vel,coff,nterms=6)
;vel_recon1=make_array(nn,value=0.0,/float)
;vel_recon1(valind)=vel_reconv
;
vel_recon=mean(vel_weights,dimension=2)
vel_recon1=interpol(vel_recon(0:nn-3),knots_co(0:nn-3),knots_co)


;i_recon1=smooth(mean(i_recon,dimension=2),5)
;i_recon1=smooth(rebin(i_weights,binn),5)
;binn=nn*5.0
;irnp=i_recon1(0.05*binn:0.95*binn)
;rvi=rvbin(0.05*binn:0.95*binn)
;i_recon1=interpol(irnp,rvi,rvbin)
;i_recon1=gaussfit(knots_co,i_weights,coff,nterms=6)
;valw_i=i_weights(valind)
;i_reconv=gaussfit(valknots,valw_i,coff,nterms=6)
;i_recon1=make_array(nn,value=0.0,/float)
;i_recon1(valind)=i_reconv
i_recon=i_weights
i_recon1=interpol(i_recon(0:nn-3),knots_co(0:nn-3),knots_co)

;flow_recon1=smooth(mean(flow_recon,dimension=2),5)
;flow_recon1=smooth(rebin(flow_weights,binn),5)
;flowrnp=flow_recon1(0.05*binn:0.9*binn)
;rvflow=rvbin(0.05*binn:0.90*binn)
;flow_recon1=interpol(flowrnp,rvflow,rvbin)
;flow_recon1=gaussfit(knots_co,flow_weights,coff,nterms=6)
;valw_flow=flow_weights(valind)
;flow_reconv=gaussfit(valknots,valw_flow,coff,nterms=6)
;flow_recon1=make_array(nn,value=0.0,/float)
;flow_recon1(valind)=flow_reconv
flow_recon=smooth(flow_weights,2)
flow_recon1=interpol(flow_recon(0:nn-3),knots_co(0:nn-3),knots_co)

;ip_recon1_num=smooth(mean(ip_recon_num,dimension=2),5)
;iprnp_num=ip_recon1_num(0.03*npts:0.97*npts)
;rvip_num=rv(0.03*npts:0.97*npts)
;ip_recon1_num=interpol(iprnp_num,rvip_num,rv)
;ip_weights1_num=mean(ip_weights_num,dimension=2)
;ip_recon1_num=gaussfit(knots_co,ip_weights1_num,coff,nterms=6)
ip_recon_num=smooth(mean(ip_weights_num,dimension=2),2)
ip_recon1_num=interpol(ip_recon_num(0:nn-3),knots_co(0:nn-3),knots_co)

;vel_recon1_num=smooth(mean(vel_recon_num,dimension=2),5)
;vrnp_num=vel_recon1_num(0.03*npts:0.97*npts)
;vvp_num=rv(0.03*npts:0.97*npts)
;vel_recon1_num=interpol(vrnp_num,vvp_num,rv)
;vel_weights1_num=mean(vel_weights_num,dimension=2)
;vel_recon1_num=gaussfit(knots_co,vel_weights1_num,coff,nterms=6)
vel_recon_num=mean(vel_weights_num,dimension=2)
vel_recon1_num=interpol(vel_recon_num(0:nn-3),knots_co(0:nn-3),knots_co)

;i_recon1_num=smooth(mean(i_recon_num,dimension=2),5)
;irnp_num=i_recon1_num(0.03*npts:0.97*npts)
;rvp_num=rv(0.03*npts:0.97*npts)
;i_recon1_num=interpol(irnp_num,rvp_num,rv)
;i_recon1_num=gaussfit(knots_co,i_weights_num,coff,nterms=6)
i_recon_num=i_weights_num
i_recon1_num=interpol(i_recon_num(0:nn-3),knots_co(0:nn-3),knots_co)

;flow_recon1_num=smooth(mean(flow_recon_num,dimension=2),5)
;flowrnp_num=flow_recon1_num(0.03*npts:0.9*npts)
;rvp_num=rv(0.03*npts:0.9*npts)
;flow_recon1_num=interpol(flowrnp_num,rvp_num,rv)
;flow_recon1_num=gaussfit(knots_co,flow_weights_num,coff,nterms=6)
flow_recon_num=flow_weights_num
flow_recon1_num=interpol(flow_recon_num(0:nn-3),knots_co(0:nn-3),knots_co)


pha_co1=knots(1:nn)
pha_co2=knots(0:nn-1)
pha_co=(pha_co1+pha_co2)/2.0

ip_recon_csec=make_array(npts,npts,8,/float)
vel_recon_csec=make_array(npts,npts,8,/float)
i_recon_csec=make_array(npts,npts,8,/float)
flow_recon_csec_x=make_array(npts,npts,8,/float)
flow_recon_csec_y=make_array(npts,npts,8,/float)
vel_con_x=make_array(npts,npts,8,/float)
vel_con_y=make_array(npts,npts,8,/float)
vel_con_numx=make_array(npts,npts,8,/float)
vel_con_numy=make_array(npts,npts,8,/float)

i_recon_csec_num=make_array(npts,npts,8,/float)
flow_recon_csec_numx=make_array(npts,npts,8,/float)
flow_recon_csec_numy=make_array(npts,npts,8,/float)
ip_recon_csec_num=make_array(npts,npts,8,/float)
vel_recon_csec_num=make_array(npts,npts,8,/float)

;rebin for interpolation
i_recon1=rebin(i_recon1,5.0*nn)
ip_recon1=rebin(ip_recon1,5.0*nn)
flow_recon1=rebin(flow_recon1,5.0*nn)
vel_recon1=rebin(vel_recon1,5.0*nn)
i_recon1_num=rebin(i_recon1_num,5.0*nn)
ip_recon1_num=rebin(ip_recon1_num,5.0*nn)
flow_recon1_num=rebin(flow_recon1_num,5.0*nn)
vel_recon1_num=rebin(vel_recon1_num,5.0*nn)
knots_co=rebin(knots_co,5.0*nn)

for i=0,7 do begin
  for p=0,npts-1 do begin
    for q=0,npts-1 do begin
    rc=sqrt(xc(p)^2+yc(q)^2)
    if (rc^2 le radius^2 ) then begin
    ramp_i=interpol(i_recon1,knots_co,rc,/LSQUADRATIC)
    ramp_flow=interpol(flow_recon1,knots_co,rc,/LSQUADRATIC)
    ramp_ip=interpol(ip_recon1,knots_co,rc,/LSQUADRATIC)
    ramp_vel=interpol(vel_recon1,knots_co,rc,/LSQUADRATIC)
    pha_ip=interpol(reform(ip_phase1(*,i)),pha_co,rc,/LSQUADRATIC)
    pha_vel=interpol(reform(vel_phase1(*,i)),pha_co,rc,/LSQUADRATIC)
    i_recon_csec(p,q,i)=ramp_i
    flow_recon_csec_x(p,q,i)=ramp_flow*sin(atan(yc(q),xc(p)))
    flow_recon_csec_y(p,q,i)=-ramp_flow*cos(atan(yc(q),xc(p)))
    ip_recon_csec(p,q,i)=ramp_ip*cos(atan(yc(q),xc(p))+pha_ip)
    vel_recon_csec(p,q,i)=ramp_vel*cos(atan(yc(q),xc(p))+pha_vel)
    
    
    ramp_i_num=interpol(i_recon1_num,knots_co,rc,/LSQUADRATIC)
    ramp_flow_num=interpol(flow_recon1_num,knots_co,rc,/LSQUADRATIC)
    ramp_ip_num=interpol(ip_recon1_num,knots_co,rc,/LSQUADRATIC)
    ramp_vel_num=interpol(vel_recon1_num,knots_co,rc,/LSQUADRATIC)
    pha_ip_num=interpol(reform(ip_phase1_num(*,i)),pha_co,rc,/LSQUADRATIC)
    pha_vel_num=interpol(reform(vel_phase1_num(*,i)),pha_co,rc,/LSQUADRATIC)
    i_recon_csec_num(p,q,i)=ramp_i_num
    flow_recon_csec_numx(p,q,i)=ramp_flow_num*sin(atan(yc(q),xc(p)))
    flow_recon_csec_numy(p,q,i)=-ramp_flow_num*cos(atan(yc(q),xc(p)))
    ip_recon_csec_num(p,q,i)=ramp_ip_num*cos(atan(yc(q),xc(p))+pha_ip_num)
    vel_recon_csec_num(p,q,i)=ramp_vel_num*cos(atan(yc(q),xc(p))+pha_vel_num)
    endif else begin
    i_recon_csec(p,q,i)=0.0
    flow_recon_csec_numx(p,q,i)=0.0
    flow_recon_csec_numy(p,q,i)=0.0
    flow_recon_csec_x(p,q,i)=0.0
    flow_recon_csec_y(p,q,i)=0.0
    ip_recon_csec(p,q,i)=0.0
    vel_recon_csec(p,q,i)=0.0
    i_recon_csec_num(p,q,i)=0.0
    ip_recon_csec_num(p,q,i)=0.0
    vel_recon_csec_num(p,q,i)=0.0
      endelse
    ;if ((p eq 95) and (q eq 5))then stop
    endfor
    endfor
    endfor

 ip_recon_pro=make_array(pn,8,value=0.0,/float)
 vel_recon_pro=make_array(pn,8,value=0.0,/float)
 i_recon_pro=make_array(pn,8,/float)
 flow_recon_pro=make_array(pn,8,/float)
 
 ip_recon_pro_num=make_array(pn,8,value=0.0,/float)
 vel_recon_pro_num=make_array(pn,8,value=0.0,/float)
 i_recon_pro_num=make_array(pn,8,/float)
 flow_recon_pro_num=make_array(pn,8,/float)
 
intn1=make_array(pn,/float)
for u=0,7 do begin
for v=0,pn-1 do begin
   vec=[(v-pn/2.0)*sz,f]
    vec=vec/sqrt(total(vec^2))
    x=vec(0)*para+center1(0)
   y=vec(1)*para+center1(1)
    dis=sqrt((x-npts/2.0)^2+(y-npts/2.0)^2)
    ind=where(dis le npts/2.0)
   para1=para(ind)
   intn1(v)=n_elements(para1)
   x=vec(0)*para1+center1(0)
   y=vec(1)*para1+center1(1)
 inten1=interpolate(intcs,x,y,missing=0.0,CUBIC=-0.5) 
  i_con_num=interpolate(reform(i_recon_csec_num(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
  i_recon_pro_num(v,u)=total(i_con_num)
  i_con=interpolate(reform(i_recon_csec(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
  i_recon_pro(v,u)=total(i_con)
  
  flow_con_numx=interpolate(reform(flow_recon_csec_numx(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
  flow_con_numy=interpolate(reform(flow_recon_csec_numy(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
  flow_con_numl=flow_con_numx*cos(atan(vec(1),vec(0)))+flow_con_numy*sin(atan(vec(1),vec(0)))
  ;flow_recon_pro_num(v,u)=total(flow_con_numl)
   if (total(inten1) ne 0.0) then begin
  flow_recon_pro_num(v,u)=total(flow_con_numl*inten1*1.0)/total(inten1*1.0)
  endif else begin
    flow_recon_pro_num(v,u)=0.0
  endelse
  
  flow_con_x=interpolate(reform(flow_recon_csec_x(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
  flow_con_y=interpolate(reform(flow_recon_csec_y(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
  flow_con_l=flow_con_x*cos(atan(vec(1),vec(0)))+flow_con_y*sin(atan(vec(1),vec(0)))
  ;flow_recon_pro(v,u)=total(flow_con_l)
 if (total(inten1) ne 0.0) then begin
  flow_recon_pro(v,u)=total(flow_con_l*inten1*1.0)/total(inten1*1.0)
  endif else begin
    flow_recon_pro(v,u)=0.0
  endelse
 
 
  ip_con_num=interpolate(reform(ip_recon_csec_num(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
  ip_recon_pro_num(v,u)=total(ip_con_num)
  ip_con=interpolate(reform(ip_recon_csec(*,*,u)),x,y,missing=0.0,CUBIC=-0.5)
  ip_recon_pro(v,u)=total(ip_con)
   
 
  vel_con_num=-gradient(reform(vel_recon_csec_num(*,*,u)),/vector)*npts/0.1
  vel_con_numx(*,*,u)=vel_con_num(*,*,1)
  vel_con_numy(*,*,u)=-vel_con_num(*,*,0)
  vel_con_numxl=interpolate(vel_con_numx(*,*,u),x,y,missing=0.0,CUBIC=-0.5)
  vel_con_numyl=interpolate(vel_con_numy(*,*,u),x,y,missing=0.0,CUBIC=-0.5)
  vel_con_numl=vel_con_numxl*cos(atan(vec(1),vec(0)))+vel_con_numyl*sin(atan(vec(1),vec(0)))
  if (total(inten1) ne 0.0) then begin
  vel_recon_pro_num(v,u)=total(vel_con_numl*inten1*1.0)/total(inten1*1.0)
  endif else begin
    vel_recon_pro_num(v,u)=0.0
  endelse
  
  vel_con=-gradient(reform(vel_recon_csec(*,*,u)),/vector)*npts/0.1
  vel_con_x(*,*,u)=vel_con(*,*,1)
  vel_con_y(*,*,u)=-vel_con(*,*,0)
  vel_con_xl=interpolate(vel_con_x(*,*,u),x,y,missing=0.0,CUBIC=-0.5)
  vel_con_yl=interpolate(vel_con_y(*,*,u),x,y,missing=0.0,CUBIC=-0.5)
  vel_con_l=vel_con_xl*cos(atan(vec(1),vec(0)))+vel_con_yl*sin(atan(vec(1),vec(0)))
  ;vel_recon_pro(v,u)=total(vel_con_l)
 if (total(inten1) ne 0.0) then begin
  vel_recon_pro(v,u)=total(vel_con_l*inten1*1.0)/total(inten1*1.0)
  endif else begin
    vel_recon_pro(v,u)=0.0
  endelse
endfor
endfor
;tomoresult={ir:i_recon1,ipr:ip_recon1,ics:i_recon_csec,ipcs:ip_recon_csec}
;tomoresult1={ir:i_recon1,ipr:ip_recon1,ics:i_recon_csec,ipcs:ip_recon_csec,flr:flow_recon1,flcsx:flow_recon_csec_x,flcsy:flow_recon_csec_y}
input_phase_num=make_array(nn,8,/float)
vel_phase1_num(*,4:*)=vel_phase1_num(*,4:*)+!pi*2.0
ip_phase1_num(*,4:*)=ip_phase1_num(*,4:*)+!pi*2.0
for i=0,7 do begin
  input_phase_num(*,i)=!pi/16.0+!pi/4.0*i
  endfor
; radial phase profile
ip_rad_pha=make_array(nn,8,/float)
vel_rad_pha=make_array(nn,8,/float)
for i=0,7 do begin
  ip_rad_pha(*,i)=ip_phase1(*,i)-ip_phase1(0,i)
  vel_rad_pha(*,i)=vel_phase1(*,i)-vel_phase1(0,i)
  endfor
   
 
;!p.multi=[0,3,2] 
;plot, knots_co,exp(-(knots_co)^2/0.02^2),title='Input radial profile',xtitle='Radius(m)',ytitle='Intensity(arb)',yrange=[0,1]
;plot, knots_co,i_recon1_num,title='Reconstructed radial profile',xtitle='Radius(m)',ytitle='Intensity(arb)',yrange=[0,1]
;i_err_numr=exp(-(knots_co)^2/0.02^2)-i_recon1_num
;plot, knots_co,i_err_numr,title='Rconstruction radial amplitude error',xtitle='Radius(m)',ytitle='Intensity(arb)'
;plot, findgen(pn),i_input_num,title='Input projection profile',xtitle='Camera pixel',ytitle='Intensity(arb)'
;plot, findgen(pn),mean(i_recon_pro_num,dimension=2),title='Reconstructed projection profile',xtitle='Camera pixel',ytitle='Intensity(arb)'
;i_err_nump=i_input_num-mean(i_recon_pro_num,dimension=2)
;plot, findgen(pn),i_err_nump,title='Rconstruction projection amplitude error',xtitle='Camera pixel',ytitle='Intensity(arb)'

;!p.multi=[0,3,2] 
;plot, knots_co,125*(1-cos(!pi*2.0*knots_co/0.07)),title='Input radial profile',xtitle='Radius(m)',ytitle='Velocty(m/s)',yrange=[0,250]
;plot, knots_co,flow_recon1_num,title='Reconstructed radial profile',xtitle='Radius(m)',ytitle='Velocty(m/s)',yrange=[0,250]
;flow_err_numr=125*(1-cos(!pi*2.0*knots_co/0.07))-flow_recon1_num
;plot, knots_co,flow_err_numr,title='Rconstruction radial amplitude error',xtitle='Radius(m)',ytitle='Velocity(m/s)'
;plot, findgen(pn),flow_input_num,title='Input projection profile',xtitle='Camera pixel',ytitle='Velocity(m/s)'
;plot, findgen(pn),mean(flow_recon_pro_num,dimension=2),title='Reconstructed projection profile',xtitle='Camera pixel',ytitle='Velocity(m/s)'
;flow_err_nump=flow_input_num-mean(flow_recon_pro_num,dimension=2)
;plot, findgen(pn),flow_err_nump,title='Rconstruction projection amplitude error',xtitle='Camera pixel',ytitle='Velocity(m/s)'

 
; window,0,title='simulation data' ;density perturbation
;!p.multi=[0,4,2]
;!p.charsize=2
;plot, rv, 0.02*(1.0-cos(rv/0.05*!pi*2.0)),title='Input profile',xtitle='Raius(m)',ytitle='Intensity(arb)',xrange=[0.,radius],yrange=[0,0.04]
;plot, knots_co,ip_recon1_num,title='Reconstructed radial profile',xtitle='Radius(m)',ytitle='Intensity(arb)',xrange=[0,radius],yrange=[0,0.04]
;plot, rebin(knots_co,nn),input_phase_num(*,0),title='Input phase',xtitle='Radius(m)',ytitle='Phase(radians)',yrange=[0,!pi*2.0]
;for i=1,7 do begin
  ;oplot,rebin(knots_co,nn),input_phase_num(*,i)
  ;endfor
;plot,rebin(knots_co,nn),ip_phase1_num(*,0),title='Reconstructed phase',xtitle='Radius(m)',ytitle='Phase(radians)',yrange=[0,!pi*2.0]
;for i=1,7 do begin
  ;oplot,rebin(knots_co,nn),ip_phase1_num(*,i)
  ;endfor
;imgplot, 2.0*real_part(ip_input_num),title='Input projection profile(arb)', xtitle='Camera pixel',ytitle='Frame NO.',/cb,zr=[-30.,30.]
;imgplot, ip_recon_pro_num,title='Reconstructed projection profile', xtitle='Camera pixel',ytitle='Frame NO.',/cb,zr=[-30.,30.]
;ip_amp_err_num=2.0*real_part(ip_input_num)-ip_recon_pro_num
;imgplot, ip_amp_err_num,title='Amplitude error(arb)',xtitle='Camera pixel',ytitle='Frame NO.',/cb,zr=[-30.,30.]
;ip_pha_err_num=input_phase_num-ip_phase1_num
;plot, rebin(knots_co,nn),ip_pha_err_num(*,0),title='Phase error',xtitle='Radius',ytitle='Phase error(radians)'
;for i=1,7 do begin
  ;oplot,rebin(knots_co,nn),ip_pha_err_num(*,i)
  ;endfor   
;stop  
;window,0,title='simulation data' ;potential
;!p.multi=[0,4,2]
;!p.charsize=2
;plot, rv, 0.4*(1.0-cos(rv/0.05*!pi*2.0)),title='Input potential profile',xtitle='Raius(m)',ytitle='Intensity(arb)',xrange=[0.,radius],yrange=[0,0.8]
;plot, knots_co,vel_recon1_num,title='Reconstructed potential profile',xtitle='Radius(m)',ytitle='Intensity(arb)',xrange=[0,radius],yrange=[0,0.8]
;plot, rebin(knots_co,nn),input_phase_num(*,0),title='Input phase',xtitle='Radius(m)',ytitle='Phase(radians)',yrange=[0,!pi*2.0]
;for i=1,7 do begin
  ;oplot,rebin(knots_co,nn),input_phase_num(*,i)
  ;endfor
;plot,rebin(knots_co,nn),vel_phase1_num(*,0),title='Reconstructed phase',xtitle='Radius(m)',ytitle='Phase(radians)',yrange=[0,!pi*2.0]
;for i=1,7 do begin
  ;oplot,rebin(knots_co,nn),vel_phase1_num(*,i)
  ;endfor
;imgplot, 2.0*real_part(vel_input_num),title='Input projection profile(arb)', xtitle='Camera pixel',ytitle='Frame NO.',/cb,zr=[-40.,40.]
;imgplot, vel_recon_pro_num,title='Reconstructed projection profile', xtitle='Camera pixel',ytitle='Frame NO.',/cb,zr=[-40.,40.]
;vel_amp_err_num=2.0*real_part(vel_input_num)-vel_recon_pro_num
;imgplot, vel_amp_err_num,title='Amplitude error(arb)',xtitle='Camera pixel',ytitle='Frame NO.',/cb,zr=[-40.,40.]
;vel_pha_err_num=input_phase_num-vel_phase1_num
;plot, rebin(knots_co,nn),vel_pha_err_num(*,0),title='Phase error',xtitle='Radius',ytitle='Phase error(radians)'
;for i=1,7 do begin
  ;oplot,rebin(knots_co,nn),vel_pha_err_num(*,i)
  ;endfor
;stop 


;experimental data reconstruction-------------------------------------------------
;!p.multi=[0,2,2]
;!p.charsize=1
;plot, findgen(pn),i_input, title='shot364 input density profile',xtitle='Camera pixel',ytitle='Normalized density(arb)',yrange=[0,1]
;plot, knots_co,i_recon1,title='Reconstructed radial density profile',xtitle='Radius(m)',ytitle='density(arb)'
;plot, findgen(pn),mean(i_recon_pro,dimension=2), title='shot364 reconstructed density profile',xtitle='Camera pixel',ytitle='Density(arb)',yrange=[0,1]
;i_err=mean(i_recon_pro,dimension=2)-i_input
;plot, findgen(pn),i_err,title='shot364 density reconstruction error',xtitle='Camera pixel',ytitle='Reconstruction error'

; format for poster pictures
;
radius=findgen(pn)*10.0/(pn-1)-5.0
valid_x=(findgen(end_ind-beg_ind+1)+beg_ind)*10.0/(pn-1)-5.0
i_recon_pro=mean(i_recon_pro,dimension=2)
p=plot(valid_x,i_input(beg_ind:end_ind),xrange=[-5,5],yrange=[0,1],xtitle='Radius(cm)',ytitle='Intensity(arb)',name='Measured profile')
p1=plot(valid_x,i_recon_pro(beg_ind:end_ind),xrange=[-5,5],color='red',overplot=1,name='Reconstructed profile')
l=legend(target=[p,p1],position=[0.92,0.8,0.98,0.85])
p1.save, 'Measured and reconstructed intensity profile.png',resolution=100
valid_por=(end_ind-beg_ind+1.0)/pn
valid_st=round(valid_por*n_elements(knots_co))
p2=plot(knots_co(0:valid_st)*100.0,i_recon1(0:valid_st),xrange=[0,5.0],xtitle='Radius(cm)',ytitle='Intensity(arb)')
p2.save, 'Reconstructed intensity radial profile.png',resolution=100

;!p.multi=[0,2,2]
;!p.charsize=1
;plot, findgen(pn),flow_input, title='shot364 input flow profile',xtitle='Camera pixel',ytitle='DC Flow(m/s)',yrange=[-1000,1000]
;plot, knots_co,flow_recon1,title='Reconstructed radial flow profile',xtitle='Radius(m)',ytitle='DC flow(m/s)'
;plot, findgen(pn),mean(flow_recon_pro,dimension=2), title='shot364 reconstructed DC flow profile',xtitle='Camera pixel',ytitle='DC flow(m/s)',yrange=[-1000,1000]
;flow_err=mean(flow_recon_pro,dimension=2)-flow_input
;plot, findgen(pn),flow_err,title='shot364 flow reconstruction error',xtitle='Camera pixel',ytitle='Reconstruction error(m/s)',yrange=[-1000,1000]

p3=plot(valid_x,flow_input(beg_ind:end_ind),xrange=[-5,5],xtitle='Radius(cm)',ytitle='Flow(m/s)',name='Measured profile')
flow_recon_pro=mean(flow_recon_pro,dimension=2)
p4=plot(valid_x,flow_recon_pro(beg_ind:end_ind),xrange=[-5,5],color='red',overplot=1,name='Reconstructed profile')
l=legend(target=[p3,p4],position=[0.48,0.8,0.58,0.85])
p4.save, 'DC flow reconstructed profile.png',resolution=100
valid_por=(end_ind-beg_ind+1.0)/pn
valid_st=round(valid_por*n_elements(knots_co))
p5=plot(knots_co(0:valid_st)*100.0,flow_recon1(0:valid_st),xrange=[0,5.0],xtitle='Radius(cm)',ytitle='Flow(m/s)')
p5.save, 'Reconstructed DC flow radial profile.png',resolution=100

;!p.multi=[0,3,2]
;!p.charsize=2
;imgplot,2.0*real_part(ip_input),title='shot364 density perturbaiton input(normalized)',xtitle='Camera pixel',ytitle='Frame No.',zr=[-1,1],/cb
;plot, knots_co,ip_recon1,title='shot364 reconstructed radial profile',xtitle='Radius(m)',ytitle='Density perturbation(arb)'
;plot, rebin(knots_co,nn),mean(ip_rad_pha,dimension=2),title='shot364 reconstructed phase radial profile',xtitle='Radius(m)',ytitle='Phase(radians)',yrange=[-!pi,!pi]
;imgplot, ip_recon_pro,title='shot364 reconstructed density perturbation',xtitle='camera pixel',ytitle='Frame No.',zr=[-1,1],/cb
;ip_err=2.0*real_part(ip_input)-ip_recon_pro
;imgplot, ip_err, title='shot364 reconstruction error',xtitle='Camera pixel',ytitle='Density perturbaiton error',zr=[-1,1],/cb
mask_cor_csec=make_array(100,100,value=1.0)
for i=0,99 do begin
  for j=0,99 do begin
    corv=sqrt((i-50.0)^2+(j-50.0)^2)
    if (corv ge 50*valid_por) then mask_cor_csec(i,j)=0.0
    endfor 
    endfor 
;format images for poster 
;; reconstructed crossection profile 
ip_tomo_csec=reform(ip_recon_csec(*,*,0))
mask_cor_csec=rebin(mask_cor_csec,200,200)
ip_tomo_csec=ip_tomo_csec*mask_cor_csec
g=image(rebin(ip_tomo_csec,1000,1000)*100,findgen(1000)*10.0/1999-5.0,findgen(1000)*10.0/1999-5.0, xtitle='Radius(cm)',$
  ytitle='Radius(cm)',axis_style=1,rgb_table=4,font_size=16,position=[0.15,0.15,0.85,0.85])
c=colorbar(target=g,orientation=1,textpos=1,title='Intensity(arb)',font_size=16,position=[0.83,0.25,0.86,0.75])
g.save, 'Reconstructed intensity perturebation crossecton.png',resolution=100
vel_tomo_csec=reform(vel_recon_csec(*,*,0))
g1=image(rebin(vel_tomo_csec,1000,1000),findgen(1000)*10.0/1999-5.0,findgen(1000)*10.0/1999-5.0, xtitle='Radius(cm)',$
  ytitle='Radius(cm)',axis_style=1,rgb_table=4,font_size=16,position=[0.15,0.15,0.85,0.85])
c1=colorbar(target=g1,orientation=1,textpos=1,title='Flow potential(arb)',font_size=16,position=[0.83,0.25,0.86,0.75])
g1.save, 'Reconstructed flow potential crossection profile.png',resolution=100

g2=image(rebin(2.0*real_part(ip_input),1024,800),findgen(1024)*10.0/1023-5.0,findgen(800)*0.01,$
  xtitle='Radius(cm)',ytitle='Frame No.',rgb_table=4,axis_style=1,font_size=16,position=[0.15,0.15,0.80,0.85])
c2=colorbar(target=g2,orientation=1,textpos=1,title='Intensity fluctuation(arb)',font_size=16,position=[0.83,0.25,0.86,0.75])
g2.save, 'Measured intensity fluctuation profile.png',resolution=100
g3=image(rebin(ip_recon_pro,1024,800),findgen(1024)*10.0/1023-5.0,findgen(800)*0.01,$
  xtitle='Radius(cm)',ytitle='Frame No.',rgb_table=4,axis_style=1,font_size=16,position=[0.15,0.15,0.80,0.85],max_value=1.0,min_value=-1.0)
c3=colorbar(target=g3,orientation=1,textpos=1,title='Intensity fluctuation(arb)',font_size=16,position=[0.83,0.25,0.86,0.75])
g3.save, 'Reconstructed intenstiy fluctuation profile.png',resolution=100

vel_mea=2.0*real_part(vel_input)+vel_resi
vel_mea(0:beg_ind,*)=0.0
vel_mea(end_ind:*,*)=0.0
gg2=image(rebin(vel_mea,1024,800),findgen(1024)*10.0/1023-5.0,findgen(800)*0.01,$
  xtitle='Radius(cm)',ytitle='Frame No.',rgb_table=4,axis_style=1,font_size=16,position=[0.15,0.15,0.80,0.85],max_value=60.0,min_value=-60.0)
cc2=colorbar(target=gg2,orientation=1,textpos=1,title='Flow fluctuation(m/s)',font_size=16,position=[0.83,0.25,0.86,0.75])
gg2.save, 'Measured flow fluctuation profile.png',resolution=100
vel_rec=vel_recon_pro+vel_resi
vel_rec(0:beg_ind,*)=0.0
vel_rec(end_ind:*,*)=0.0
gg3=image(rebin(vel_rec,1024,800),findgen(1024)*10.0/1023-5.0,findgen(800)*0.01,$
  xtitle='Radius(cm)',ytitle='Frame No.',rgb_table=4,axis_style=1,font_size=16,position=[0.15,0.15,0.80,0.85],max_value=60.0,min_value=-60.0)
cc3=colorbar(target=gg3,orientation=1,textpos=1,title='Flow fluctuation(m/s)',font_size=16,position=[0.83,0.25,0.86,0.75])
gg3.save, 'Reconstructed flow fluctuation profile.png',resolution=100


flow_csecx=reform(flow_recon_csec_x(*,*,1))*mask_cor_csec
flow_csecy=reform(flow_recon_csec_y(*,*,1))*mask_cor_csec
gg4=vector(rebin(flow_csecx,40,40),rebin(flow_csecy,40,40),findgen(40)*10.0/39-5.0,findgen(40)*10/39.0-5,xtitle='Radius(cm)',ytitle='Radius(cm)',axis_style=1,$
  auto_color=1,length_scale=2,rgb_table=4,font_size=16,position=[0.15,0.15,0.80,0.85],xrange=[-3,3],yrange=[-3,3])
cc4=colorbar(target=gg4,textpos=1,title='Amplitude(arb)',position=[0.83,0.25,0.86,0.75],font_size=16,orientation=1)
gg4.save, 'Reconstructed flow radial profile.png',resolution=100



velp_csecx=reform(vel_con_x(*,*,2))*mask_cor_csec
velp_csecy=reform(vel_con_y(*,*,2))*mask_cor_csec
g4=vector(rebin(velp_csecx,40,40),rebin(velp_csecy,40,40),findgen(40)*10.0/39-5.0,findgen(40)*10/39.0-5,xtitle='Radius(cm)',ytitle='Radius(cm)',axis_style=1,$
  auto_color=1,length_scale=2,rgb_table=4,font_size=16,position=[0.15,0.15,0.80,0.85],xrange=[-3,3],yrange=[-3,3])
c4=colorbar(target=g4,textpos=1,title='Amplitude(arb)',position=[0.83,0.25,0.86,0.75],font_size=16,orientation=1)
g4.save, 'Reconstructed potential fluctuation crossection profile.png',resolution=100





ip_rad_phase=mean(ip_rad_pha,dimension=2)
vel_rad_phase=mean(vel_rad_pha,dimension=2)
valid_pha_st=round(n_elements(ip_rad_phase)*valid_por)
pha_cor=findgen(48)*5.0/47
p=plot(pha_cor(0:valid_pha_st),ip_rad_phase(0:valid_pha_st),xrange=[0,3.0],yrange=[-!pi,!pi],xtitle='Radius(cm)',ytitle='Phase(radians)')
p.save, 'Intensity fluctuaton radial phase variation.png',resolution=100
p1=plot(pha_cor(0:valid_pha_st),vel_rad_phase(0:valid_pha_st),xrange=[0,3.0],yrange=[-!pi,!pi],xtitle='Radius(cm)',ytitle='Phase(radians)')
p1.save, 'FLow potential raidal phase variaton.png',resolution=100
p2=plot(pha_cor(0:valid_pha_st),vel_recon(0:valid_pha_st),xrange=[0,3.0],xtitle='Radius(cm)',ytitle='Flow potential fluctuation(arb)')
p2.save, 'Reconstructed potential fluctuation raidal profile.png',resolution=100
p3=plot(pha_cor(0:valid_pha_st),ip_recon(0:valid_pha_st),xrange=[0,3.0],xtitle='Radius(cm)',ytitle='Intensity fluctuation profile(arb)')
p3.save, 'Reconstructed intensity fluctuation profile.png',resolution=100


; phase 


stop

!p.multi=[0,3,2]
!p.charsize=2
imgplot,2.0*real_part(vel_input)+vel_resi,title='shot364 flow perturbaiton input(normalized)',xtitle='Camera pixel',ytitle='Frame No.',/cb,zr=[-80,80]
plot, knots_co,vel_recon1,title='shot364 reconstructed radial profile',xtitle='Radius(m)',ytitle='Flow potential(arb)'
plot, rebin(knots_co,nn),mean(vel_rad_pha,dimension=2),title='shot364 reconstructed phase radial profile',xtitle='Radius(m)',ytitle='Phase(radians)',yrange=[-!pi,!pi]
imgplot, vel_recon_pro+vel_resi,title='shot364 reconstructed flow perturbation',xtitle='camera pixel',ytitle='Frame No.',/cb,zr=[-80,80]
vel_err=2.0*real_part(vel_input)-vel_recon_pro
imgplot, vel_err, title='shot364 reconstruction error',xtitle='Camera pixel',ytitle='Flow perturbaiton error(m/s)',zr=[-80,80],/cb

valr=float(val_pix)/pn*radius
val_ind=where(knots_co le valr)
maxpix=max(val_ind)
val_r=knots_co(0:maxpix)
val_i=i_recon1(0:maxpix)
val_i=val_i/max(val_i)
val_ip=ip_recon1(0:maxpix)
val_ip=val_ip/max(val_ip)
val_flow=flow_recon1(0:maxpix)
val_flow=val_flow/max(val_flow)
val_vel=vel_recon1(0:maxpix)
val_vel=val_vel/max(val_vel)
i_gra=deriv(val_r,val_i)
i_gra=smooth(abs(i_gra),8)/max(smooth(abs(i_gra),10))
i_gra_div=(i_gra/val_i)/max((i_gra/val_i))
flow_gra=deriv(val_r,val_flow)
flow_gra=smooth(abs(flow_gra),8)/max(smooth(abs(flow_gra),8))
p=plot(val_r,val_i,title='Normalized reconstructed quantities',xtitle='Radius(m)',ytitle='Intensity(arb)',name='Density')
p1=plot(val_r,val_ip,title='Normalized reconstructed quantities',xtitle='Radius(m)',ytitle='Intensity(arb)',/overplot,name='Density perturbaiton',color='red')
p2=plot(val_r,val_flow,title='Normalized reconstructed quantities',xtitle='Radius(m)',ytitle='Intensity(arb)',/overplot,name='Flow',color='blue')
p3=plot(val_r,val_vel,title='Normalized reconstructed quantities',xtitle='Radius(m)',ytitle='Intensity(arb)',/overplot,name='Flow potential',color='orange')
p4=plot(val_r,i_gra,title='Normalized reconstructed quantities',xtitle='Radius(m)',ytitle='Intensity(arb)',/overplot,name='Density gradient',color='purple')
p5=plot(val_r,i_gra_div,title='Normalized reconstructed quantities',xtitle='Radius(m)',ytitle='Intensity(arb)',/overplot,name='Gradient over density',color='green')
p6=plot(val_r,flow_gra,title='Normalized reconstructed quantities',xtitle='Radius(m)',ytitle='Intensity(arb)',/overplot,name='Flow gradient',color='cyan')
l=legend(target=[p,p1,p2,p3,p4,p5,p6],/AUTO_TEXT_COLOR,position=[0.98,0.90,1.0,0.93])
;---------------------------------------------------------------------------------------------


intp_amp=2.0*real_part(mdata)
intp_pha=atan(mdata,/phase)
intp_pha=mean(intp_pha(160:230,*),dimension=1)
;pick up plasam area
indp=where(marr_dc lt 0.1*max(marr_dc))
intp_amp(indp,*)=0.
recon_ip_pro(indp,*)=0.0

intp_amp=intp_amp/max(intp_amp)
recon_ip_pro= recon_ip_pro/max(recon_ip_pro)

;!p.multi=[0,2,2]
;!p.charsize=1
;plot, findgen(512),marr_dc/max(marr_dc),xtitle='Camera pixel',ytitle='Normalized intensity (arb)',title='DC proile(shifted shot364)'
;oplot,findgen(512),recon_i_pro/max(recon_i_pro),color=3
;plot, rv,smooth(rden_dc,5)/max(smooth(rden_dc,5)),xtitle='Radius(m)',ytitle='Normalized intensity (arb)',title='Reconstructed radial proile(shot364)',yrange=[0,1]
;!p.multi=0
;plot, rv,smooth(rden,5)/max(smooth(rden,5)),xtitle='Radius(m)',ytitle='Intensity(arb)',title='Reconstructed AC radial profile'



!p.multi=[0,3,2]
!p.charsize=2
imgplot, intp_amp,xtitle='Camera pixel',ytitle='Frame NO.',title='Intensity perturbation of shot'+shot+'(arb)',/cb
plot, intp_pha,xtitle='Frame NO.',ytitle='Phase(radians)',title='Input phase od shot'+shot,yrange=[-!pi,!pi]
imgplot, intp_amp-recon_ip_pro,xtitle='Camera pixel',ytitle='Frame NO.',title='Amplitude error',zr=[-1,1],/cb
imgplot, recon_ip_pro, xtitle='Camera pixel',ytitle='Frame NO.',title='Reconstructed intensity perturbation(arb)',/cb
plot, recon_ip_pha,xtitle='Frame NO.',ytitle='Reconstructed phase(radians)',title='Reconstructed phase',yrange=[-!pi,!pi]
plot, recon_ip_pha-intp_pha,title='Phase error',xtitle='Frame NO.',ytitle='Phase error(radians)',yrange=[-!pi,!pi]
;plot, findgen(512),dr(*,2),xtitle='Camera pixel',ytitle='Intensity(arb)',title='Input real part'
;plot, findgen(512),di(*,2),xtitle='Camera pixel',ytitle='Intensity(arb)',title='Input imaginary part'
;plot, mean(cweights,dimension=2), xtitle='Intenval NO.',ytitle='Calculated weights',title='Weight profile'
stop
;check the location of the wave
fcoor=range(-radius,radius,npts=pn)
indval=where(marr_dc ge 0.1*max(marr_dc))
cr=max(fcoor(indval)) 
indval1=where(rv le cr)

valdc=rp_dc(indval1)
valac=rp(indval1)
valr=rv(indval1)

valdc=valdc/max(valdc)
valac=valac/max(valac)
gradc=abs(deriv(valr,valdc))
gradc=smooth(gradc/max(gradc),5)

gradc_div_dc=gradc/valdc
gradc_div_dc=gradc_div_dc/max(gradc_div_dc)
!p.multi=[0,2,1]
!p.charsize=1
plot, findgen(512),marr_dc,title='Shot'+shot+'DC profile', xtitle='Camera pixel',ytitle='Intensity(arb)'
plot, valr,valdc,xtitle='Radius(m)',ytitle='Normalized amplitude',title='Reconstructed quantities'
oplot, valr,valac,color=3
oplot, valr,gradc,color=4
oplot,valr,gradc_div_dc,color=6
 
stop
end