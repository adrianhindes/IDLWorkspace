pro find_apdcam_shift,shot,data_source=data_source,chn=chn,shift_sample=shift_sample,$
   timerange=timerange,timefile=timefile,fitlen=fitlen,channel_list=channel_list

default,chn,64
default,fitlen,100
default,channel_list,[1,2,3,4,5,13,14,15,16,18,19,20,28,9,30,31,32,37,38,39,40,41,42,43,44,49,53,54,55,56,57,58,59,60]

n_adc = fix(chn/32)
default,data_source,32
if (data_source eq 32) then begin
  ; KSTAR BES
  prefix = 'BES-ADC'
endif

if (defined(timefile)) then begin
  d = loadncol(dir_f_name('time',timefile),2)
  timerange_read = [min(d),max(d)]
endif else begin
  timerange_read = timerange
endelse
for i_adc=0,n_adc-1 do begin
  for i_ch = 0,7 do begin
    ind = where(channel_list eq i_adc*32+i_ch+1)
    if (ind[0] lt 0) then continue
    get_rawsignal,shot,prefix+i2str(i_adc*32+i_ch+1),t,d,errormess=e,data_source=data_source,sampletime=sampletime,timerange=timerange_read
    if (e ne '') then begin
      print,e
      return
    endif
    if (not defined(refsignal)) then begin
      refsignal = d
      delete,d
    endif else begin
      refisgnal = refsignal+d
      delete,d
    endelse
  endfor
endfor

signal_cache_add,name='refsignal',data=refsignal,start=t[0],sampletime=sampletime,errormess=e
if (e ne '') then begin
  print,e
  return
endif

shift_sample = intarr(chn/8)

for i_block=0,chn/8-1 do begin
  if (i_block eq 0) then continue
  blocksignal = 0
  for i_ch = 0,7 do begin
    ind = where(channel_list eq i_block*8+i_ch+1)
    if (ind[0] lt 0) then continue
    get_rawsignal,shot,prefix+i2str(i_block*8+i_ch+1),t,d,errormess=e,data_source=data_source,sampletime=sampletime,timerange=timerange_read
    if (e ne '') then begin
      print,e
      return
    endif
    if (n_elements(blocksignal) lt 2) then begin
      blocksignal = d
      delete,d
    endif else begin
      blocksignal = blocksignal+d
      delete,d
    endelse
  endfor

  signal_cache_add,name='blocksignal',data=blocksignal,start=t[0],sampletime=sampletime,errormess=e
  if (e ne '') then begin
    print,e
    return
  endif


  fluc_correlation,0,timefile,timerange=timerange,ref='cache/refsignal',plotch='cache/blocksignal',$
    taurange=[-1.,1.]*2000*sampletime/1e-6,outcorr=c,outtime=t,errormess=e,/silent,/noerror,interv=1
  if (e ne '') then begin
    print,e
    return
  endif
  plot,t,c,ystyle=1,title='Block '+i2str(i_block+1)
  ind = where(c eq max(c))
  tmax = t[ind[0]]
  ind1 = where(((t-tmax) gt -fitlen) and (t-tmax lt -20))
  t1 = t[ind1]
  c1 = c[ind1]
  p1 = poly_fit(t1,c1,1)
  cc1 = p1[0]+t*p1[1]
  oplot,t,cc1
  ind2 = where(((t-tmax) gt 20) and (t-tmax lt fitlen))
  t2 = t[ind2]
  c2 = c[ind2]
  p2 = poly_fit(t2,c2,1)
  cc2 = p2[0]+t*p2[1]
  oplot,t,cc2
  tmax1 = (p1[0]-p2[0])/(p2[1]-p1[1])
  print,'Block '+i2str(i_block+1)+': '+string(tmax1,format='(F6.2)')
  wait,0.1
  shift_sample[i_block] = round(tmax1/(sampletime/1e-6))

endfor
print,shift_sample


end