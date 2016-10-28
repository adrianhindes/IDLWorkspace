@z:\idl\clive\common\intspace.pro
function get2t,sh
file1='Z:\pll2\lastrun_daq\pll_'+string(sh,format='(I3.3)')+'.lvm'
dum=file_info(file1)
return,dum.mtime
end

function get1t,sh
file1='Z:\pll2\test'+string(sh,format='(I0)')+'.SPE'
dum=file_info(file1)

return,dum.mtime
end

;a=intspace(363,379)
;b=intspace(1,35)
a=intspace(397,411)
b=intspace(30,75)

;a=intspace(449,465)
;b=intspace(90,114)

na=n_elements(a)
nb=n_elements(b)
at=lonarr(na)
bt=lonarr(nb)
for i=0,na-1 do at(i)=get1t(a(i))
for i=0,nb-1 do bt(i)=get2t(b(i))

bofa=intarr(na)
for i=0,na-1 do begin
    del=bt-at(i)
    cent=65
    wid=10.
    idx=where(del gt cent-wid/2 and del lt cent+wid/2)
    if idx(0) ne -1 then bofa(i)=b(idx(0))
endfor
print,bofa
;stop
!p.multi=0
td=make_array(17,/float)
td2=td
order=['0','2','4','6','8','10','12','14','1','3','5','7','9','11','13','15','16']
for i=0,n_elements(bofa)-1 do begin
  file='Z:\pll2\test'+string(a(i),format='(I0)')+'.SPE'
  read_spe, file, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
  file='Z:\pll2\lastrun_daq\pll_'+string(bofa(i),format='(I3.3)')+'.lvm'
  data=myread_ascii(file,data_start=23,delim=string(byte(9)))
  ;plot, data(*,2)
  ;oplot, data(*,3),color=3
;save, data,filename='C:\haitao\papers\PMT camera\coherence data\data\data convert\'+'data'+string(a(i),format='(I0)')+'.save'
 ;endfor
  gate=data(*,3)
  osc=data(*,2)
  ind=where(gate ge 0.8*max(gate))
  gate1=gate(ind(0):ind(n_elements(ind)-1))
  ;plot, osc1,xrange=[0,50]
  ;oplot, gate1,color=3
  osc1=osc(ind(0):ind(n_elements(ind)-1))
  lag=findgen(30)
  cor=c_correlate(gate1,osc1,lag)
  plot, lag,cor,title='hey'
 ;   stop
  wait,0.1
  md=max(cor,ind)
  td(i)=ind*2.0
  td2(i)=str.gatedelay
 print, td(i)
 ; endfor
  
  ii=[indgen(8)*2,indgen(8)*2+1]
  plot,td(ii)
oplot,-td2(ii)+10
stop 

end
