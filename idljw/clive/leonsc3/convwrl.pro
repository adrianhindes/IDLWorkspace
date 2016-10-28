;;;

@cutind
;@hidelines
pro moplot, x,y,z,_extra=_extra
;;if total(x lt 0) ne 0 then 

;oplot,y,z,_extra=_extra
oplot,x,y,_extra=_extra
end

pro indextok, dat, ttok0,ttok1,ix,pair

tk0=(byte(ttok0))(0)
tk1=(byte(ttok1))(0)
m0= (dat eq tk0)
m1= (dat eq tk1)
ix=where(m0 or m1)
n=n_elements(ix)
cl=0l
lev=intarr(n)
for i=0l,n-1 do begin
    if dat(ix(i)) eq tk0 then begin
        cl=cl+1
        lev(i)=cl
    endif
    if dat(ix(i)) eq tk1 then begin
        lev(i)=cl
        cl=cl-1
    endif
endfor

pair=lonarr(n)
    
for i=0l,n-1 do begin
    if dat(ix(i)) eq tk0 then begin
        for j=i+1,n-1 do if lev(j) eq lev(i) then break
        pair(i)=j-i
    endif
    if dat(ix(i)) eq tk1 then begin
        for j=i-1,0 do if lev(j) eq lev(i) then break
        pair(i)=j-i
    endif

endfor
end

pro findtok, c,en,ty,i1,toks,err=err
common tkb, dat, ix1, pair1,ix2,pair2
nt=n_elements(toks)
pa=lonarr(nt)
for i=0,nt-1 do begin
    pa(i)=strpos(string(dat(c:en)),toks(i))
;    if pa(i) eq -1 then pa(i)=99999999l
endfor
err=0
if product(pa eq -1) eq 1 then begin
    err=1
    return
endif
ix=where(pa ne -1)
i1=min(pa(ix),wch) + c

ty=toks(ix(wch))
end

pro getgroup1, c,st,en
common tkb, dat, ix1, pair1,ix2,pair2
i=(where(ix1 ge c))(0)
st=ix1(i)
en=ix1(i+pair1(i))
end

pro getgroup2, c,st,en
common tkb, dat, ix1, pair1,ix2,pair2
i=(where(ix2 ge c))(0)
st=ix2(i)
en=ix2(i+pair2(i))
end

pro taketokm,st,en,data,toks,cond,opt=opt
common tkb, dat, ix1, pair1,ix2,pair2
err=0
cnt=0

while err eq 0 do begin
    taketok1,st,en,field,value,ieol,toks,cond,err=err,opt=opt
    if err eq 0 then begin
      if n_elements(value) ne 0 then if cnt eq 0 then data=create_struct(field,value) else $
        data=create_struct(data,field,value)
      if n_elements(value) eq 0 then data=-1    
    endif
    cnt=cnt+1
    st=ieol
    
endwhile

;if n_elements(data) eq 0 then stop

end

function remlf, s
ix=where(s ne 10b and s ne 13b and s ne (byte(','))(0))
rv=s(ix)
return,rv
end



pro taketok1,st,en,field,value,ieol,toks,cond,err=err,opt=opt
common tkb, dat, ix1, pair1,ix2,pair2

if n_elements(value) ne 0 then tmp=temporary(value)
findtok, st,en,field,loc,toks,err=err
if err ne 0 then return
iw=(where(toks eq field))(0) ;value_locate(toks,field)
cond1=cond(iw)
loc=loc+strlen(field)
if cond1 eq 'sarr' then begin
    dum=where(dat(loc:en) eq 13b)
    ieol=dum(0)+loc;value_locate(dat(loc:en),13b)
    contents=strsplit(string(dat(loc:ieol)),/extr)
    fcontents=float(contents)
    value=fcontents
endif
if cond1 eq 'node' then begin
    getgroup2,loc, st2,en2
    bcnt=0L
    while 1 do begin
        getnode,dval,st2,en2,err=err1
        if err1 ne 0 then break
        tn=string('child_',bcnt,format='(A,I5.5)')
        if bcnt eq 0 then value=create_struct(tn,dval) else value=create_struct(value,tn,dval)
        bcnt=bcnt+1
    endwhile
    ieol=en2
endif
if cond1 eq 'coord' then begin
    opt1=opt(iw)
    getgroup2,loc, st2,en2
    contents=strsplit(string((dat(st2+1:en2-1))),'[ ,'+string([9b,10b,13b])+']+',/regex,/extr)
    value=float(contents)
    nv=n_elements(value)
    if opt1 eq 0 then begin
        if field eq 'coord Coordinate' then $
          value=reform(value,3,nv/3)
        if field eq 'coordIndex' then $
          value=reform(value,4,nv/4)
    endif

    ieol=en2
endif
    
;if n_elements(value) eq 0 then stop

end



pro getnode, node,c,en,err=err
common tkb, dat, ix1, pair1,ix2,pair2
common instb, inames, iptr,icnt
common gnb, reclev
if n_elements(reclev) eq 0 then reclev=0l

reclev=reclev+1


tmpp=strpos(dat(c:en),'USE')
if tmpp gt 10 then tmpp=-1
if tmpp ne -1 then begin
    tmpp2=c+tmpp
    tmp2=string(dat(tmpp2:en))
    spl=strsplit(tmp2,' ',/extr)
    arg=spl(1)
    print, 'found use '+arg
    iv=where(inames(0:icnt-1) eq arg) & iv=iv(0)
    if iv eq -1 then stop,'not found arg'
    node=*iptr(iv)
    node=create_struct(node,'use',arg)
    c=en
    err=0
    return
endif

;toks=['WorldInfo','NagigationInfo','Background','Viewpoint','Transform','Group','Shape','appearance','geometry','coord','solid','coord','point','coordindex','normal','vector']
toks=['Transform','IndexedFaceSet','IndexedLineSet','Group']
print,string(c/float(n_elements(dat))*100.,format='(I2.2)')

findtok,c,en,ty,i1,toks,err=err
if err ne 0 then return
if ty eq 'Group' then begin
    isdef=0
    ;; look between c and i1 for DEF 
    tmp=string(dat(c:i1))
    tmpp=strpos(tmp,'DEF')
    if tmpp ne -1 then begin
        tmp2=string(dat(c+tmpp:i1))
        spl=strsplit(tmp2,' ',/extr)
        arg=spl(1)
        print,'found DEF '+arg
        isdef=1
    endif
    getgroup1, i1, st1,en1
    taketokm,st1,en1,node,['children'],['node']
    c=en1
    reclev=reclev-1
    if size(node,/type) eq 8 then node=create_struct(node,'type',ty) else print, 'null node'
;    if size(node.children,/type) ne 8 then print, 'null children'
    if isdef eq 1 then begin
        node=create_struct(node,'def',arg)
        inames(icnt)=arg
        iptr(icnt)=ptr_new(node)
        icnt=icnt+1
    endif

;    stop
    return
endif
if ty eq 'IndexedFaceSet' then begin
    getgroup1, i1, st1,en1
    taketokm,st1,en1,node,['coord Coordinate','coordIndex'],['coord','coord'],opt=[0,0]
    c=en1
    reclev=reclev-1
    node=create_struct(node,'type',ty)
    return
endif
if ty eq 'IndexedLineSet' then begin
    getgroup1, i1, st1,en1
    taketokm,st1,en1,node,['coord Coordinate','coordIndex'],['coord','coord'],opt=[0,1]
    c=en1
    reclev=reclev-1
    node=create_struct(node,'type',ty)
    return
endif
if ty eq 'Transform' then begin
    getgroup1, i1, st1,en1
    taketokm,st1,en1,node,['scale','translation','rotation','children'],['sarr','sarr','sarr','node']
    c=en1
    reclev=reclev-1
    if size(node,/type) eq 8 then node=create_struct(node,'type',ty) else print, 'null node'
;    if size(node.children,/type) ne 8 then print, 'null children'
    return
endif






end
function genrotmat, vec
x=vec(0)
y=vec(1)
z=vec(2)
th=vec(3)
ct=cos(th)
st=sin(th)

mat=[ [ x^2 * (1-ct) + ct,    x*y*(1-ct) - z*st,     x*z*(1-ct) + y*st],$
      [ x*y*(1-ct)+z * st,  y^2 * (1-ct) + ct  ,   y*z*(1-ct) - x * st],$
      [ x*z*(1-ct)-y * st,  y*z*(1-ct) + x*st  ,   z^2 * (1-ct) + ct  ] ]
return,mat
end

pro transformact, node,mat=mat0,scal=scal0,trans=trans0,set=set0
common cbtransformact1, reclev,gbc,locarr,pos

if n_elements(node) eq 0 then stop
if size(node,/type) ne 8 then begin
    return
endif
if n_elements(reclev) eq 0 then reclev=0
paf=0
if reclev gt 0 then begin
    tstp=[1,0,0,0,0,1,2,0,0,9,0,0,2]
    tstp=[1,0,0,0,0,1,2,0,0,9,0,0,0,0]
    if reclev eq n_elements(tstp) then if product(tstp eq pos(0:reclev-1)) eq 1 then begin
        print,'set',set0
        print,'bf',node.coord_coordinate(*,0)
        paf=1
;        stop
    endif
;stop
;.(01).(00).(00).(00).(00).(01).(02).(00).(00).(09).(00).(00).(02)
;       t         t         tx
endif
reclev=reclev+1
;gbc=gbc+1

nt=n_tags(node)
doit=0

leaf=0                          ; leaf=1 means end of tree
isgroup=0

if istag(node,'type') then if node.type eq 'Transform' then doit=1 
if istag(node,'type') then if node.type eq 'Group' then isgroup=1 
if istag(node,'coord_coordinate') then leaf=1

if doit eq 0 then begin
    if leaf eq 1 then begin
        nc=n_elements(node.coord_coordinate(0,*))
        for i=0,nc-1 do begin
            mat=mat0
            node.coord_coordinate(*,i) = $
              mat0 ## node.coord_coordinate(*,i) + trans0 ; no scale
        endfor
        if paf eq 1 then print, 'af',node.coord_coordinate(*,0)

    endif else begin
        for i=0,nt-1 do begin
            pos(reclev-1)=i
            dum=node.(i)
            transformact, dum,mat=mat0,scal=scal0,trans=trans0,set=set0
            node.(i)=dum
        endfor
    endelse
endif
if doit eq 1 then begin
    scal1=1.                    ; forget scale here cause not changed
    trans1=[0.,0.,0.]
    mat1=identity(3)
    set1=pos(0:reclev-1)
    if istag(node,'translation') then trans1=node.translation;/.001
    if istag(node,'rotation') then begin
        mat1=genrotmat(node.rotation)
;        set1=node.rotation
    endif
    tn=tag_names(node)
    ix=where(tn eq 'CHILDREN')
    pos(reclev-1)=ix
                                ; first apply new transformation
    dum=node.children
    transformact, dum,mat=mat1,scal=scal1,trans=trans1,set=set1
                                ; then apply old transformation
    ; then set the type so that it can't be done again
    node.type='DoneTransform'
    transformact, dum,mat=mat0,scal=scal0,trans=trans0,set=set0
    node.children=dum
endif

reclev=reclev-1

end

pro unfoldnode, node
common unfb, lns, lnc
common unfb2, fcb, fcc

reclev=0l
gbc=0l
pos=fltarr(30)

if n_elements(node) eq 0 then stop
if size(node,/type) ne 8 then begin
;    print, 'ignoring null leaf'
    if node(0) ne -1 then stop
    return
endif
if n_elements(levr) eq 0 then levr=0
levr=levr+1
gbc=gbc+1
;print, 'entering', levr, gbc
nt=n_tags(node)
doit=0
if istag(node,'type') then if node.type eq 'IndexedLineSet' then begin
    coord=node.coord_coordinate
    ind=    node.coordindex    
    np=n_elements(ind)
    np=np-1
    ind=ind(0:np-1)
    moplot,coord(0,ind),coord(1,ind),coord(2,ind)
    lns(*,0,lnc:lnc+np-2)=reform(coord(*,ind(0:np-2)),3,1,np-1)
    lns(*,1,lnc:lnc+np-2)=reform(coord(*,ind(1:np-1)),3,1,np-1)
    lnc=lnc+np-1
;    if np gt 10 then begin
;        dst= sqrt(total((coord(*,1:np-1)-coord(*,0:np-2))^2,1))
;        print,minmax(dst)
;    endif
    return
endif 
if istag(node,'type') then if node.type eq 'IndexedFaceSet' then begin
    if istag(node,'coord_coordinate') eq 0 then goto,aff
    coord=node.coord_coordinate
    ind=    node.coordindex(0:2,*)   
    np=n_elements(ind(0,*))

    dfac=fltarr(3,3,np)
    for i=0,np-1 do dfac(*,*,i)=coord(*,ind(*,i))
    fcb(*,*,fcc:fcc+np-1)=dfac
    fcc=fcc+np
    for i=0,np-1 do moplot,coord(0,ind(*,i)),coord(1,ind(*,i)),coord(2,ind(*,i)),col='ff0000'x
    for i=0,np-1 do polyfill,coord(0,ind(*,i)),coord(1,ind(*,i)),col='ff0000'x

;    for i=0,np2-1 do moplot,coord(0,ind2(*,i)),coord(1,ind2(*,i)),coord(2,ind2(*,i)),col=3
;    if np gt 100 then stop

    aff:
    return
endif


;;; otherwise..

haschildren=0
if istag(node,'children') then haschildren=1
;if haschildren eq 1 then unfoldnode,node.children
if haschildren eq 1 then begin
    if istag(node,'def') and not istag(node,'use') then begin
;        print, 'ignoring a part because def but no use'
;        goto,af
    endif
    for i=0,n_tags(node.children)-1 do unfoldnode,node.children.(i)
    af:
endif

;if isgroup eq 0 then for i=0,nt-1 do unfoldnode, node.(i)



end


pro convwrl,fn,pathin,pathout

common cbtransformact1, reclev,gbc,locarr,pos
gbc=0l
reclev=0l
pos=intarr(500)
common unfb, lns, lnc
common unfb2, fcb, fcc
lns=fltarr(3,2,1e6) & lnc=0l
fcb=fltarr(3,3,1e6) & fcc=0l
r=2000. ;[-580,-600]
plot,[-1,1]*r,[-1,1]*r,/nodata,ysty=1

common tkb, dat, ix1, pair1,ix2,pair2
common instb, inames, iptr,icnt
;restore,file='~/node0.sav'
;goto,ee


icnt=0l
mx=1000
inames=strarr(mx)
iptr=ptrarr(mx)

;;fil='~/disc_coil.wrl'
;fil='~/coil1.wrl'
;fn='~/cent_column'
;fn='~/coil1' ;tae_upper'
fil=pathin+'/'+fn+'.wrl'
siz=(file_info(fil)).size
openr,lun,fil,/get_lun

dat=bytarr(siz)
readu,lun,dat

close,lun
free_lun,lun

indextok, dat,'{','}',ix1,pair1
indextok, dat,'[',']',ix2,pair2


c=0l
ntxt=n_elements(dat)
;while c lt ntxt do begin
getnode,node0,c,ntxt-1
inames=inames(0:icnt-1)
iptr0=iptr(0:icnt-1)
;stop
iptr=ptrarr(icnt)
for i=0,icnt-1 do begin
    iptr(i)=ptr_new(*iptr0(i))
endfor


;ee:

node=node0;*iptr(0) ;node0;*iptr(0); node0
;stop


scal=1.
mat=identity(3)
trans=fltarr(3)
i=2
;print,node.(01).(00).(00).(00).(00).(i).(02).(00).(00).(09).(00).(00).(0).(4).coord_coordinate
;unfoldnode,node
;lnsb=lns
set0=fltarr(4)
transformact, node,scal=scal,trans=trans,mat=mat,set=set0
;stop
;print,node.(01).(00).(00).(00).(00).(i).(02).(00).(00).(09).(00).(00).(0).(4).coord_coordinate
;!p.color=2
ee:
unfoldnode,node
lns=lns(*,*,0:lnc-1)
if fcc gt 0 then fcb=fcb(*,*,0:fcc-1) else dum=temporary(fcb)

save,lns,fcb,file=pathout+'/'+fn+'show.sav'  

;',fcb



end


;fn=['coil_lower','coil_upper']
;fn=['cent_column','bdump',
;fn=['gdc1','gdc2','tae_upper','tank']
;fn=['disc_coil']
;fn=['coil_lower2',[
;fn=['tae_lower']
;fn=['tae1']
;nfn=n_elements(fn)
;for i=0,nfn-1 do tstp3,fn(i)
;end

