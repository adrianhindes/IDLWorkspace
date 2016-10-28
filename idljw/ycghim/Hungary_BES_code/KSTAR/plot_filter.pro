pro plot_filter,filter,cwl=cwl_new,angle=angle,linestyle=linestyle,xrange=xrange,$
  norm=norm,over=over,ytype=ytype,yrange=yrange,equation=equation,refr_index=refr_index,$
  thick=thick,charsize=charsize,title=title

;Plot the filter transmission curve at a certain angle
; /equation: Use equation from Andover website for angle shift
; refr_index: Refrective index for angle sensitivity

default,cwl_new,661.
default,angle,0.
default,filter,'Materion_V3.dat'
default,refr_index,2.08

d = loadncol(filter,head=2,text=head,errormess=errormess,/silent)
if (errormess ne '') then begin
  print,errormess
  return
endif
txt = strsplit(strcompress(head[1]),' ',/extract)
angles1 = float(txt[1:n_elements(txt)-1])
w1 = d[*,0]
n_angle1 = (size(d))[2]-1
p1 = d[*,1:n_angle1]
if (keyword_set(norm)) then p1 = p1/max(p1)*100
maxw = w1[(where(p1[*,0] eq max(p1[*,0])))[0]]
ind = where((w1 ge maxw-4.) and (w1 le maxw+4.))
cwl = total(w1[ind]*p1[ind,0])/total(p1[ind,0])
; Shifting to actual CWL
default,cwl_new,cwl
w1 = w1+(cwl_new-cwl)

if (not keyword_set(equation)) then begin
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
endif else begin
  w1 = w1*sqrt(1-(1./refr_index)^2*sin(angle/180.*!pi)^2)
  p1_act = p1
endelse

if (not keyword_set(over)) then begin
  default,title,filter+'  Angle:'+i2str(angle)
  default,yrange,[0,105]
  if (keyword_set(norm)) then ytitle='Normalized transmission [%]' else ytitle='Transmission [%]'
  plot,w1,p1_act,xrange=xrange,xstyle=1,xtitle='Wavelength [nm]',ytitle=ytitle,$
    yrange=yrange,ystyle=1,title=title,ytype=ytype,thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize
endif else begin
  oplot,w1,p1_act,linestyle=linestyle,thick=thick
endelse

end