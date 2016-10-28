@~/idl/clive/plotit


pro wimage_event, ev
common aab,t,str,info
common wimagecb, id
common aac, res,resnew
common zoomb, x0, rngorig,done1

if ev.id eq id.up or ev.id eq id.down then begin
    if ev.id eq id.up then off=1
    if ev.id eq id.down then off=-1
    widget_control, id.sh,get_value=shot
    shot=shot+off
    widget_control, id.sh,set_value=shot
    wimage_event,{id:id.tbar.vslide}
endif


if ev.id eq id.sh then begin
    widget_control,id.sh,get_value=sh
    widget_control,id.db,get_value=db & db=db(0)
    im=getimgnew(sh,0,info=info,/getinfo,str=str,/nostop,db=db)
    n=info.num_images
    t=findgen(n)*str.dt + str.t0
;    putsel,id.tbar, min(t),max(t)
;    setsel,id.tbar
    rngorig=[min(t),max(t)]

endif

if ev.id eq id.tbar.vslide then bar=id.tbar
if ev.id eq id.xbar.vslide then bar=id.xbar
if ev.id eq id.ybar.vslide then bar=id.ybar

dopl=0
if n_elements(bar) ne 0 then begin
    setsel,bar
    dopl=1
end

act=0
for k=0,2 do begin
    if k eq 0 then base=id.tbar
    if k eq 1 then base=id.xbar
    if k eq 2 then base=id.ybar
    if ev.id eq base.vplus then begin
        base2=base
        act=1
        kk=k
    endif
    if ev.id eq base.vminus then begin
        base2=base
        act=-1
        kk=k
    endif
endfor

if act ne 0 then begin
    widget_control, base2.vsel,get_value=vsel
    widget_control, base2.vmin,get_value=vmin
    widget_control, base2.vmax,get_value=vmax
    widget_control, base2.vnstep,get_value=vnstep
    if kk eq 0 then xx=t
    if kk eq 1 then xx=res.r1
    if kk eq 2 then xx=res.z1
    ii=value_locate3(xx,vsel)
    ii=ii+vnstep*act
    ii=ii>0<(n_elements(xx)-1)
    vsel=xx(ii)
    vslide=(vsel-vmin)/(vmax-vmin)*1000.
    widget_control,base2.vsel,set_value=vsel
    widget_control,base2.vslide,set_value=vslide
;    stop
;    stop
    dopl=1
endif

widget_control, id.qty,get_value=qty,get_uvalue=sqty & qty=qty(0) & sqty=sqty(qty)
if dopl eq 1 and qty gt 0 then begin

    widget_control,id.demodplot,get_value=i,get_uvalue=a  & demodplot=a(i)
    if demodplot eq 'only2' then ares=res
    if demodplot eq 'only1' then ares=resnew

    if sqty eq 'ang' then z=ares.ang
    if sqty eq 'eps' then z=ares.eps
    if sqty eq 'linfrac' then z=ares.lin

    if sqty eq 'inten' then z=ares.inten
    if sqty eq 'dopc' then z=ares.dopc

    

    t=ares.t
    r1=ares.r1
    z1=ares.z1

    getsel,id.tbar,tw
    getsel,id.xbar,xw
    getsel,id.ybar,yw

    widget_control,id.zr,get_value=zr

    if sqty eq 'ang' then     widget_control,id.zrang,get_value=zr
    if sqty eq 'eps' then     widget_control,id.zreps,get_value=zr
    if sqty eq 'linfrac' then     widget_control,id.zrlin,get_value=zr
    if sqty eq 'inten' then     widget_control,id.zrint,get_value=zr
    if sqty eq 'dopc' then     widget_control,id.zrdop,get_value=zr

    widget_control,id.type,get_value=itype,get_uvalue=atype  & type=atype(itype)

;    widget_control,id.auxopt,get_value=i,get_uvalue=a  & auxopt=a(i)
    widget_control,id.zropt,get_value=i,get_uvalue=a  & zropt=a(i)
    widget_control,id.aux,get_value=i,get_uvalue=a  & aux=a(i)

    widget_control,id.sh,get_value=sh
    widget_control,id.db,get_value=db& db=db(0)
    if sqty eq 'carriers' then begin
        it=   fix ((tw.vsel - str.t0)/str.dt)

        ixa=value_locate3(r1,xw.vsel)
        iya=value_locate3(z1,yw.vsel)
        if str.flc0per gt 10 then only2=1 else only2=0

        newdemodflc,sh,it,/plotcar,cix=ixa,ciy=iya,only2=only2,db=db
        return
    endif



    par={type:type,tw:tw,xw:xw,yw:yw,zr:zr,zropt:zropt}

    if aux ne 'none' then begin
        common cbshot, shotc,dbc, isconnected
        shotc=sh
        dbc='kstar'
        if aux eq 'ip' then daux=cgetdata('\PCRC03')
        if aux eq 'nbi1' then daux=cgetdata('\NB11_I0')
        if aux eq 'nbi2' then daux=cgetdata('\NB12_I0')
        if aux eq 'nbi1_v' then daux=cgetdata('\NB11_VG1')
        if aux eq 'nbi2_v' then daux=cgetdata('\NB12_VG1')
;        if aux eq 'dalpha' then daux=cgetdata('\POL_HA03')
        if aux eq 'dalpha' then daux=cgetdata('\EC1_RFFWD1')

        widget_control,id.zraux,get_value=zraux

        par=create_struct(par,'aux',daux,'zraux',zraux)


    endif

    widget_control,id.plot,get_value=win
    wset,win
    device,decomp=0
    tek_color
    plotit, z,ares.r1,ares.z1,ares.t,par=par
endif

if dopl eq 1 and qty eq 0 then begin
    widget_control,id.sh,get_value=sh
    widget_control,id.db,get_value=db& db=db(0)

    getsel,id.tbar,tsel
    i=value_locate(t,tsel.vsel)
    im=getimgnew(sh,i,db=db)
    widget_control,id.plot,get_value=win
    wset,win
    device,decomp=0
    tek_color
    widget_control,id.whatplot,get_value=whatplot
    if whatplot eq -1 then begin
        widget_control,id.zr,get_value=zr
        imgplot,im,/cb,zr=zr,title=i
    endif
    if whatplot eq -2 or whatplot ge 0 then begin
        
        if strmid(str.cellno,0,3) eq 'mse' then lam=659.89e-9 else lam=529e-9
;        simg=getimgnew(sh,20)*1.0
        simg=im

        newdemod,simg,cars,sh=sh,lam=lam,doplot=whatplot eq -2,demodtype='basicd',ix=ix,iy=iy,p=str,ifr=i,db=db
        getptsnew,rarr=r,zarr=z,str=str,ix=ix,iy=iy,pts=pts
;contourn2,r
        if whatplot ge 0 then begin
            imgplot,abs(cars(*,*,whatplot)),xsty=1,ysty=1
            contour,r,xsty=1,ysty=1,/noer,nl=10,c_lab=replicate(1,10)
        endif
    endif
endif


if ev.id eq id.plot then begin

   if ev.release ne 0 then return
   if ev.press ne 1 then begin
      rng=rngorig
      done1=0
   endif else begin
      res=convert_coord(ev.x,ev.y,/device,/to_data)
      if n_elements(done1) ne 0 then if done1 eq 1 then begin
         rng=[x0,res(0)]
         idx=sort(rng)
         rng=rng(idx)
         done1=0
      endif else begin
         x0=res(0)
         done1=1
         return
      endelse
   endelse

   widget_control,id.plot,get_uvalue=idd

   putsel,id.tbar, rng(0),rng(1)
   wimage_event,{id:idd}
   return
      
endif


if ev.id eq id.thist then begin
    widget_control,id.plot,get_value=win
    wset,win
    device,decomp=0
    tek_color

    widget_control,id.sh,get_value=sh
    widget_control,id.db,get_value=db& db=db(0)
    
    bar=id.tbar
    widget_control,bar.vmin,get_value=vmin
    widget_control,bar.vmax,get_value=vmax
    tr=[vmin,vmax]
    loadallnew,sh,tr=tr,/nostop,db=db
    widget_control,id.plot,set_uvalue=id.thist
endif

if ev.id eq id.load3d then begin

    widget_control,id.sh,get_value=sh
    bar=id.tbar
    widget_control,bar.vmin,get_value=vmin
    widget_control,bar.vmax,get_value=vmax
    tr=[vmin,vmax]

    widget_control,id.cache,get_value=cache
    widget_control,id.nskip,get_value=nskip
    cacheread=0
    cachewrite=0
    if cache eq 0 then cacheread=1
    if cache eq 1 then cachewrite=1
    if cache eq 3 then begin
       cachewrite=1
       cacheread=1
    endif

    if str.flc0per gt 10 then only2=1 else only2=0
    if sh gt 9000 then only2=1 ; new campaign only2 always one

   newdemodflcshot,sh,tr,res=res,cacheread=cacheread,cachewrite=cachewrite,only2=only2,nskip=nskip

    putsel,id.xbar, min(res.r1),max(res.r1)
    setsel,id.xbar
    putsel,id.ybar, min(res.z1),max(res.z1)
    setsel,id.ybar



    wimage_event,{id:id.tbar.vslide}
endif

if ev.id eq id.load3d2 then begin

    widget_control,id.sh,get_value=sh
    bar=id.tbar
    widget_control,bar.vmin,get_value=vmin
    widget_control,bar.vmax,get_value=vmax
    tr=[vmin,vmax]

    widget_control,id.cache,get_value=cache
    widget_control,id.nsm,get_value=nsm
    cacheread=0
    cachewrite=0
    if cache eq 0 then cacheread=1
    if cache eq 1 then cachewrite=1
    if cache eq 3 then begin
       cachewrite=1
       cacheread=1
    endif

    widget_control,id.nskip,get_value=nskip

    newdemodflcshot,sh,tr,res=resnew,cacheread=cacheread,cachewrite=cachewrite,nskip=nskip,rresref=res, nsm=nsm

;    putsel,id.xbar, min(res.r1),max(res.r1)
;    setsel,id.xbar
;    putsel,id.ybar, min(res.z1),max(res.z1)
;    setsel,id.ybar



    wimage_event,{id:id.tbar.vslide}
endif



if dopl eq 1 or ev.id eq id.thist then begin
    savewidget,id,getenv('HOME')+'/idl/clive/wimage_default.sav'
endif


end



pro getsel,bar,sel
widget_control,bar.vmin,get_value=vmin
widget_control,bar.vmax,get_value=vmax
widget_control,bar.vsel,get_value=vsel
sel={vmin:vmin,vmax:vmax,vsel:vsel,vr:[vmin,vmax]}
end

pro putsel,bar,vmin,vmax
widget_control,bar.vmin,set_value=vmin
widget_control,bar.vmax,set_value=vmax
end

pro setsel,bar
    widget_control,bar.vslide,get_value=v
    widget_control,bar.vmin,get_value=vmin
    widget_control,bar.vmax,get_value=vmax
    vsel=vmin+(vmax-vmin)*v/1000.
    widget_control,bar.vsel,set_value=vsel
end

pro makebar,top,id,lab=lab,vmin=vmin,vmax=vmax,vsel=vsel
c1=widget_base(top,/row)
dum=widget_label(c1,value=lab)
id.vmin=cw_field(c1,/float,value=vmin,xsize=5,title='')
id.vslide =WIDGET_SLIDER( c1,MAXIMUM=1000 ,MINIMUM=0 ,SCROLL=0.01, VALUE=0.3, XSIZE=200, /SUPPRESS_VALUE )
id.vmax=cw_field(c1,/float,value=vmax,xsize=5,title='')
id.vsel=cw_field(c1,/float,value=vsel,xsize=7,title='')
id.vplus=widget_button(c1,value='+')
id.vminus=widget_button(c1,value='-')
id.vnstep=cw_field(c1,/float,value=1,xsize=2,title='')
end

pro wimage

common wimagecb, id


bar={vmin:0L,vmax:0L,vslide:0L,vsel:0L,vplus:0L,vminus:0L,vnstep:0L}
id={top:0L, plot:0L,sh:0L,db:0L, tbar:bar,xbar:bar,ybar:bar,zr:0L,thist:0L,whatplot:0L,type:0L,load3d:0L,cache:0L,qty:0L,aux:0L,zrang:0L,zreps:0L,zrlin:0L,zrdop:0L,zrint:0L,zropt:0L,zraux:0L,nsm:0L,load3d2:0L,nskip:0L,demodplot:0L,down:0L,up:0L}

id.top=widget_base(/row,title='wimage')
id.plot=widget_draw(id.top,xsize=600,ysize=600,/button_events,uvalue=0)
c2=widget_base(id.top,/column)
rw=widget_base(c2,/row)
id.sh=cw_field(rw,title='shot No.: ',/long,value=7426,xsize=5,/return_events)
id.down=widget_button(rw,value='<')
id.up=widget_button(rw,value='>')

id.db=cw_field(rw,title='db: ',/string,value='k',xsize=3)


id.zr=cw_array(rw,title='zr:',value=[0,65535],xsize=9)
id.thist=widget_button(rw,value='thist')
id.whatplot=cw_field(rw,title='whatplot:',value=-1,/long,xsize=9)


rw=widget_base(c2,/row)
id.zrang=cw_array(rw,title='zrang:',value=[50,70],xsize=7)
id.zreps=cw_array(rw,title='zreps:',value=[-15,15],xsize=7)
id.zrlin=cw_array(rw,title='zrlin:',value=[0,0.7],xsize=7)
id.zrdop=cw_array(rw,title='zrdop:',value=[-180,180],xsize=7)

rw=widget_base(c2,/row)
id.zrint=cw_array(rw,title='zrint:',value=[0,5000],xsize=7)
id.zraux=cw_array(rw,title='zraux:',value=[0,5],xsize=7)

arr=['var','fixed']
id.zropt=cw_bgroup(rw,arr,/exclusive,set_value=0,uvalue=arr,column=2)

arr=['only2','only1','both']
id.demodplot=cw_bgroup(rw,arr,/exclusive,set_value=0,uvalue=arr,column=3)




;arr=['auxon','auxoff']
;id.auxopt=cw_bgroup(rw,arr,/exclusive,set_value=0,uvalue=arr,column=2)


makebar,c2,bar,lab='t' & id.tbar=bar
makebar,c2,bar,lab='x' & id.xbar=bar
makebar,c2,bar,lab='y' & id.ybar=bar

rw=widget_base(c2,/row)
arr=['t','x','y','tx','ty','xy']
id.type=cw_bgroup(rw,arr,/exclusive,column=6,set_value=0,uvalue=arr)

id.load3d=widget_button(rw,value='load3d')
id.nskip=cw_field(rw,title='nskip: ',/long,value=1,xsize=5)

rw=widget_base(c2,/row)



id.nsm=cw_field(rw,title='nsm: ',/long,value=1,xsize=5)
id.load3d2=widget_button(rw,value='load3d-everytime')

arr=['cacheread','cachewrite','none','both']
id.cache=cw_bgroup(rw,arr,/exclusive,set_value=0,uvalue=arr,column=3)


arr=['raw','ang','eps','linfrac','inten','dopc','carriers']
id.qty=cw_bgroup(c2,arr,/exclusive,set_value=0,uvalue=arr,column=7,label_left='demod qty:')

arr=['none','nbi1','nbi2','nbi1_v','nbi2_v','ip','dalpha']
id.aux=cw_bgroup(c2,arr,/exclusive,set_value=0,uvalue=arr,column=7,label_left='aux. qty: ')


widget_control,c2,/realize
loadwidget,id,getenv('HOME')+'/idl/clive/wimage_default.sav'
device,decomp=0
;xmanager,catch=0
xmanager,'wimage',id.top;l,catch=0;,/no_block;,catch=0
end
