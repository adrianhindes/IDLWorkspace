function posarr, nx_p,ny_p,i_p,cnx=cnx_p,cny=cny_p,msratx=msratx_p,msraty=msraty_p,titlepos=titlepos,rev=rev_p,fx=fx_p,fy=fy_p,next=next,current=current,quiet=quiet
default,cnx_p,0.05
default,cny_p,0.05
default,fx_p,0.
default,fy_p,0.
;;; note first 3 pars must be integer!!!!!!!!!
if n_elements(nx_p) ne 0 then if nx_p gt 1 then default, msratx_p,5. else default,msratx_p,1e9
if n_elements(nx_p) ne 0 then if ny_p gt 1 then default, msraty_p,5. else default,msraty_p,1e9

common parrb, cnx,cny,fx,fy,msratx,msraty,nx,ny,i,rev
if not (keyword_set(next) or keyword_set(current) ) then begin
    cnx=cnx_p
    cny=cny_p
    fx=fx_p
    fy=fy_p
    nx=nx_p
    ny=ny_p
    msratx=msratx_p
    msraty=msraty_p
    rev=keyword_set(rev_p)
    i=i_p
endif else if keyword_set(next) then i=i+1

wdy=(1-2*cny)/ny
wdx=(1-2*cnx)/nx

iy = (i)/nx
iy=ny-1-iy
ix = (i) mod nx

if rev eq 1 then begin
    iy = i mod ny
    iy=ny-1-iy
    ix = (i) / ny
endif
if not keyword_set(quiet) then print,i,ix,iy

;print,iy
;stop
ox = cnx*(1+fx)+ float(ix*msratx)/float(nx*msratx-1) * (1-2*cnx)
oy = cny*(1+fy)+ float(iy*msraty)/float(ny*(msraty)-1) * (1-2*cny)
wx = 1./nx * (msratx-1)/msratx * (1-2*cnx)
wy = 1./ny * (msraty-1)/msraty * (1-2*cny)


return, [ox,oy,ox+wx,oy+wy]
end

