pro show_ft,shot,signal,trange=trange,tres=tres,data_source=data_source,afs=afs,cdrom=cdrom,$
frange=frange,fres=fres,errormess=errormess,title=title,nocalibrate=nocalibrate

errormess = ''

default,frange,[0,1e5]
default,fres,2e3
default,trange,[0,1]
default,tres,0.01

get_rawsignal,shot,signal,t,d,errormess=errormess,data_source=data_source,afs=afs,$
       cdrom=cdrom,trange=trange,sampletime=sampletime,nocalibrate=nocalibrate


if (errormess ne '') then return


n_t = (trange[1]-trange[0])/tres

for i=0,n_t-1 do begin
    ind = where((t ge trange[0]+tres*i) and (t le trange[0]+tres*(i+1)))
    if (ind(0) lt 0) then begin
       errormess = 'No data in time interval: '+string(trange[0]+tres*i,format='(F6.4)')+$
                    '-'+string(trange[0]+tres*(i+1),format='(F6.4)')
       print,errormess
       return
    endif
    s = d(ind)

    if (i eq 0) then begin
       pointlist = long(2)^lindgen(24)
       np = pointlist[(where(pointlist gt n_elements(s)*1.2))[0]]
       fres_int = 1/(sampletime*np)
       sm_length = long(fres/fres_int)
       if ((sm_length mod 2) eq 0) then sm_length = sm_length+1
       fres = fres_int/sm_length
       fscale_int = findgen(np/2)*fres_int
       if (sm_length gt 1) then fscale = smooth(fscale_int,sm_length) else fscale=fscale_int
       ind_data = lindgen(n_elements(fscale)/sm_length)*sm_length+fix(sm_length/2)
       ind_data = ind_data[where((fscale(ind_data) ge frange[0]) and (fscale(ind_data) le frange[1]))]
       fscale = fscale[ind_data]
       n_f = n_elements(fscale)
       ft = fltarr(n_t,n_f)
    endif

    sf = fltarr(np)
    sf[(np-n_elements(ind))/2:(np-n_elements(ind))/2+n_elements(ind)-1] = s


    p = fft(sf,-1)
    p = p*conj(p)
    p = float(p)
    p = p[0:np/2-1]
    if (sm_length gt 1) then p = smooth(p,sm_length)
    p = p[ind_data]


    ft[i,*] = float(p)


endfor
nf = n_elements(fscale)
frange = [fscale[0]-float(fscale[1]-fscale[0])/2,fscale[nf-1]+float(fscale[nf-1]-fscale[nf-2])/2]
default,title,i2str(shot)+'  '+signal
plot,trange,frange,/nodata,xrange=trange+[-tres/2,tres/2],xstyle=1,$
    yrange=frange+[-fres,fres],ystyle=1,xtitle='Time [s]',ytitle='Frequency [Hz]',title=title
otv,ft/max(ft)*(!d.n_colors < 256),/inter


end
