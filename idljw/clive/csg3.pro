function mean, s
return, (total(s)/float(n_elements(s)))
end
function dynrangem, f,n,mn=mn,ignorezero=ignorezero,el=el,eu=eu,ss=st,usess=usess
default,el,1
default,eu,1

idx=where(finite(f) eq 1)
if keyword_set(ignorezero) then begin
	idx2=where(f(idx) ne ignorezero)
	idx3=idx(idx2)
	idx=idx3
endif

mn=mean(f(idx))
if not keyword_set(usess) then st=stdev(f(idx))
if n_elements(n) eq 0 then return, [mn-el*st,mn+eu*st] else return, [mn-st,mn+st,n]
end

function logclipm, x,el=el,eu=eu,ss=ss,usess=usess,dshift=dshift
lx=alog10(x>0)
default,dshift,0.
dr=dynrangem(lx,el=el,eu=eu,ss=ss,usess=usess)
dr=dr+dshift
print, 'dynamic range is',dr(1)-dr(0)
rv=lx>dr(0)<dr(1) 

return,rv
end


pro csg3,dat,tw=tw,dt=dt,t0=t0,el=el,eu=eu,npw=npw,fmax=fmax,olap=olap,$
         han=han,ntk=ntk,nl=nl,ss=ss,usess=usess,dshift=dshift,$
         _extra=_extra
default,el,1.
default,eu,3.
;@math_startup
;@stat_startup
;@sigpro_startup

common dpcib, d1, d2

if n_elements(dat) eq 0 then dat=d2(*,7)
sz=size(dat,/dim)
nt=sz(0)
default,dt,1.e-6
default,t0,0.
t=findgen(nt)*dt+t0
default,npw,512
default,tw,[min(t),max(t)];3.75];1.05,1.1]

;default,tw,[5156,5256]*128.*1.e-6

dummy=min(abs(tw(0)-t),imin)
dummy=min(abs(tw(1)-t),imax)

default,olap,0

dbw=npw-olap

ntw=round(imax-imin)/(dbw)
i0=imin
s=fltarr(ntw,npw)
tt=fltarr(ntw)
if keyword_set(han) then win=hanning(npw) else win=replicate(1.,npw)

for i=0L,ntw-1 do begin
    s(i,*)=abs(fft(win*dat(i0+i*dbw:i0+i*dbw+npw-1),-1))^2
    tt(i)=t(i0+i*dbw)
endfor
f=findgen(npw)/float(npw) * 1/dt
s=s(*,0:npw/2-1)
f=f(0:npw/2-1)


;tvscl,alog10(s>1e-4)
;mkfig,'c:\talk\sg3.eps'
;device,ysize=25,xsize=15
;!p.multi=[0,1,2]

default,fmax,1./2./dt
ls=logclipm(s,el=el,eu=eu,ss=ss,usess=usess,dshift=dshift)
ix=where(f lt fmax)
f=f(ix)
ls=ls(*,ix)
default,ntk,6
nt=n_elements(tt)
nf=n_elements(f)
ntmax=200
nfmax=100
st=floor(nt/ntmax) > 1
sf=floor(nf/nfmax) > 1
ls=smooth2(ls,st,sf)
it2=findgen(nt/st)*st # replicate(1,nf/sf)
iff2=replicate(1,nt/st) # findgen(nf/sf)*sf
it=findgen(nt/st)*st
iff=findgen(nf/sf)*sf
ls=ls(it2,iff2)
tt=tt(it)
f=f(iff)

;stop;
default,nl,10

contour,ls,tt,f/1e3,nl=nl,/fill,c_col=linspace(32,255,nl),_extra=_extra
;contourn2,ls,tt,f/1e3,nl=10,/nonice,/nicedefs,_extra=_extra
;cdatr,z,t,r,rref
;plot,t,z(*,23),xr=tw,xsty=1,ysty=1,xtitle='t (s)',ytitle='n_e',title='CO2 lin av. density, R=4.13m'
;endfig


end
