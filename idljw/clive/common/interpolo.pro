function interpolo,v,x,u,outside=outside,oval=oval
idx1=where(u gt max(x,imax))
idx2=where(u lt min(x,imin))
r=interpol(v,x,u)
if keyword_set(outside) then begin
    v1=outside
    v2=outside
endif else begin
    v1=v(imax)
    v2=v(imin)
endelse
if keyword_set(oval) then begin
    v1=oval
    v2=oval
endif

if idx1(0) ne -1 then r(idx1)=v1
if idx2(0) ne -1 then r(idx2)=v2
return,r
end
