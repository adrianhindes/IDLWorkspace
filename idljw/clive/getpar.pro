@~/idl/clive/probe_charnew
@~/idl/clive/readpatcharr

function getpar, sh, par, tw=tw,y=y,st=st,data=data
mach='h1'

if mach eq 'magpie' then begin

if par eq 'isat' then begin

dum=magpie_data('probe_isat',sh) &dum.vvector/=(sh eq 465 ? 50 : 200.)
endif

if par eq 'isatfork' then begin
dum=magpie_data('probe_isat_rot',sh) &dum.vvector/= 400. 
;dum=magpie_data('single_pmt',sh) &dum.vvector/= 1.
;dum=magpie_data('probe_vplus',sh) &dum.vvector/= 400. 
endif
;1895/1902,1900
;1905 no choke
;1906 choke on, curr on -

; wednesday comparing discharge types
;2710 nearest

if par eq 'vfloat' then begin
dum=magpie_data('probe_vfloat',sh) &dum.vvector/=5./333.
endif

if par eq 'vfloatfork' then begin
dum=magpie_data('probe_vfloat_rot',sh) &dum.vvector/= 5./333.
;dum=magpie_data('probe_vplus',sh) &dum.vvector/=  5./333.
;dum2=magpie_data('probe_vfloat',sh) &dum2.vvector/=  5./333.
;dum.vvector=dum.vvector-dum2.vvector

endif

if par eq 'vplus' then begin
dum=magpie_data('probe_vplus',sh) &dum.vvector/=5./333.
endif



y={t:dum.tvector,v:dum.vvector}
endif



if mach eq 'h1' then begin
mdsopen,'h1data',sh
if par eq 'lint' then begin
   y=mdsvalue2('\H1DATA::TOP.ELECTR_DENS.NE_HET:NE_CENTRE',/nozero)
;   demodsw,sh,10,yy,tt & y={v:yy,t:tt}
endif
if par eq 'mirnov' then begin
   y=mdsvalue2('\H1DATA::TOP.MIRNOV.ACQ132_7:INPUT_01',/nozero)
;   demodsw,sh,10,yy,tt & y={v:yy,t:tt}
endif

if par eq 'lint2' then begin
;   y=mdsvalue2('\H1DATA::TOP.ELECTR_DENS.NE_HET:NE_9',/nozero)
   demodsw,sh,2,yy,tt & y={v:yy,t:tt}
endif

if par eq 'isat' then begin
   readpatchpr,sh,str,file='BPP_FP_settings.csv',data=data
   nd='\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_'+string(str.isatdig,format='(I0)')
   y=mdsvalue2(nd,/nozero) & y.v*=1/str.isatrm / str.isatgain
;   print,str.ampgain4

endif
if par eq 'isatfork' then begin
   readpatchpr,sh,str,file='BPP_FP_settings.csv',data=data
   nd='\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_09:INPUT_6'
   y=mdsvalue2(nd,/nozero) & y.v*=1./50
;   print,str.ampgain4

endif

if par eq 'isatotherfork' then begin
   readpatchpr,sh,str,file='BPP_FP_settings.csv',data=data
   nd='\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_09:INPUT_5'
   y=mdsvalue2(nd,/nozero) & y.v*=1./50
;   print,str.ampgain4

endif

if par eq 'vfloat' then begin
   readpatchpr,sh,str,file='BPP_FP_settings.csv',data=data
   nd='\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_'+string(str.vfldig,format='(I0)')
   y=mdsvalue2(nd,/nozero) & y.v*=str.vfldr / str.vflgain ; gain;/str.ampgain3;250/5;

endif

if par eq 'vplasma' then begin
   readpatchpr,sh,str,file='BPP_FP_settings.csv',data=data
   nd='\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_08:INPUT_'+string(str.vpldig,format='(I0)')
   y=mdsvalue2(nd,/nozero) & y.v*=str.vpldr/str.vplgain;ampgain3;250/5;
endif

if par eq 'tebp' then begin
   dum=getpar(sh,'vplasma',y=y1,tw=[0,.01])
   dum=getpar(sh,'vfloat',y=y2,tw=[0,.01])
   y=y1 & y.v = ( (y1.v - y2.v) / 3.76 )
endif


if par eq 'pres' then begin
   dum=getpar(sh,'tebp',y=y1,tw=[0,.01])
   dum=getpar(sh,'isat',y=y2,tw=[0,.01])
   y=y1 & y.v = y1.v * y2.v
endif


if par eq 'vfloatfork' then begin
   readpatchpr,sh,str,file='BPP_FP_settings.csv',data=data
   nd='\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_09:INPUT_3'

   y=mdsvalue2(nd,/nozero) & y.v*=50 / (sh le 83700 ? 5 : 1)

endif

if par eq 'vplusfork' then begin
   readpatchpr,sh,str,file='BPP_FP_settings.csv',data=data
   nd='\H1DATA::TOP.FLUCTUATIONS.CAMAC:A14_09:INPUT_4'

   y=mdsvalue2(nd,/nozero) & y.v*=50 ;/ (sh le 83700 ? 5 : 1)

endif

mdsclose
endif

idx=where(y.t ge tw(0) and y.t le tw(1))
val=mean(y.v(idx))
st=stdev(y.v(idx))
return,val
end
