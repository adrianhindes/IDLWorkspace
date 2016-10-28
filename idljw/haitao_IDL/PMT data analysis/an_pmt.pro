;path='/data/kstar/pmt_romana/mar2014/03_03_2014/scan2/'
path='z:\pmt_romana\feb2014\28_02_2014\scan5\'
print,file_search(path+'10.tdms')
;stop

tdms_get_pmt_all,data=d,ch=ch,ig=0,file='10.tdms',path=path

fdig=600e3
nt=n_elements(d(*,0))
t=findgen(nt) * 1/fdig
nch=16
idx=where(t+0. ge 0.2)

f=findgen(nt)/(t(1)-t(0))/nt    ;fft_t_to_f(t(idx))
n2=n_elements(idx)
s=complexarr(n2,nch)
ps=fltarr(n2,nch)
nsm=30
for i=0,nch-1 do s(*,i)=fft(d(idx,i))
for i=0,nch-1 do ps(*,i)=smooth(abs(s(*,i))^2,nsm)

chi=findgen(16)
;imgplot,d,t,chi,/cb
as=alog10(ps)
imgplot,as,f,chi,/cb,zr=[-8,-6],xr=[0,300e3]
;plot,ps(*,7),/ylog,/xlog,xr=[1,1e5]

end
