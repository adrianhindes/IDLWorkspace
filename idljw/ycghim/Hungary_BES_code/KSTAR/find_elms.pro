pro find_elms, shot, timerange, flow=flow, fhigh=fhigh, thres=thres, error=error

;************************************************
;*                  find_elms
;************************************************
;* The routine plots the data, where a certain  *
;* interval has to be defined. After that a     *
;* window goes from the beginning to the end of *
;* the time interval. Where there is an ELM, one*
;* has to click on the maximum.                 *
;************************************************

cd, 'C:\Users\lampee\KFKI\Measurements\KSTAR\Measurement'
restore, 'elmdatabase.sav'

save, database, filename='elmdatabase.bak.sav'
default,flow,30. ;cutoff frequency of the filter of the halfa signal
default,fhigh,500.
get_rawsignal, shot, '\TOR_HA09', /store
if not defined(timerange) then begin
  show_rawsignal, shot, '\TOR_HA09'
  print, 'Click on the beginning and on the end of the time interval!'
  cursor, t1,y, /down
  cursor, t2,y, /down
  print, t1, t2
endif else begin
  t1=timerange[0]
  t2=timerange[1]
endelse

get_rawsignal, shot, '\TOR_HA09',time,datatemp, timerange=[t1,t2]
;a high pass filtering has to be made for accurate ELM find [fcutoff=10Hz]
tres=time[1]-time[0]
nwin1=round(1./(tres*flow))
data2=dblarr(n_elements(datatemp))
for i=0l, n_elements(datatemp)-1-nwin1 do begin
  data2[i]=datatemp[i]-total(datatemp[i:i+nwin1])/double((nwin1+1))
endfor
print, total(data2)
;a low pass filter is also applied (smoothing)
nwin2=round(1./(tres*fhigh))
data=dblarr(n_elements(datatemp))
for i=0l, n_elements(datatemp)-1-nwin2 do begin
  data[i]=total(data2[i:i+nwin2])/double((nwin2+1))
endfor
if not (defined(thres)) then begin
  plot, time, data
  print, 'Click on the threshold value!'
  cursor, x,thres, /down
  print, thres
endif
data2=data
data[where(data lt thres)]=0

k=0
while (n_elements(where(data eq 0)) ne n_elements(data)) do begin
  timevec=dblarr(k+1)
  if (k ge 1) then timevec[0:n_elements(timevec)-2]=temp
  a=max(data,j)
  if j eq 0 then l=0 else l=j-1
  if j eq n_elements(data) then m=j else m=(j+1)
  data[j]=0
  while (data[l] ne 0) do begin
    data[l]=0
    l=l-1
    if (l eq 0) then break
  endwhile
  while (data[m] ne 0) do begin
    data[m]=0
    m=m+1
    if (m eq n_elements(data)) then break
  endwhile
  timevec[k]=time[j]
  ;maxdvec[where((maxtvec gt timevec[k]-twin) and (maxtvec lt timevec[k]+twin))]=0
  temp=timevec
  k=k+1
endwhile

aa=sort(timevec)
timevec=timevec[aa]
print, timevec
nt=n_elements(timevec)
xv=dblarr(nt)
for i=0,nt-1 do begin
  a=min(abs(time-timevec[i]),j)
  xv[i]=data2[j]
endfor

device, decomposed=0
loadct, 5
plots, timevec, xv, psym=5, color=200, thick=2
oplot, [-1000,1000],[thres,thres], color=100
read, 'Does it seem right? (n:0, y:1)',bl
if not (bl) then begin
  print, 'Try again. Returning...'
  error=1
endif else begin
  for i=0, n_elements(timevec)-1 do begin
    database_new_rec, shot, timevec[i], database
  endfor
  print, 'Saving database...'
  save, database, filename='elmdatabase.sav'
endelse
end