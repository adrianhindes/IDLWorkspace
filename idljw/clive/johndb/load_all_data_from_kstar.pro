pro Load_ALL_data_from_kstar, shotno, force=force

; this reads data from the KSTAR mdsplus database and puts it into
; the MSE databse on local computer.  Name mappings are different

;default, shotno, 5954

print,'Opening kstar at shot '+strtrim(shotno, 2)+' ...'

tree = 'kstar'
quiet = 1

; see what's ther already
if keyword_set(force) then begin
  
  Ipstatus = 0B
  TFstatus = 0B
  wtotstatus = 0B
  NB1status = 0B
  NB2status = 0B
  NBV1status = 0B
  NBV2status = 0B
  VBstatus = 0B
  PB1status = 0B
  PB2status = 0B
  ICRFstatus = 0B
  ECHstatus = 0B
  INTstatus = 0B
  ECE02status = 0B
  ECCDstatus = 0B
  HAstatus = 0B
  LV23status = 0B
  LMSRstatus = 0B
  RMPstatus = 0B
  
end else begin

mdsopen,tree, shotno, quiet=quiet, Status = TreeStatus
y = mdsvalue('getnci(.kstar,"NID_NUMBER")', stat=KSTARstatus, quiet=quiet)
y = mdsvalue('getnci(.kstar:Ip,"NID_NUMBER")', stat=Ipstatus, quiet=quiet)
y = mdsvalue('getnci(.kstar:I_TFC,"NID_NUMBER")', stat=TFstatus, quiet=quiet)
y = mdsvalue('getnci(.kstar:wtot,"NID_NUMBER")', stat=wtotstatus, quiet=quiet)
y = mdsvalue('getnci(.kstar:NB12_I0,"NID_NUMBER")', stat=NB1status, quiet=quiet)
y = mdsvalue('getnci(.kstar:NB11_I0,"NID_NUMBER")', stat=NB2status, quiet=quiet)
y = mdsvalue('getnci(.kstar:NB11_VG1,"NID_NUMBER")', stat=NBV1status, quiet=quiet)
y = mdsvalue('getnci(.kstar:NB12_VG1,"NID_NUMBER")', stat=NBV2status, quiet=quiet)
y = mdsvalue('getnci(.KSTAR:VISBREM18,"NID_NUMBER")', stat=VBstatus, quiet=quiet)
y = mdsvalue('getnci(KSTAR:NB1_PB1,"NID_NUMBER")', stat=PB1status, quiet=quiet)
y = mdsvalue('getnci(KSTAR:NB1_PB2,"NID_NUMBER")', stat=PB2status, quiet=quiet)
y = mdsvalue('getnci(KSTAR:ICRF,"NID_NUMBER")', stat=ICRFstatus, quiet=quiet)
y = mdsvalue('getnci(KSTAR:ECH,"NID_NUMBER")', stat=ECHstatus, quiet=quiet)
y = mdsvalue('getnci(KSTAR:N_E,"NID_NUMBER")', stat=INTstatus, quiet=quiet)
y = mdsvalue('getnci(KSTAR:ECE02,"NID_NUMBER")', stat=ECE02status, quiet=quiet)
y = mdsvalue('getnci(KSTAR:ECCD_FWD,"NID_NUMBER")', stat=ECCDstatus, quiet=quiet)
y = mdsvalue('getnci(KSTAR:HALPHA,"NID_NUMBER")', stat=HAstatus, quiet=quiet)
y = mdsvalue('getnci(KSTAR:LV23,"NID_NUMBER")', stat=LV23status, quiet=quiet)
y = mdsvalue('getnci(KSTAR:LMSR,"NID_NUMBER")', stat=LMSRstatus, quiet=quiet)
y = mdsvalue('getnci(KSTAR:RMP_M_I,"NID_NUMBER")', stat=RMPstatus, quiet=quiet)

mdsclose
end

mdsconnect,'172.17.250.100:8005'
;mdsconnect,'172.17.100.200:8300'
mdsopen, tree, shotno

Print,'Plasma current ...'
if Ipstatus then print,'Ip data in tree' else Ip = kstar_read_node('\RC03', local='KSTAR:Ip')

Print,'Toroidal current ...'
if TFstatus then print,'I_TFC data in tree' else I_TFC = kstar_read_node('\PCITFMSRD', local='KSTAR:I_TFC')
  
Print,'Icrf ...'
if ICRFstatus then print,'ICRF data in tree' else Icrf = kstar_read_node('\ICRF_FWD-\ICRF_REF', local='KSTAR:ICRF')

Print,'ECH ...'
if ECHstatus then print,'ECH data in tree' else ech = kstar_read_node('\ECH_VFWD1', local='KSTAR:ECH')

Print,'NBI ...'
if NB1status then print,'NB1 data in tree' else nbi11 = kstar_read_node('\NB11_I0', local='KSTAR:NB11_I0')
if NB2status then print,'NB2 data in tree' else nbi12 = kstar_read_node('\NB12_I0', local='KSTAR:NB12_I0')
if NBV1status then print,'NBV1 data in tree' else nbv1 = kstar_read_node('\NB11_VG1', local='KSTAR:NB11_VG1')
if NBV2status then print,'NBV2 data in tree' else nbv2 = kstar_read_node('\NB12_VG1', local='KSTAR:NB12_VG1')

Print,'Total beam power ...'
if PB1status then print,'PB1 data in tree' else PB1 = kstar_read_node('\NB1_PB1', local='KSTAR:NB1_PB1')
if PB2status then print,'PB2 data in tree' else PB2 = kstar_read_node('\NB1_PB2', local='KSTAR:NB1_PB2')

Print,'D2 flow ...'
KFLOW = kstar_read_node('\K_GFLOW_IN', local='KSTAR:K_GFLOW')

Print,'ECE ...'
if ECE02status then print,'ECE02 data in tree' else ece = kstar_read_node('\ECE02', local='KSTAR:ECE02')

if ECCDstatus then print,'ECCD data in tree' else ECCD = kstar_read_node('\EC1_RFFWD1', local='ECCD_FWD')


Print,'Interferometer ...'
if INTstatus then print,'Interferometer data in tree' else interf = kstar_read_node('\NE_INTER01', local='KSTAR:N_E')

Print,'Halpha ...'
if HAstatus then print,'Halpha data in tree' else HA = kstar_read_node('\POL_HA02', local='KSTAR:HALPHA')

Print,'Visible bremsstrahlung ...'
if VBstatus then print,'Visible Bremsstrahlung data in tree' else VB18 = kstar_read_node('\tube10', local='KSTAR:VISBREM18')
;\TUBE09 ON  VIS_FILTER  VB measured in toroidal 17 ch.  
;\TUBE10 ON  VIS_FILTER  VB measured in toroidal 18 ch. 
;\TUBE11 ON  VIS_FILTER  VB measured in toroidal 19 ch.

Print,'Last magnetic surface ...'
if LMSRstatus then print,'LMSR data in tree' else LMSR = kstar_read_node('\LMSR', local='KSTAR:LMSR')

Print,'Stored energy ...'
if wtotstatus then print,'Store energy data in tree' else Energy = kstar_read_node('\Wtot_DLM03', local='KSTAR:WTOT')

Print,'RMP ...'
if rmpstatus then print,'RMP data in tree' else rmp_m_i = kstar_read_node('.operation.rmp.rmpm.rmpm_i', local='KSTAR:RMP_M_I')

Print,'Loop voltage ...'
if LV23status then print,'Loop Voltage 23 data in tree' else LV23 = kstar_read_node('\LV23', local='KSTAR:LV23')

kstar_read_cxrs, Ti, Vt    ; these are arrays

kstar_read_PF_currents, PF1, PF2, PF3U, PF4U, PF5U, PF6U, PF3L, PF4L, PF5L, PF6L, PF7, IVFC
                                 

mdsclose
mdsdisconnect


Print,'______________________________________'
Print,'Saving to local DB ...'

write_local_kstar_data, shotno, nbi11, nbi12, Nbv1, nbv2, Energy, /create

write_local_kstar_data, shotno, $
                        Ip, Icrf, ech,  PB1, PB2, ece, interf, ha, lmsr, rmp_m_i,$
                        Kflow, VB18, I_TFC, ECCD

write_local_kstar_data, shotno, subtree='PF', $
                        PF1, PF2, PF3U, PF4U, PF5U, PF6U,$
                        PF3L, PF4L, PF5L, PF6L, PF7, IVFC
                        
write_local_kstar_data, shotno, subtree='CXRS', Ti, VT

;print,'Cleaning the tree ..''
;    mdsclean, tree, shotno
                        
Print,'______________________________________'


end

