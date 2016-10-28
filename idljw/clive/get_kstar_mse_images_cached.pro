function get_kstar_mse_images_cached, shotno, nx, ny, n_im, tree=tree, snap=snap, cal=cal, time=time, camera=camera
common cbstore,sharr,darr,cnt
if n_elements(sharr) eq 0 then begin
    nmax=100
    sharr=fltarr(nmax)
    darr=ptrarr(nmax)
    cnt=0
endif

for i=0,cnt-1 do begin
    if (*darr(i)).shotno eq shotno then begin
        d=(*darr(i)).d
        nx=(*darr(i)).nx
        ny=(*darr(i)).ny
        n_im=(*darr(i)).n_im
;        snap=(*darr(i)).snap
;        cal=(*darr(i)).cal
        time=(*darr(i)).time
        camera=(*darr(i)).camera
        print,'got images from cache for shotno',shotno
        return,d
    endif
endfor

d=get_kstar_mse_images( shotno, nx, ny, n_im, tree=tree, snap=snap, cal=cal, time=time, camera=camera)
dat={d:d,nx:nx,ny:ny,n_im:n_im,tree:tree,time:time,camera:camera,shotno:shotno};snap:snap
darr(cnt)=ptr_new(dat)
cnt=cnt+1

return,d
end

