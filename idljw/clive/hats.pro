function hats, th0, thw, ang,set=set,doplot=doplot
if set.type eq 'hat' then rval1= ang gt th0-thw/2 and ang lt th0+thw/2
if set.type eq 'cos' then rval1=cos(!pi/2 * (ang - th0) / thw)
if set.type eq 'hanning' then rval1=[hanning(n_elements(ang)-1),0]
if set.type eq 'sg' then rval1 = exp( - ((ang - th0)/thw*set.sgmul)^set.sgexp)
if set.type eq 'sghat' then rval1 = exp( - ((ang - th0)/thw*set.sgmul)^set.sgexp) * ( ang gt th0-thw/2 and ang lt th0+thw/2)
if set.type eq 'none' then rval1=ang*0. + 1
if keyword_set(doplot) then begin
    plot,ang,rval1
    stop
endif
return,rval1
end
