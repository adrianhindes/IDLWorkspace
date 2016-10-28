pro analyse_pol_vel, shot, timerange, rad_chan=rad_chan, tau=tau, ps=ps, winsize=winsize, user=user
  
  default, shot, 6352
  default, timerange, [2.377,2.635]
  default, rad_chan, 6
  default, tau, 100e-6
  default, winsize, 1e-3
  default, user, 'lampee'
  if user eq 'lampee' then cd, 'D:\KFKI\Measurements\KSTAR\Measurement'
  n=round((timerange[1]-timerange[0])/winsize)
  
  ;*************************************
;*      calculate the velocity       *
;*************************************
;
; For the velocity calculation, one needs the time shift of each pixel for the vertical pixel array
; this could be gathered from the correlation by calculating the maximum of the correlation function
; and knowing the place of each detector pixel, it iw easy to calculate the velocity with linear regression.

  if keyword_set(ps) then hardon, /color
  
    timeshift=dblarr(n)
    v=dblarr(n)
    t=dblarr(n)
    detpos=getcal_kstar_spat(shot, /xyz)
    for i=0,n-1 do begin
        time_range=[timerange[0]+i*winsize,timerange[0]+(i+1)*winsize]
        for j=0,2 do begin
          plotchan='BES-1-'+strtrim(rad_chan,2)
          refchan='BES-'+strtrim(j+2,2)+'-'+strtrim(rad_chan,2)
  
          fluc_correlation, shot2, timerange=time_range, refchan=refchan, plotchan=plotchan, frange=frange, /plot_correlation, $
                          outcorr=outcorr, outtime=outtime, /noplot, /silent, /nocalibrate
          
          outcorr2=outcorr[where(outtime lt tau and outtime gt -tau)]
          outtime2=outtime[where(outtime lt tau and outtime gt -tau)]
          
          a=max(outcorr2,k)
          timeshift[i,1,j+1]=outtime2[k]*1e-6
          timeshift[i,1,j+1]=distance(detpos[j+1,rad_chan-1,*],detpos[0,rad_chan-1,*])*1e-3
          if not keyword_set(noplot) then begin
            plot, outtime, outcorr
            oplot, [outtime2[k],outtime2[k]], [-1e15,1e15]
            if not keyword_set(ps) then cursor, x,y, /down
            print, outtime[k]
            print, distance(detpos[j+1,rad_chan-1,*],detpos[0,rad_chan-1,*])
          endif
        endfor
        ;calculate the velocity with linear regression
        v[i]=(total(timeshift[i,0,*]*timeshift[i,1,*])-4*mean(timeshift[i,0,*])*mean(timeshift[i,1,*]))/$
             (total((timeshift[i,0,*])^2)-4*mean(timeshift[i,0,*])^2)
        t[i]=timerange[0]+(i+0.5)*winsize
    endfor
    ;v=v[where(v gt -8*1e3)]
    
    if keyword_set(ps) then begin
      thick=3
      xc=0.01
      cs=2
    endif else begin
      xc=0.01
      cs=1
    endelse
    
    plot, findgen(n),v/1.e3, ytitle='Velocity [km/s]', xtitle='ELM event index', thick=thick, $
          xcharsize=cs, ycharsize=cs, /noerase, psym=4
          
    if keyword_set(ps) then hardfile, filename+'.ps'
  
  
end