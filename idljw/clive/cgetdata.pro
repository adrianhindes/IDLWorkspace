function cgetdata,name,norest=norest,shot=shot,db=db
common cbshot, shotc,dbc, isconnected

if keyword_set(shot) then shotc=shot
if keyword_set(db) then dbc=db

home=gettstorepath()


kavail=[9943,$
;9888,$
;9892,$
;9880,$
9944,$
9945,$
9946,$
9947,$
9948,$
9949,$
9950,$
9951,$
9952,$
9953,$
9954,$
9955,$
9956,$
9957,$
9958,$
9959,$
9960,$
9961,$
9962,$
9963,$
9964,$
10020,$
10021,$
10022]

dum=where(shotc eq kavail,cnt)


if shotc lt 8700 then goto,aaa
if getenv('COMPUTERNAME') eq 'PRL98' then cnt=1
spawn,'hostname',host
if host eq 'prl75' then cnt=1
;cnt=1

if shotc eq 10502 then cnt=0
;stop
if (cnt eq 0 and shotc gt 9500) or  (getenv('COMPUTERNAME') eq 'PRL98' )  then goto,aaa

;and strupcase(getenv('USER')) eq 'USER')

;if shotc eq 9892 then shotc=9998
;if shotc eq 9880 then shotc=999811
;if shotc eq 9888 then shotc=9998

if host eq 'ikstar.nfri.re.kr' then goto,aaa
tlist=[['\NB11_I0','.KSTAR:NB11_I0'],$
       ['\NB12_I0','.KSTAR:NB12_I0'],$
       ['\NB13_I0','.KSTAR:NB13_I0'],$
       ['\NB11_VG1','.KSTAR:NB11_VG1'],$
       ['\RC01','.KSTAR:IP'],$
;       ['\LV23','.KSTAR:LV23'],$
       ['\EC1_RFFWD1',':ECCD_FWD'],$
       ['\ECH_VFWD1','.KSTAR:ECH']]
if n_elements(isconnected) eq 0 then isconnected=0
nt=n_elements(tlist(0,*))
for j=0,nt-1 do begin
   if tlist(0,j) eq name then begin
      if isconnected eq 1 then begin
         mdsdisconnect
         isconnected=0
      endif
;      stop
      mdsopen,'kstar',shotc

      y=mdsvalue2(tlist(1,j),/nozero)
      print,'got from',tlist(1,j)
      mdsclose
      return,y
   endif
endfor
aaa:


print,'not getting from db'
;sh=fix(mdsvalue('$shot'))
sh=shotc
fn=string(home,sh,winslashdollar(name),format='(A,I0,"_",A,".hdf")')
if keyword_set(norest) then goto,af
dum=file_search(fn,count=cnt)

if cnt ne 0 then begin
;    stop
    hdfrestoreext,fn,dum
    print,'restored from',fn
    return,dum

endif
af:



if n_elements(isconnected) eq 0 then isconnected=0

if dbc eq 'kstar' then begin

   if !version.os ne 'Win32' then begin
      spawn,'hostname',hostname
      if hostname ne 'ikstar.nfri.re.kr' then begin
         if hostname eq 'prl63' or hostname eq 'prl750' then $
            stop $
;             mdsconnect,'172.17.100.200:8300' 
         else $
         mdsconnect,'172.17.250.100:8005'
         isconnected=1
      endif
   endif else begin
      if getenv('COMPUTERNAME') eq 'JINIL-PC' or getenv('COMPUTERNAME') eq '2D-MSE2' or getenv('COMPUTERNAME') eq 'PRL33' or getenv('COMPUTERNAME') EQ 'PRL98' then mdsconnect,'172.17.100.200:8300' else mdsconnect,'172.17.250.100:8005'
      isconnected=1
    endelse
endif else begin

    if isconnected eq 1 then begin
        mdsclose
        mdsdisconnect
        isconnected=0
    endif

endelse


mdsopen,dbc,shotc


v=mdsvalue(''+name)
print,'got ',name
if n_elements(v) gt 0 then t=mdsvalue('DIM_OF('+name+')') else t=0.
print,'got dim of ',name
rv={t:t,v:v}
if not keyword_set(norest) then begin
    hdfsaveext,fn,rv
    print,'saved to',fn
endif
mdsclose

return,rv
end
