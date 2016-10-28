pro fitplane,ent,sol
np=n_elements(ent)
mat=fltarr(4,2*np)
for i=0,np-1 do begin
    mat(0:2,2*i:2*i+1)=*ent(i).vertices
endfor
mat(3,*)=1.
;mat=mat(*,0:10)
svdc,(mat),w,u,v
dummy=min(w,imin)

sol=v(imin,*)
nm=norm(sol(0:2))
sol=sol/nm
;print,mat##sol
;stop

end


pro calcint,ent,pts,show=show
bks=ent.block
srt=sort(bks)
ub=bks(uniq(bks,srt))
nb=n_elements(ub)
pl=fltarr(3,4,nb)
for i=0,nb-1 do begin
    ix=where(ent.block eq ub(i))
    nix=n_elements(ix)
    for j=0,nix-1 do begin
        pl(*,j,i)=(*(ent(ix(j)).vertices))(*,0)
        if keyword_set(show) then print,pl(*,j,i)
    endfor
endfor
p = fltarr(3,3)
v = p
w = p
n = p
p=reform(pl(*,0,*),3,3)
v=reform(pl(*,1,*)-pl(*,0,*),3,3)
w=reform(pl(*,3,*)-pl(*,0,*),3,3)
for i=0,2 do v(*,i)=v(*,i)/norm(v(*,i))
for i=0,2 do w(*,i)=w(*,i)/norm(w(*,i))


for i=0,2 do n(*,i)=crossp(v(*,i),w(*,i))

for i=0,2 do n(*,i)=n(*,i)/norm(n(*,i))

dotp=fltarr(3)
for i=0,nb-1 do dotp(i)=total(p(*,i)*n(*,i))

;q=fltarr(3)
;for i=0,2 do q=q + n(*,i) * dotp(i)

mi=invert(transpose(n))
q=mi # dotp

pts=fltarr(3,2,6)
len=100.
for i=0,5 do pts(*,0,i)=q
for i=0,2 do pts(*,1,i)=q + n(*,i) * len
for i=0,2 do pts(*,1,i+3)=q - n(*,i) * len

;if keyword_set(show) then stop

end

pro calcint2,odxf,layer,pts,show=show

o1=odxf->GetEntity(19,layer=layer) ; 2
nb=n_elements(o1)

pl=fltarr(3,4,nb)
for i=0,nb-1 do begin
    blk=o1(i).instance_block
    ent=odxf->GetEntity(4,block=blk)
    nix=n_elements(ent)
    for j=0,nix-1 do begin
        pl(*,j,i)=(*(ent((j)).vertices))(*,0)
        if keyword_set(show) then print,pl(*,j,i)
    endfor
endfor
p = fltarr(3,3)
v = p
w = p
n = p
p=reform(pl(*,0,*),3,3)
v=reform(pl(*,1,*)-pl(*,0,*),3,3)
w=reform(pl(*,3,*)-pl(*,0,*),3,3)
for i=0,2 do v(*,i)=v(*,i)/norm(v(*,i))
for i=0,2 do w(*,i)=w(*,i)/norm(w(*,i))


for i=0,2 do n(*,i)=crossp(v(*,i),w(*,i))

for i=0,2 do n(*,i)=n(*,i)/norm(n(*,i))

dotp=fltarr(3)
for i=0,nb-1 do dotp(i)=total(p(*,i)*n(*,i))

;q=fltarr(3)
;for i=0,2 do q=q + n(*,i) * dotp(i)

mi=invert(transpose(n))
q=mi # dotp

pts=fltarr(3,2,6)
len=100.
for i=0,5 do pts(*,0,i)=q
for i=0,2 do pts(*,1,i)=q + n(*,i) * len
for i=0,2 do pts(*,1,i+3)=q - n(*,i) * len

;if keyword_set(show) then stop
;top
end


fil = '/home/cam112/H1VIEW_REENTRY.dxf';~/faro/faro_data.dxf'
odxf = OBJ_NEW('IDLffDXF')
status = odxf->Read(fil)
types = odxf->GetContents(COUNT = cnt,layer='IPOINTS')
PRINT, 'Entity Types: ', types
PRINT, 'Count of Types: ', cnt

stop
ent1 = odxf->GetEntity(16,layer='IPOINTS')
ent2 = odxf->GetEntity(2,layer='IPOINTS') ; 2
;stop
nt=n_elements(ent1);+n_elements(ent2)
p0=[[ent1.pt0]];,[ent2.pt0]]
p1=p0
len=100.
for i=0,nt-1 do begin
    tmp=[p0(0:1,i),0]
    tmp=tmp/norm(tmp)
    p1(*,i)=p0(*,i) + tmp*len
endfor
parr=fltarr(3,2,nt)
parr(*,0,*)=reform(p0,3,1,nt)
parr(*,1,*)=reform(p1,3,1,nt)

;types = odxf->GetContents(COUNT = cnt,layer='IC4') &PRINT, 'Entity Types: ', types&PRINT, 'Count of Types: ', cnt
;print,'---'

;ent = odxf->GetEntity(18,layer='IC1')
;help,/str,ent
;retall
;types = odxf->GetContents(COUNT = cnt,block='*U159') &PRINT, 'Entity Types: ', types&PRINT, 'Count of Types: ', cnt
;print,'---'
;ent = odxf->GetEntity(18,layer='IC1')
;help,/str,ent


calcint,odxf->GetEntity(4,layer='IC1'),parr2;,/show
parr=[[[[parr]],[[parr2]]]]
calcint,odxf->GetEntity(4,layer='IC2'),parr2
parr=[[[[parr]],[[parr2]]]]
calcint,odxf->GetEntity(4,layer='IC3'),parr2;,/show
parr=[[[[parr]],[[parr2]]]]
calcint2,odxf,'IC4',parr2,/show
parr=[[[[parr]],[[parr2]]]]
calcint2,odxf,'IC5',parr2,/show
parr=[[[[parr]],[[parr2]]]]
calcint2,odxf,'IC6',parr2,/show
parr=[[[[parr]],[[parr2]]]]
calcint2,odxf,'IC7',parr2,/show
parr=[[[[parr]],[[parr2]]]]


types = odxf->GetContents(COUNT = cnt,layer='IPORT3')
PRINT, 'Entity Types: ', types
PRINT, 'Count of Types: ', cnt
ent = odxf->GetEntity(4,layer='IPORT3')
fitplane,ent,sol

ent = odxf->GetEntity(16,layer='IPORT3')
cent=ent(0).pt0
quad=ent(1).pt0
rad=sqrt(total( (quad-cent)^2 ))
dir=cent & dir(2)=0. & dir=dir/norm(dir)

h=(-sol(3) - total(sol(0:2) * cent)) / total(sol(0:2)*dir)
print,h
cent=cent+h*dir
xh=crossp([1,0,0],dir) & xh=xh/norm(xh)
yh=crossp(xh,dir) & yh=yh/norm(xh)
xh=xh*rad
yh=yh*rad
ns=100
th=linspace(0,2*!pi,ns+1)
parr2=fltarr(3,2,ns)
for i=0,ns-1 do parr2(*,0,i)=cent + xh * cos(th(i)) + yh * sin(th(i))
for i=0,ns-1 do parr2(*,1,i)=cent + xh * cos(th(i+1)) + yh * sin(th(i+1))

parr=[[[[parr]],[[parr2]]]]


lns=parr
save,lns,file='~/newwrl/faro_ptsshow.sav',/verb


OBJ_DESTROY, odxf
END
