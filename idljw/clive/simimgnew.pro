 
pro simimgnew,simg,sh=sh,db=db,lam=lam,svec=svec,ifr=ifr,angdeptilt=angdeptilt,p=p,str=str,noload=noload,xytilt=xytilt
default,xytilt,[0,0.]
default,svec,[1,1.,0,0]
if not keyword_set(noload) then begin
   readpatch,sh,p,db=db
   readcell,p.cellno,str
endif
print,p.cellno
default,lam,656.1e-9


default,ifr,0

stat=transpose([[0,0,1,1],[0,1,0,1]])

stat1=[((ifr - p.flc0t0) mod p.flc0per) / (p.flc0mark eq 0 ? p.flc0per/2 : p.flc0mark), ((ifr-p.flc1t0) mod p.flc1per) / (p.flc1mark eq 0 ? p.flc1per/2 : p.flc1mark)]


istat=where( (stat1(0) eq stat(0,*)) and (stat1(1) eq stat(1,*)))
state=istat


imsz=[(p.roir-p.roil+1),(p.roit-p.roib+1)]/[p.binx,p.biny]
i0=(getcamdims(p)/[p.binx,p.biny]) / 2. + xytilt*!dtor * p.flencam /( p.pixsizemm * [p.binx,p.biny])

ixo=(findgen(imsz(0))+p.roil-1 - i0(0))
iyo=(findgen(imsz(1))+p.roib-1 - i0(1))

iw=[value_locate(ixo,0),value_locate(iyo,0)]
;stop
x1=ixo*p.binx * p.pixsizemm;6.5e-3
y1=iyo*p.biny * p.pixsizemm;6.5e-3

x2 = x1 # replicate(1,imsz(1))
y2 = replicate(1,imsz(0)) # y1


thx=x2/p.flencam
thy=y2/p.flencam


tn=tag_names(str)
i0=value_locate(tn,'WP1')
nstates=1
max_crystal = 6;5
for i=0,max_crystal do begin
    if str.(i0+i).type eq 'flc' then nstates=nstates*2
endfor





;for state=0,nstates-1 do begin

    g = 0.
    img=fltarr(imsz(0),imsz(1),4)
    img(*,*,0)=svec(0)
    img(*,*,1)=svec(1)
    img(*,*,2)=svec(2)
    img(*,*,3)=svec(3)
    for i=0,max_crystal do begin
        tmp=str.(i0+i)
        tmp.angle+=str.mountangle - p.camangle
        if tmp.type eq 'wp' then begin
            par={crystal:tmp.material,thickness:tmp.thicknessmm*1e-3,facetilt:tmp.facetilt*!dtor,lambda:lam,delta0:tmp.angle*!dtor}


            opd=opd(thx,thy,par=par,delta=par.delta0)/2/!pi
;            if i eq 0 then opd=opd*0+0.25

            print,'thicknessmm=',tmp.thicknessmm,'facetilt:',tmp.facetilt,'angle=',par.delta0*!radeg,'opd=',opd[iw(0),iw(1)]
;            if opd gt 100 then kappa=kappat

;            print,opd/opdt, 1+kappat*del

        endif
        if tmp.type eq 'flc' then begin
            opd=tmp.delaydeg/360
            s=stat(tmp.sourceid,state)*2. - 1.
            par={delta0:(tmp.angle + s * tmp.switchangle/2)*!dtor,facetilt:0.}
            k=0.
            print,'flc ','angle',par.delta0*!radeg,'retardance',tmp.delaydeg
        endif
        if tmp.type eq 'flc' or tmp.type eq 'wp' then begin
           if not keyword_set(angdeptilt) or par.facetilt eq 0 then begin
              mrotate,img,g,par.delta0
              mwp,img,opd*2*!pi
              mrotate,img,g,-par.delta0
           endif else begin
              dang3=ang_err( thx, thy, par=par,delta=par.delta0)
              mrotate,img,g,par.delta0+dang3
              mwp,img,opd*2*!pi
              mrotate,img,g,-par.delta0-dang3
           endelse
        endif
        if tmp.type eq 'pol' then begin
            mrotate,img,g,tmp.angle*!dtor
            simg=img(*,*,0)+img(*,*,1)
            goto,out1
        endif
    endfor
    out1:
;endfor

end

;simimgnew,img
;!p.multi=[0,1,2]
;d=getimgnew(8046,100)
;'i;mgplot,img(800:900,800:900),/iso
;imgplot,d(800:900,800:900),/iso
;!p.multi=0

;end



