pro compare_filters,filter1,filter2,cwl=cwl,angle=angle

default,cwl,661.
default,angle,0.
default,filter1,'Materion_V3.dat'
default,filter2,'BES_2011.dat'

d = loadncol(filter1,head=2,text=head,errormess=errormess,/silent)
if (errormess ne '') then begin
  print,errormess
  return
endif
txt = strsplit(strcompress(head[1]),' ',/extract)
angles1 = float(txt[1:n_elements(txt)-1])
w1 = d[*,0]
n_angle1 = (size(d))[2]-1
p1 = d[*,1:n_angle1]
maxw = w1[(where(p1[*,0] eq max(p1[*,0])))[0]]
ind = where((w1 ge maxw-4.) and (w1 le maxw+4.))
cwl = total(w1[ind]*p1[ind,0])/total(p1[ind,0])
; Shifting to actual CWL
default,cwl_new,cwl
w1 = w1+(cwl_new-cwl)

d = loadncol(filter2,head=2,text=head,errormess=errormess,/silent)
if (errormess ne '') then begin
  print,errormess
  return
endif
txt = strsplit(strcompress(head[1]),' ',/extract)
angles2 = float(txt[1:n_elements(txt)-1])
w2 = d[*,0]
n_angle2 = (size(d))[2]-1
p2 = d[*,1:n_angle2]
maxw = w2[(where(p2[*,0] eq max(p2[*,0])))[0]]
ind = where((w2 ge maxw-4.) and (w2 le maxw+4.))
cwl = total(w2[ind]*p2[ind,0])/total(p2[ind,0])
; Shifting to actual CWL
default,cwl_new,cwl
w2 = w2+(cwl_new-cwl)

; Interpolating to required angle
ind1 = where(angle ge angles1)
ind1 = ind1[n_elements(ind1)-1]
if (ind1 eq n_elements(angles1)-1) then begin
  print,'Warning: extrapolating filter angle data.'
  stop
  ind2 = ind1
  ind1 = ind1-1
endif else begin
  ind2 = ind1+1
endelse
p1_act = p1[*,ind1]+(p1[*,ind2]-p1[*,ind1])*(angle-angles1[ind1])/(angles1[ind2]-angles1[ind1])

; Interpolating to required angle
ind1 = where(angle ge angles2)
ind1 = ind1[n_elements(ind1)-1]
if (ind1 eq n_elements(angles2)-1) then begin
  print,'Warning: extrapolating filter angle data.'
  stop
  ind2 = ind1
  ind1 = ind1-1
endif else begin
  ind2 = ind1+1
endelse
p2_act = p2[*,ind1]+(p2[*,ind2]-p2[*,ind1])*(angle-angles2[ind1])/(angles2[ind2]-angles2[ind1])


if (not keyword_set(over)) then begin
  plot,w1,p1_act,xrange=xrange,xstyle=1,xtitle='Wavelength [nm]',ytitle='Transmission [%]',$
    yrange=[0,105],ystyle=1,title=filter1+'-'+filter2+'  Angle:'+i2str(angle)
endif else begin
  oplot,w2,p2_act,linestyle=2
endelse

end