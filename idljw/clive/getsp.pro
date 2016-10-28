function getsp, n
path='/data/kstar/misc/sp_quad/'
fil='cal'+string(n,format='(I0)')
d=read_ascii(path+fil)
z=d.(0)
return,z

end

pro pat, f,l,d
f1=getsp(f)
l1=getsp(l)
d1=getsp(d)
f1-=d1
l1-=d1
rat=f1/l1
idx=where(finite(rat) eq 0)
if idx(0) ne -1 then rat(idx)=0.
plot,rat,yr=[0,1],pos=posarr(2,1,0)
plot,abs(fft(rat)),/ylog,/noer,pos=posarr(/next),xr=[0,80]

end
