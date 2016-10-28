;path='/data/kstar/pmt_romana/mar2014/03_03_2014/scan2/'
path='/data/kstar/pmt_romana/feb2014/28_02_2014/scan4/'
tdms_get_pmt_all,data=d,ch=ch,ig=0,file='12.tdms',path=path
fdig=600e3
nt=n_elements(d(*,0))
t=findgen(nt) * 1/fdig
nch=16
idx=where(t+0. ge 0.2)

f=fft_t_to_f(t(idx))
n2=n_elements(idx)
s=complexarr(n2,nch)
ps=fltarr(n2,nch)
nsm=30
nsm2=3
ps2=ps
for i=0,nch-1 do s(*,i)=fft(d(idx,i)-mean(d(idx,i)))
for i=0,nch-1 do ps(*,i)=smooth(abs(s(*,i))^2,nsm,/edge_wrap)
for i=0,nch-1 do ps2(*,i)=smooth(abs(s(*,i))^2,nsm2,/edge_wrap)

chi=findgen(16)
imgplot,d,t,chi,/cb,pos=posarr(2,2,0)

as=alog10(ps)
imgplot,as,f,chi,/cb,zr=[-8,-6],xr=[0,300e3],pos=posarr(/next),/noer

plot,f,ps2(*,7),/ylog,/xlog,xr=[1,1e5],pos=posarr(/next),/noer
plot,f,ps(*,7),/ylog,xr=[1,1e5],pos=posarr(/next),/noer

end
