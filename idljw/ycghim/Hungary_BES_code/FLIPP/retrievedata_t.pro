;==============================================================================
; TEXTOR Data Retrieval                                                RPS 4/99
;------------------------------------------------------------------------------

pro RetrieveData_t, Shot, Name, nd, tt, ss, RetrieveOK

;------------------------------------------------------------------------------
; Shot (Long Integer)   : TEXTOR Shot Number
; Name (String)         : Signal Name
; nd (Long Integer)     : Number of data points to be retrieved
; tt (fltarr)           : Time vector retrieved
; ss (fltarr)           : Signal vector retrieved
; RetrieveOK (Integer)  : 1 OK, 0 not OK
;
; works on IPPPWW under OpenVMS 7.1 AXP and IDL 5.2
;------------------------------------------------------------------------------

print,'RETRIEVEDATA_T... shot:'+I2STR(SHOT)+'  NAME:'+name
t  = fltarr(nd)
s  = fltarr(nd)

LC           = 0
T_Act        = 0.0
Sub          = '*'
Stor         = 'PRIVATE'
Tim          = 'B'
Status       = 0L
Status_Block = intarr(4)
RetrieveOK   = 1

Status = CALL_EXTERNAL ('rt2shrlib','Define_Channel', $
                        Status_Block,LC,Shot,Name,Sub,Stor,Tim, $
                        Default='USR$SYSROOT:[USRLIB].exe',/vax_float)

If (Status NE 134316041) then Begin
         RetrieveOK = 0
         print,'Error in RETRIEVEDATA_T: 1'
         Return
EndIf

Status = CALL_EXTERNAL ('rt2shrlib','Read_Channel', $
                        Status_Block,LC,T_Act,ND,T,S, $
                        Default='USR$SYSROOT:[USRLIB].exe',/vax_float)

Status = CALL_EXTERNAL ('rt2shrlib','Release_Channel', $
                        Status_Block,LC, $
                        Default='USR$SYSROOT:[USRLIB].exe',/vax_float)

tt = t(0:nd-1)
ss = s(0:nd-1)

end ; pro RetrieveData

;==============================================================================
