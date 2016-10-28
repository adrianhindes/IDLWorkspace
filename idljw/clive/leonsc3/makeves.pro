pro makeves

rves=2000.
thmin=-90*!dtor
thmax=0*!dtor
nseg=91
zmin=-500.
zmax=500.
th=linspace(thmin,thmax,nseg)

lns=fltarr(3,2,1e5)
fcb=fltarr(3,3,1e5)
c1=0
c2=0
scal=1.0;0.99
for i=0,nseg-2 do begin
    x1=rves*cos(th(i))
    y1=rves*sin(th(i))
    x2=rves*cos(th(i+1))
    y2=rves*sin(th(i+1))
    fcb(*,2,c1)=[x1,y1,zmin]
    fcb(*,1,c1)=[x1,y1,zmax]
    fcb(*,0,c1)=[x2,y2,zmax]
    c1+=1
    fcb(*,0,c1)=[x2,y2,zmin]
    fcb(*,1,c1)=[x2,y2,zmax]
    fcb(*,2,c1)=[x1,y1,zmin]
    c1+=1
    lns(*,0,c2)=[x1,y1,zmin]*scal
    lns(*,1,c2)=[x1,y1,zmax]*scal
    c2+=1
    if i eq nseg-2 then begin
        lns(*,0,c2)=[x2,y2,zmin]*scal
        lns(*,1,c2)=[x2,y2,zmax]*scal
        c2+=1
    endif
endfor

fcb=fcb(*,*,0:c1-1)
lns=lns(*,*,0:c2-1)
fil=string('~/newwrl/ves_',thmin*!radeg,'_',thmax*!radeg,'_',zmin,'_',zmax,'_show.sav',$
           format='(A,G0,A,G0,A,G0,A,G0,A)')
save,fcb,lns,file=fil,/verb
print,fil
plot,[-2.5,2.5],[-2.5,2.5],/iso,/nodata
oplot,lns(0,*,*),lns(1,*,*)
oplot,fcb(0,*,*),fcb(1,*,*),col=2
stop

end




    
makeves
end
