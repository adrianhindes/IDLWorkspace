pro pulses_vs_limit,shot,chlist,timerange=timerange,thick=thick,datapath=datapath,data_source=data_source,limits=limits
;*********************************************************************
;* PULSES_VS_LIMIT.PRO                S. Zoletnik 2011               *
;*********************************************************************
;* Test program for FILTER_RADIATION_PULSES                          *
;* Plots the number of pulses cut as a function of the limit.        *
;*********************************************************************
default,shot,115424
default,chlist,'BES-'+strcompress(string(indgen(14)+2,format='(I2)'),/remove_all)
default,timerange,[1,2]
default,thick,1
default,data_source,local_default('data_source')
default,charsize,0.5
default,symsize,0.5

;limits = [0.025,0.03,0.035,0.04,0.045,0.05,0.06,0.07,0.08,0.1,0.12,0.14,0.16,0.18,0.2,0.3,0.4,0.8]
default,limits,[0.001,0.0025,0.005,0.01,0.015,0.02,0.025,0.03,0.035,0.04,0.045,0.05,0.06,0.07,0.08,0.1,0.12,0.14,0.16,0.18,0.2,0.3,0.4,0.8]
n_limits = n_elements(limits)
n_ch = n_elements(chlist)

erase
time_legend,'pulses_vs_limit.pro'
n_column = fix(sqrt(n_ch))
n_row = float(n_ch)/n_column
if (n_row mod 1) eq 0 then begin
  n_row = fix(n_row) 
endif  else begin
  n_row = fix(n_row)+1
endelse  
for ich=0,n_ch-1 do begin
  print,chlist[ich]
  wait,0.1
  get_rawsignal,shot,chlist[ich],trange=timerange,t,d,errormess=e,datapath=datapath,filter_radiaton_pulses=0,/nocalib
  if (e ne '') then return
  np = fltarr(n_limits)
  for i=0,n_limits-1 do begin
    d1 = d
    filter_radiation_pulses,d1,limit=limits[i],n_p=n,data_source=data_source
    np[i] = n
  endfor
  plotsymbol,0
  np = np > 0.5
  ystep = 0.94/n_row
  xstep = 0.94/n_column
  if (ich/n_column eq 0) then begin
    xtitle = 'Limit'
    xtickname = ' '
  endif else begin
    xtitle = ''
    xtickname = strarr(20)+' '
  endelse  
  pos = [0.03+(ich mod n_column)*xstep,0.03+(ich/n_column)*ystep,0.03+((ich mod n_column)+0.65)*xstep,0.03+(ich/n_column+0.65)*ystep]
  plot,limits,np,psym=8,xtitle=xtitle,xtickname=xtickname,xtype=1,ytitle='N of peaks cut',yrange=[0.5,max(np)*2],ystyle=1,ytype=1,$
     title=chlist[ich],$
    /noerase,pos=pos,charsize=charsize,thick=thick,xthick=thick,ythick=thick,charthick=thick,symsize=symsize
  wait,0.1
endfor

xyouts,0.1,0.98,/normal,'Shot: '+i2str(shot)+'  Timerange=['+string(timerange[0],format='(F6.3)')+','+string(timerange[1],format='(F6.3)')+']',charthick=thick
end
