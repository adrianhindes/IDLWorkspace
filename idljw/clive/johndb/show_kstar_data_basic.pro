pro show_kstar_data_basic, shotno, xrange=xrange, tree=tree

if n_params() ne 1 then stop,'Please provide shotno'
default, tree, 'kstar'

mdsopen, tree, shotno
default, xrange, [-.5,10.0]

window,1,xs=1400,ys=900
!p.multi = [0,4,3]
!p.font=-1 & !p.charsize=2
!p.background=1
!p.color=0
tek_color
            
d = kstar_read_node('.kstar:ip',status=status)
if status then plot,d.time,-d.data/1000,xr=xrange,/xst,$
                titl='Plasma and TFC currents.  Shot #'+strtrim(shotno,2),$
                ytitle=d.units, xtitle='Time (s)'    

d = kstar_read_node('.kstar:i_tfc',status=status)
if status then oplot,d.time, d.data/100, col=2  

d = kstar_read_node('.kstar:NB1_PB1',status=status)
if status then plot,[d.time],[d.data],xr=xrange,/xst,titl=d.name,ytitle=d.units, xtitle='Time (s)', yrange=[0,4]

d = kstar_read_node('.kstar:NB1_PB2',status=status)
if status then oplot,[d.time],[d.data], col=2

d = kstar_read_node('.kstar:NB11_I0',status=status)
if status then plot,[d.time],[d.data],xr=xrange,/xst,titl=d.name,ytitle=d.units, xtitle='Time (s)', yrange=[0,60]

d = kstar_read_node('.kstar:NB12_I0',status=status)
if status then oplot,[d.time],[d.data], col=2

d = kstar_read_node('.kstar:NB11_VG1',status=status)
if status then plot,[d.time],[d.data],xr=xrange,/xst,titl=d.name,ytitle=d.units, xtitle='Time (s)', yrange=[0,100]

d = kstar_read_node('.kstar:NB12_VG1',status=status)
if status then oplot,[d.time],[d.data], col=2

d = kstar_read_node('.kstar:ICRF',status=status)
if status then plot,[d.time],[d.data],xr=xrange,/xst,titl=d.name,ytitle=d.units, xtitle='Time (s)', yrange=[0,4000]

d1 = kstar_read_node('.kstar:ECH',status=status)
if status then oplot,[d.time],[d.data], col=2

d = kstar_read_node('.kstar:n_e',status=status)
if status then plot,[d.time],[d.data],xr=xrange,/xst,titl=d.name,ytitle=d.units, xtitle='Time (s)'    

d = kstar_read_node('.kstar:wtot',status=status)
if status then plot,[d.time],[d.data],xr=xrange,/xst,titl=d.name,ytitle=d.units, xtitle='Time (s)'    

d = kstar_read_node('.kstar:ece02',status=status)
if status then plot,[d.time],[d.data],xr=xrange,/xst,titl=d.name,ytitle=d.units, xtitle='Time (s)'    

d = kstar_read_node('.kstar:cxrs.ti04',status=status)
if status then plot,[d.time],[d.data],xr=xrange,/xst,titl=d.name,ytitle=d.units, xtitle='Time (s)', yrange=[0.,5000]
for i=8,28,4 do begin &$
  d = kstar_read_node('.kstar:cxrs.ti'+string(i,'(i02)'),status=status) &$
  if status then oplot,[d.time],[d.data], col=i/4 &$
end

d = kstar_read_node('.kstar:cxrs.vt04',status=status)
if status then plot,[d.time],[d.data],xr=xrange,/xst,titl=d.name,ytitle=d.units, xtitle='Time (s)', yrange=[-100.,400]
for i=8,28,4 do begin &$
  d = kstar_read_node('.kstar:cxrs.vt'+string(i,'(i02)'),status=status) &$
  if status then oplot,[d.time],[d.data], col=i/4 &$
end

d = kstar_read_node('.kstar:halpha',status=status)
if status then plot,[d.time],[d.data],xr=xrange,/xst,titl=d.name,ytitle=d.units, xtitle='Time (s)'    

d = kstar_read_node('.kstar:MSE_I0_TOT',status=status)
if status then plot,[d.time],[d.data],xr=xrange,/xst,titl=d.name,ytitle=d.units, xtitle='Time (s)'    
d = kstar_read_node('.kstar:CXRS_I0_TOT',status=status)
if status then oplot,[d.time],[d.data],col=2   

!p.multi=0
!p.background = 16777215
!p.color = 0
end
 