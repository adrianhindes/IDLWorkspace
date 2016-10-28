function read_datam,shot,ch1,dt=dt,t0=t0,newdig=newdig,anal=anal,pmt=pmt
if shot ge 83000 and not keyword_set(pmt) then newdig=1
tab=[$
;REAL CHNO, FENTON CHNO, DIG NO, CHAN NO
[0,	11,	22,5],$
[1,	10,	22,4],$
[2,	9,	22,3],$
[3,	8,	22,2],$
[4,	7,	22,1],$
[5,	6,	21,6],$
[6,	5,	21,5],$
[7,	4,	21,4],$
[8,	3,	21,3],$
[9,	2,	21,2],$
[10,	1,	21,1],$
[11,	12,	22,6],$
[12,	13,	23,1],$
[13,	14,	23,2],$
[14,	15,	23,3],$
[15,	16,	23,4],$
[16,	17,	23,5],$
[17,	18,	23,6],$
[18,	19,	24,1],$
[19,	20,	24,2],$
[20 ,  	21,	24,3],$
[21 ,  	22,	24,4]] ; refrence


if keyword_set(pmt) then begin
tab=[$
[0,0,21,1],$
[1,1,21,2],$
[2,2,21,3],$
[3,3,21,4],$
[4,4,21,5],$
[5,5,21,6],$
[6,6,22,1],$
[7,7,22,2],$
[8,8,22,3],$
[9,9,22,4],$
[10,10,22,5],$
[11,11,22,6],$
[12,12,23,1],$
[13,13,23,2],$
[14,14,23,3],$
[15,15,23,4]]
endif



ch=tab(0,*)
fentchno=tab(1,*)
digno=tab(2,*)
inpno=tab(3,*)

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
