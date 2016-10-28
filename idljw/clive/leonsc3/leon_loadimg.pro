pro leon_loadimg, set
common cbleon, sim, sobj;img,imset
common nleonwb, id,id1,id2,id3,id4,defsz
forward_function ipx2frame,ipx2open

if set.format eq 0 then suff='.ipx'
if set.format eq 1 then suff='.tif'
if set.format eq 2 then suff='.png'

if set.type eq 0 then begin
    ; mastdb
    ssh=string(set.sh,format='(I0)')
    ssh2=string(set.sh,format='(I6.6)')

    fname='$MAST_DATA/'+ssh+'/Images/'+set.pre+ssh2+suff
endif
if set.type eq 1 then begin
    ; mastdb
    fname=set.filename(0)
endif



if set.format eq 0 then begin
    dstr=ipx2open(fname,rate=rate)
;    stop
    help,/str,dstr.fileinfo,output=op
    for i=0,n_elements(op)-1 do print,op(i)
    d0 = ipx2frame(dstr, set.frnum , EXP=texp)
    print,'loaded'+fname+' fr#'+string(set.frnum,format='(I0)')
endif

if set.format eq 1 then begin
    d0=read_tiff(fname,image_index=set.frnum)
    dum1=query_tiff(fname,info)
    help,/str,info,output=op
    for i=0,n_elements(op)-1 do print,op(i)
    print,'loaded'+fname+' fr#'+string(set.frnum,format='(I0)')
endif

if set.format eq 2 then begin
    d0=read_png(fname)
    print,'loaded'+fname;+' fr#'+string(set.frnum,format='(I0)')
endif


if set.format eq 1 then begin
    d0=read_tiff(fname,image_index=set.frnum)
    dum1=query_tiff(fname,info)
    help,/str,info,output=op
    for i=0,n_elements(op)-1 do print,op(i)
    print,'loaded'+fname+' fr#'+string(set.frnum,format='(I0)')
endif

if set.format ge 3 then begin
;    uc = get_kstar_mse_images_cached(set.sh, cal=set.sh lt 1000 ? 1 :
;    0,camera=camera, time=timec, tree=tree)
    d0=getimgnew(set.sh,set.frnum,str=str,db=set.format eq 3 ? 'k' : 'c')
;    nt=n_elements(timec)
;    print,'time vector is' 
;    print,transpose([[indgen(nt)],[timec-timec(0)]])
;    ndim=size(uc,/n_dim)
;    if ndim gt 2 then d0=uc(*,*,set.frnum) else d0=uc
    print,'loaded kmse shot# ',string(set.sh,format='(I0)'),' ,fr#'+string(set.frnum,format='(I0)')
    sz=size(d0,/dim)
    widget_control,id1.dim,set_value=6.5e-3 * sz * str.binx

    i0=(getcamdims(str)  )/2.
    cent=([(i0(0) - (str.roil-1)), (i0(1)-(str.roib-1))]*1.0) / $
      (1.0*[str.roir - str.roil+1,str.roit-str.roib+1])
    widget_control, id.distcx,set_value=cent(0)
    widget_control, id.distcy,set_value=cent(1)
    


endif


if set.avg4 eq 1 then begin
    d0=cutd0(d0,0,0) + cutd0(d0,0,1) + cutd0(d0,1,0) + cutd0(d0,1,1)
endif

d0=rotate(d0,set.pretransp)

sz=size(d0,/dim)

if set.expfact ge 1 then $
  d1=rebin(d0,sz(0)*set.expfact,sz(1)*set.expfact,/sample) $
else $
  d1=congrid(d0,sz(0)*set.expfact,sz(1)*set.expfact) 

sz=size(d1,/dim)

widget_control, id.draw,draw_xsize=sz(0),draw_ysize=sz(1),get_value=win
wset,win

if set.dolog eq 1 then begin
    pic0=alog10( (float(d1)>set.cont(0)<set.cont(1)) )
    mx=max(pic0)
    mn=min(pic0)
    d1b=fix( (pic0-mn)/(mx-mn) * 255.49)
endif else begin
    d1b=(d1-set.cont(0))/float(set.cont(1)-set.cont(0))*255. > 0 < 255
endelse

d2=bytarr(3,sz(0),sz(1))
for i=0,2 do d2(i,*,*)=d1b
tv,d2,/true

sim={pic:d2,dim:set.dim,sz:sz,del:set.dim/sz}

end


