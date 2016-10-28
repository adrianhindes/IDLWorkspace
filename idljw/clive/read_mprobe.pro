function read_datam,shot,ch1,dt=dt,t0=t0
tab=transpose(
[ [findgen(32)], [replicate(7,32)],[findgen(32)+1] ]

ch=tab(0,*)
edigno=tab(1,*)
inpno=tab(2,*)

if keyword_set(newdig) then digno=digno - 21 + 7

digno1=digno(ch1)
inpno1=inpno(ch1)
fentchno1=fentchno(ch1)

base='\ELECTR_DENS::TOP.CAMAC:'
if keyword_set(newdig) then dev='TR612' else dev='A14'
nd=base+dev+'_'+string(digno1,format='(I0)')+':INPUT_'+string(inpno1,format='(I0)')

if keyword_set(anal) then nd='\ELECTR_DENS::TOP.NE_HET:NE_'+string(fentchno1,format='(I0)')
mdsopen,'h1data',shot
y=mdsvalue(nd)
t=mdsvalue('DIM_OF('+nd+')')
dt=t(1)-t(0)
t0=t(0)
;dt=1/10e3 / 16.

return,y

end
