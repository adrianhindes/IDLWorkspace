pro show_kstar_bes_mean_power,shot,timerange=timerange,channels=channels,timefile=timefile,$
   fres=fres,frange=frange,savefile=savefile,nocalibrate=nocalibrate,nocalculate=nocalculate,$
   xtype=xtype,ytype=ytype,ftype=ftype,yrange=yrange,over=over,thick=thick

default,savefile,i2str(shot)+'_all_power.sav'
default,ftype,1
default,frange,[1e3,1e6]
default,fres,1e2
default,ytype,1
default,xtype,1
default,nocalibrate,1

if (not defined(channels)) then begin
  channels = strarr(32)
  for i=1,8 do begin
   for j=1,4 do begin
       channels[i-1+(j-1)*8] = 'BES-'+i2str(j)+'-'+i2str(i)
    endfor
  endfor
endif

if (not keyword_set(nocalculate)) then begin
  nch = n_elements(channels)
  for i=0,nch-1 do begin
    print,i2str(i+1)+'/'+i2str(nch)
    wait,0.1
    fluc_correlation,shot,timefile,timerange=timerange,fres=fres,frange=frange,ref=channels[i],$
      outfscale=f,outpower=p,outpwscat=ps,errormess=e,nocalibrate=nocalibrate,/noplot,/plot_power,ftype=ftype,/silent
    if (e ne '') then begin
      print,e
      return
    endif
    if (i eq 0) then begin
      ptot = p
      ps2tot = ps^2
      fscale = f
    endif else begin
      ptot = ptot+p
      ps2tot = ps2tot+ps^2
    endelse
  endfor
  save,shot,frange,fres,timerange,timefile,channels,ptot,ps2tot,fscale,file=dir_f_name('tmp',savefile)
endif else begin
  if (defined(frange)) then frange_save = frange
  if (defined(fres)) then fres_save = fres
  restore,dir_f_name('tmp',savefile)
endelse

if (not keyword_set(over)) then begin
  plot,fscale,ptot/n_elements(channels),xtype=xtype,ytype=ytype,yrange=yrange,xrange=frange,xstyle=1,ystyle=1,$
    xtitle='Frequency [Hz]',ytitle='Power [a.u.]',thick=thick
endif else begin
  oplot,fscale,ptot/n_elements(channels),thick=thick
endelse
err = sqrt(ps2tot/n_elements(channels))
errplot,fscale,ptot/n_elements(channels)-err,ptot/n_elements(channels)+err,thick=thick
end
