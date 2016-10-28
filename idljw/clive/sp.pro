pro sp,rwant,twant,ac=ac1,bg=bg1,cx=cx1,lam=lam1,tr=tr1

common cbb, filt_dat,wavelength,$
   IntensityM,BG,CX,Gauss,time,radius
if n_elements(IntensityM) ne 0 then goto, ee

;goto,af2

;dirData=cd(/current); % filenames of files in the folder are saved in
;dirData array





shotN=9240
spectrumFilename='~/'+string(shotN,format='(I0)')+'DS_spectrum_v2.txt'



xzeroFilename='~/xzeroDS_DU897.txt'; % for Andor897 [pixel]
dispersion=0.011; % [nm/pixel]

openr,fid,xzeroFilename,/get_lun
xzeroN=0
readf,fid,xzeroN
xzero=fltarr(xzeroN)
for i=0,xzeroN-1 do begin
   tmp=0.
    readf,fid,tmp & xzero(i)=tmp
endfor
close,fid & free_lun,fid


wavelength=fltarr(32,254)

for i=0,32-1 do begin
    for j=0,254-1 do begin
        if (i gt 16-1) then begin
            wavelength(i,j)=529.05+(xzero(i)-256-(j+1))*dispersion
        endif else begin
            wavelength(i,j)=529.05+(xzero(i)-(j+1))*dispersion
        endelse
    endfor
endfor


;rarr=[replicate(2000,8),replicate(2100,8),$
;      replicate(2200,8),replicate(2250,8)]
rarr=[replicate(2000,16),replicate(2200,16)]

;rarr=[2000,2100,2200,2250]
n=n_elements(rarr)
filt_lam=fltarr(n,254)
filt_dat0=filt_lam
filt_dat=wavelength
for i=0,n-1 do begin
   fn='~/7266_T5355ms_R'+string(rarr(i),format='(I0)')+'mm.txt'
   dat=(read_ascii(fn,data_start=0)).(0)
;mkfig,'~/fit1.eps',xsize=14,ysize=10,font_size=9
;if i eq 0 then plot,dat(0,*),dat(4,*) else
;oplot,dat(0,*),dat(4,*),col=i+1
;   if i eq 0 then filt_lam=fltarr(
   filt_lam(i,*)=dat(0,0:253)
   filt_dat0(i,*)=dat(4,0:253)
   filt_dat(i,*)=interpol(filt_dat0(i,*),filt_lam(i,*),wavelength(i,*))
endfor

;stop



openr,lun,spectrumFilename,/get_lun
spdata=fltarr(25000000)
on_ioerror,af
readf,lun,spdata
af:
tmp=fstat(lun)
n=tmp.transfer_count
spdata=spdata(0:n-1)

af2:



channelN=spdata(1-1);
ndata=spdata(2-1);
leftN=spdata(3-1);
gapN=spdata(4-1);
dframe=(1+ndata*4)*channelN+1;
dchannel=1+ndata*4;
totalFrame=(n-2)/((1+ndata*4)*channelN+1);


pixel=findgen(ndata)+1
time=fltarr(1,totalFrame);
radius=fltarr(1,channelN);
IntensityM=fltarr(totalFrame,channelN,ndata);
BG=fltarr(totalFrame,channelN,ndata);
CX=fltarr(totalFrame,channelN,ndata);
Gauss=fltarr(totalFrame,channelN,ndata);

for i=1-1 , totalFrame-1 do begin
    time(i)=spdata(-1+5+dframe*(i));
    
    for j=1-1,channelN-1 do begin
        
        radius(j)=spdata(-1+6+dframe*(i+1-1)+(4*ndata+1)*(j+1-1));
        IntensityM(i,j,*)=spdata(-1+6+dframe*(i)+(4*ndata+1)*(j)+1:-1+6+dframe*(i)+(4*ndata+1)*(j)+ndata);
        BG(i,j,*)=spdata(-1+6+dframe*(i)+(4*ndata+1)*(j)+1+ndata:-1+6+dframe*(i)+(4*ndata+1)*(j)+2*ndata);
        CX(i,j,*)=spdata(-1+6+dframe*(i)+(4*ndata+1)*(j)+1+2*ndata:-1+6+dframe*(i)+(4*ndata+1)*(j)+3*ndata);
        Gauss(i,j,*)=spdata(-1+6+dframe*(i)+(4*ndata+1)*(j)+1+3*ndata:-1+6+dframe*(i)+(4*ndata+1)*(j)+4*ndata);
        
        
;        Gauss(i,j,Gauss(i,j,1:ndata)==0)=nan;
;        CX(i,j,CX(i,j,1:ndata)==0)=nan;
        
        
    endfor
    
    
endfor


ee:

it=value_locate(time,twant)
ir=value_locate(radius,rwant)
ac1=intensitym(it,ir,*)
bg1=bg(it,ir,*)
tr1=filt_dat(ir,*)
lam1=wavelength(ir,*)


end

;sp, 2250, 3.2,ac=ac,bg=bg,tr=tr,lam=lam


;end
