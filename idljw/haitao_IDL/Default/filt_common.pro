;pro mk5b
;x=[-3.85,-1.95,-1.65,-1.25,-1.,         -.85,        0] / 5.
;y=[-2.,   -1.,  0.,   1.,   alog10(0.5)+2, alog10(.9)+2, 2.]
;save,x,y,file='~/Filter_type_5b.sav',/verb
;end


pro mk4b
; 4 cavity andover from oriel website table, narrowest
x=[-9,  -3.5,    -2,  -1.5, -1.1, -1.,         -.9,        0] / 5.
y=[-3., -2. ,   -1.,    0.,   1.,    alog10(0.5)+2, alog10(.9)+2, 2.]
save,x,y,file='~/Filter_type_4b.sav',/verb
end

pro mk4c
; 4 cavity andover from oriel website table, widest values
x=[-12, -4.25,-2.25,  -1.8, -1.3, -1.,         -.85,        0] / 5.
y=[-3., -2. ,   -1.,    0.,   1.,    alog10(0.5)+2, alog10(.9)+2, 2.]
save,x,y,file='~/Filter_type_4c.sav',/verb
end


pro mk5b
; 5 cavity andover from oriel website table, narrowest
x=[-8,  -3.1,    -2,  -1.5, -1.1, -1.,         -.9,        0] / 5.
y=[-3., -2. ,   -1.,    0.,   1.,    alog10(0.5)+2, alog10(.9)+2, 2.]
save,x,y,file='~/Filter_type_5b.sav',/verb
end

pro mk5c
; 5 cavity andover from oriel website table, widest values
x=[-10, -3.85,-2.25,  -1.65, -1.25, -1.,         -.85,        0] / 5.
y=[-3., -2. ,   -1.,    0.,   1.,    alog10(0.5)+2, alog10(.9)+2, 2.]
save,x,y,file='~/Filter_type_5c.sav',/verb
end

pro procsc,num,b=b,c=c

btxt=''
if keyword_set(b) then btxt='b' 
if keyword_set(c) then btxt='c'

fn='~/Filter_type_'+string(num,format='(I0)')+btxt+'.sav'
restore,file=fn
x2=[x,-(reverse(x))(1:*)]
y2=[y,(reverse(y))(1:*)]
idx=sort(x2)
x2=x2(idx)
y2=y2(idx)
xn=linspace(-1,1.,300)
ynl=interpol(y2,x2,xn)
;ynl=spline(x2,y2,xn)
transmission=10.^ynl
transmission/=max(transmission)
plot,xn,transmission,/ylog
oplot,x,10^y/100.,psym=4,col=2
save,transmission,file='~/idl/andover_scan_'+string(num,format='(I0)')+btxt+'.sav',/verb
;stop
end



pro getp,l,d,l0,fwhm
mx=max(d,imax)
l0=l(imax)
ia=value_locate(d(0:imax-1),mx/2)
ib=imax+value_locate(d(imax:*),mx/2)
fwhm=l(ib)-l(ia)
l0=(l(ib)+l(ia))/2
end


pro scalld,lam,dpar,l0=l0new,fwhm=fwhmnew,opt=opt,remember=remember
common cbr, l,d,l0,fwhm
;more=1
;stop



if not keyword_set(remember) then begin
    getld,l,d,opt=opt
endif
;if keyword_set(more) then begin
;    lam1=(l-l0)/fwhm * fwhmnew + l0new
;    lam=linspace(min(lam1),max(lam1),1000)
;    dpar=spline(lam1,d,lam);

;endif else begin

;if keyword_set(noscal) then begin

doscal=1
if strmid(opt,0,6) eq 'hipass' then doscal=0
if opt eq 'cvi' then begin
lc=651.135;      8.39996
dl=656.1-lc

    lam=l+dl*1e-9*2;8.4e-9
    dpar=d
    return
endif


if doscal eq 0 then begin
    mag=alog10(l0new)
    if mag lt -6 then mult=1e9 else mult=1. ; check nm or m
    lam=(l - 656.6 + l0new*mult)/mult
    dpar=d
;    if mult eq 1e9 then stop
;    print,'l0new=',l0new
;    stop
endif else begin
    getp,l,d,l0,fwhm
    lam=(l-l0)/fwhm * fwhmnew + l0new
    dpar=d
endelse


end


pro getld,lam,transmission,opt=opt
if opt eq 't5' then begin
    restore,file='~/idl/fivecavity.xdr'
    nl=n_elements(transmission)
    lam=findgen(nl)
endif
if opt eq 'a5' then begin
    restore,file='C:\Users\Haitao\andover_scan_5.sav'
    nl=n_elements(transmission)
    lam=findgen(nl)
endif
if opt eq 'a5b' then begin
    restore,file='C:\Users\Haitao\andover_scan_5b.sav'
    nl=n_elements(transmission)
    lam=findgen(nl)
endif
if opt eq 'a5c' then begin
    restore,file='~C:\Users\Haitao\andover_scan_5c.sav'
    nl=n_elements(transmission)
    lam=findgen(nl)
endif
if opt eq 'a4b' then begin
    restore,file='~C:\Users\Haitao\andover_scan_4b.sav'
    nl=n_elements(transmission)
    lam=findgen(nl)
endif
if opt eq 'a4c' then begin
    restore,file='C:\Users\Haitao\andover_scan_4c.sav'
    nl=n_elements(transmission)
    lam=findgen(nl)
endif

if opt eq 'a3' then begin
    restore,file='C:\Users\Haitao\andover_scan_3.sav'
    nl=n_elements(transmission)
    lam=findgen(nl)
endif
if opt eq 'a4' then begin
    restore,file='C:\Users\Haitao\andover_scan_4.sav'
    nl=n_elements(transmission)
    lam=findgen(nl)
endif
if opt eq 'a2' then begin
    restore,file='C:\Users\Haitao\andover_scan_2.sav'
    nl=n_elements(transmission)
    lam=findgen(nl)
endif
if opt eq 'a1' then begin
    restore,file='C:\Users\Haitao\andover_scan_1.sav'
    nl=n_elements(transmission)
    lam=findgen(nl)
endif

if opt eq 't6' then begin
    restore,file='~/idl/sixcavity.xdr'
    nl=n_elements(transmission)
    lam=findgen(nl)
endif
if opt eq 't3' then begin
    restore,file='~/idl/threecavity.xdr'
    nl=n_elements(transmission)
    lam=findgen(nl)
endif
if opt eq 'cx5' then begin
    restore,'~njconway/idl/mastcx/code/barr5cavity.xdr'
;plot,barr5cavity(0,*),barr5cavity(1,*)
    transmission=barr5cavity(1,*)/100.
    lam=barr5cavity(0,*)
endif
if opt eq 'cvi' then begin
    d=(read_ascii('~/xm2.csv',data_start=9,delim=',')).(0)
    icol=3
    lam=d(icol,*)*1e-9
    transmission=d(icol+1,*)/100.
endif

if opt eq 'barr6t' then begin
    dum=read_ascii('/home/cmichael/idl/657x12nm_theo.csv',data_start=0,delim=',')
    transmission = (dum.(0))[1,*]/100.
    lam = (dum.(0))[0,*]
endif
if opt eq 'barr5t' then begin
    fil='~/barr659x11nm sim.csv'
    dum=read_ascii(fil,delim=',',data_start=5)
    d=dum.(0)
;Wavelength(nm)	uniform	CW3.4nm	CW2nm	CW1nm	CW0.5nm
    lam=d(0,*)
    un=d(1,*)/100.
    transmission=un

endif
if opt eq 'barr5t1.6' then begin
    fil='~/barr659x11nm sim.csv'
    dum=read_ascii(fil,delim=',',data_start=5)
    d=dum.(0)
;Wavelength(nm)	uniform	CW3.4nm	CW2nm	CW1nm	CW0.5nm
    lam=d(0,*)
    un=d(2,*)/100.
    transmission=un

endif
if opt eq 'hipass1' then begin
    lam1=656.6+[0,     1]
    ly1=       [-2,     -0.5]

    lam=linspace(650,663,300)
    ly=interpol(ly1,lam1,lam)<0.
    ly=smooth(ly,300./13.*0.6)
    transmission=10^ly
endif

if opt eq 'hipass2' then begin
    lam1=656.6+[0,     1.]*2
    ly1=       [-2,     -0.5]

    lam=linspace(650,663,300)
    ly=interpol(ly1,lam1,lam)<0.
    ly=smooth(ly,300./13.*0.6)
    transmission=10^ly
endif

if opt eq 'synth5c' then begin
    lam1=656.6+[0,     1]*2
    ly1=       [-2,     -0.5]
    dl=13
    lam=linspace(-15,15,300)+656.6
    lya=interpol(ly1,lam1-dl/2,lam)
;stop
    lyb=interpol(reverse(ly1),lam1+dl/2,lam)
    idx=where(lya gt lyb)
    ly=lya
    ly(idx)=lyb(idx)
    ly=ly<0


    ly=smooth(ly,300./30.*0.6)
    transmission=10^ly
;    stop
endif


if opt eq 'synth8c' then begin
    lam1=656.6+[0,     1]
    ly1=       [-2,     -0.5]
    dl=10.1
    lam=linspace(-15,15,300)+656.6
    lya=interpol(ly1,lam1-dl/2,lam)
;stop
    lyb=interpol(reverse(ly1),lam1+dl/2,lam)
    idx=where(lya gt lyb)
    ly=lya
    ly(idx)=lyb(idx)
    ly=ly<0


    ly=smooth(ly,300./30.*0.6)
    transmission=10^ly
;    stop
endif

end

