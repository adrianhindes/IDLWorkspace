pro getflcinfo,str,info

if strupcase(strmid(str.cellno,0,3)) ne 'MSE' then begin
   stat1a=intarr(2000)
   stat1=[[stat1a],[stat1a*0]]
   info=create_struct('stat1',stat1)
   return
endif

if str.sh le 8960 then bit='DATA' ELSE BIT='WAVEFORMS'
flc0=mdsvaluestr(str,'.DAQ.'+bit+':FLC_0',/open)
flc1=mdsvaluestr(str,'.DAQ.'+bit+':FLC_1')

if n_elements(flc0.t) lt 10 then begin
   flc0={t:'*',v:'*'}
endif


if size(flc0.t,/type) ne 7 then begin
;   flc0.t-=flc0.t(0)
   flc0.t+=str.t0proper
endif

if size(flc0.t,/type) ne 7 then             begin
;   flc1.t-=flc1.t(0)
   flc1.t+=str.t0proper
endif

flc0mark=fix(mdsvaluestr(str,'.MSE.FLC.FLC__00:MARK',/flat))
flc0space=fix(mdsvaluestr(str,'.MSE.FLC.FLC__00:SPACE',/flat))
flc0invert=(mdsvaluestr(str,'.MSE.FLC.FLC__00:INVERT',/flat,/close)) eq 'True'

flc0per_orig=str.flc0per

;stop
if (str.flc0per eq 999) or (str.flc0per eq 9999) or (str.flc0per eq 1999) then begin
   str.flc0per=flc0mark+flc0space
   str.flc0mark=flc0mark
;               str.flc0t0=0
;stop
;   str.flc0invert=1-flc0invert ; ! invert to be consistent with definition in cs
   str.flc0invert=flc0invert ; ! invert to be consistent with definition in csv file
endif

ifr=indgen(str.nfr)

;999 makes it interpolate signa, 9999 makes it hard coded on db values
if size(flc0.t,/type) eq 7 or flc0per_orig ne 999 then begin
   ifr2=ifr+str.nskip
   stat1=[[((ifr2 - str.flc0t0) mod str.flc0per) / (str.flc0mark eq 0 ? str.flc0per/2 : str.flc0mark)], [((ifr2-str.flc1t0) mod str.flc1per) / (str.flc1mark eq 0 ? str.flc1per/2 : str.flc1mark)]] ne 0
   idx=where(ifr gt str.flc0endt)

   if str.flc0invert eq 1 then stat1=1-stat1
   if idx(0) ne -1 then stat1(idx,*) = str.flc0endstate

endif else begin
   tfr=str.t0+str.dt*ifr+ str.dt * 0.1
   if (min(tfr) lt min(flc0.t)) or $
      (max(tfr) gt max(flc0.t)) then begin
      print,'warning extrapolatinon of flc signal required'
;               stop
   endif
   flc0i1=interpol(flc0.v,flc0.t,tfr)
;           plot,flc0.t,flc0.v,xr=[0,2]
   stat1a=1-fix((flc0i1+5)/10.)
;            oplot,tfr,stat1a,psym=4,col=2
   stat1=[[stat1a],[stat1a*0]]

endelse


info=create_struct('flc0',flc0,'flc1',flc1,'flc0mark',flc0mark,'flc0space',flc0space,'flc0invert',flc0invert,'stat1',stat1)

            
            
end
