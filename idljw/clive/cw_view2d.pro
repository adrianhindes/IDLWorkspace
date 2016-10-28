pro contournan, z,x,y,_extra=_extra
idx=where(finite(z) eq 0)
z2=z
if idx(0) ne -1 then z2(idx)=0.
contour,z,x,y,_extra=_extra
end
function minnan,f,imin
idx=where(finite(f))
if idx(0) eq -1 then begin
    imin=0
    mn=!values.f_nan
    return,mn
endif
mn=min(f(idx),imin)
imin=idx(imin)
return,mn
end
function maxnan,f,imin
idx=where(finite(f))
if idx(0) eq -1 then begin
    imin=0
    mn=!values.f_nan
    return,mn
endif
mn=max(f(idx),imin)
imin=idx(imin)
return,mn
end




function cw_view2d_getvalue, top

child=widget_info(top,/child)
widget_control, child, get_uvalue=basedata
if istag(basedata,'dblock') then dblock=basedata.dblock else $
  dblock={dummy:''}

id=basedata.id

widget_control, id.sel, get_value=sel
widget_control, id.bnds,get_value=bnds
widget_control, id.bndsfreeze,get_value=bndsfreeze
widget_control, id.contopt, get_value=contopt
widget_control, id.contlab,get_value=contlab
widget_control, id.tframe,get_value=tframe
widget_control, id.tbnds,get_value=tbnds
widget_control, id.tbndsfreeze,get_value=tbndsfreeze
widget_control, id.ncont,get_value=ncont
widget_control, id.serplot,get_value=serplot
widget_control, id.seropt,get_value=seropt
widget_control, id.sercont,get_value=sercont
widget_control, id.serfit,get_value=serfit


set={sel:sel,$
     bnds:bnds,$
     bndsfreeze:bndsfreeze,$
     contopt:contopt,$
     contlab:contlab,$
     tframe:tframe,$
     tbnds:tbnds,$
     tbndsfreeze:tbndsfreeze,$
     ncont:ncont,$
     serplot:serplot,$
     seropt:seropt,$
     sercont:sercont,$
     serfit:serfit}


if istag(dblock,'set') then dblock.set=set else $
  dblock=create_struct(dblock,'set',set)

return, dblock
end

pro cw_view2d_setvalue, top, dblock

child=widget_info(top,/child)
widget_control, child, get_uvalue=basedata
id=basedata.id

widget_control, id.bndsfreeze, get_value=frz
frz=frz[0]
widget_control, id.tbndsfreeze, get_value=tfrz
tfrz=tfrz[0]

if istag(dblock,'set') then begin
    set=dblock.set
    widget_control, id.sel, set_value=set.sel
if frz eq 0 then  widget_control, id.bnds,set_value=set.bnds
;    widget_control, id.bndsfreeze,set_value=set.bndsfreeze
    widget_control, id.contopt, set_value=set.contopt
    widget_control, id.contlab,set_value=set.contlab
    widget_control, id.tframe,set_value=set.tframe
if tfrz eq 0 then  widget_control, id.tbnds,set_value=set.tbnds
;    widget_control, id.tbndsfreeze,set_value=set.tbndsfreeze
    widget_control, id.ncont,set_value=set.ncont
    widget_control, id.serplot,set_value=set.serplot
    widget_control, id.seropt,set_value=set.seropt
    widget_control, id.sercont,set_value=set.sercont
    widget_control, id.serfit,set_value=set.serfit
    print, 'set settings'
endif
  

nt=n_elements(dblock.t)
nch=n_elements(dblock.ch)

if nch eq 1 then begin
    widget_control, id.tidx,set_slider_max=nt-1
    widget_control, id.chidx,set_slider_max=0

;    widget_control, id.chidx, set_value=0
;    widget_control, id.tidx, sensitive=0
;    widget_control, id.chidx, sensitive=0
;    widget_control, id.contour, sensitive=0
;    widget_control, id.tseriesbut, sensitive=0
;    widget_control, id.play, sensitive=0
endif else begin
    widget_control, id.tidx, sensitive=1
    widget_control, id.chidx, sensitive=1
    widget_control, id.contour, sensitive=1
;    widget_control, id.tseriesbut, sensitive=1
    widget_control, id.play, sensitive=1
    widget_control, id.tidx, set_slider_min=0, set_slider_max=nt-1
    widget_control, id.chidx, set_slider_min=0, set_slider_max=nch-1
endelse


if not istag(dblock,'darr') then begin
    yr=[minnan([dblock.data,dblock.data2]),$
        maxnan([dblock.data,dblock.data2])]
endif else begin
    nd=n_tags(dblock.darr)
    mnarr=fltarr(nd) & mxarr=fltarr(nd)
    for i=0,nd-1 do begin
        mnarr(i)=minnan(dblock.darr.(i))
        mxarr(i)=maxnan(dblock.darr.(i))
    endfor
    yr=[minnan(mnarr),maxnan(mxarr)]
    if yr(0) eq yr(1) then yr(1)=yr(0)+1
endelse



if istag(dblock,'yr') then yr=dblock.yr

; fix bnds to 2 dp
;expn = fix(alog(yr)/alog(10))
;base= round(yr/10.^expn * 100.) / 100.
;yr=base*10.^expn


if (frz ne 1) and (istag(dblock,'set') eq 0) then widget_control, id.bnds, set_value=yr

xr=[minnan(dblock.t),maxnan(dblock.t)]
if (tfrz ne 1) and (istag(dblock,'set') eq 0) then widget_control, id.tbnds, set_value=xr

bd={id:id,dblock:temporary(dblock)}
widget_control, child, set_uvalue=bd,/no_copy



if (id.lastact ne 0L) and (nch ne 1) then $
  cw_view2d_event, {id:id.lastact,handler:id.top} $
else $
  cw_view2d_event, {id:id.chidx,handler:id.top}
    
;cw_view2d_event, {id:id.tidx,handler:id.top}
;if size(dblock.darr,/n_dimensions) eq 2 then $
;catch, errc
;if errc ne 0 then begin
;    print, 'error huh'
;    goto, after
;endif




after:


end

pro cw_view2d_event, ev

common secondchanblock, data_ch2

;;; this is so that the print dialog will work
widget_control, ev.handler,get_uvalue=parent
if n_elements(parent) eq 0 then parent=ev.handler


child=widget_info(parent,/child)


widget_control, child, get_uvalue=bd,/no_copy
bd2=bd
widget_control, child, set_uvalue=bd2,/no_copy
id=bd.id
;dblock=basedata.dblock

widget_control, id.draw, get_value=win

if istag(bd.dblock,'title') then title=bd.dblock.title else title=''
if istag(bd.dblock,'xtitle') then xtitle=bd.dblock.xtitle
if istag(bd.dblock,'ytitle') then ytitle=bd.dblock.ytitle
if istag(bd.dblock,'ztitle') then ztitle=bd.dblock.ztitle


if !d.name ne 'PS' then wset,win

if (ev.id eq id.bnds) or (ev.id eq id.sel) or $
  (ev.id eq id.tbnds)  then begin
    nch=n_elements(bd.dblock.ch)
    widget_control, child, set_uvalue=bd,/no_copy
    if (id.lastact ne 0L) and (nch ne 1) then $
      cw_view2d_event, {id:id.lastact,handler:id.top} $
    else $
      cw_view2d_event, {id:id.chidx,handler:id.top}
    return
endif


if tag_names(ev,/structure_name) eq 'WIDGET_TIMER' then begin
    widget_control, id.tframe, get_value=playtime
    nt=n_elements(bd.dblock.t)
    tframe=playtime(1)
    widget_control, id.tidx, get_value=tidx
    cw_view2d_event, {id:id.tidx,handler:ev.handler}
    widget_control, id.play, get_uvalue=play
    
    if (tidx ne nt-1) and (play ne 0) then begin
        widget_control, id.tidx, set_value=tidx+playtime(0)
        widget_control, id.top, timer=tframe
    endif else begin
        widget_control, id.play, set_uvalue=0
    endelse
    widget_control, child, set_uvalue=bd,/no_copy
    return
endif

if ev.id eq id.play then begin
    widget_control, id.tframe, get_value=playtime
    nt=n_elements(bd.dblock.t)
    tframe=playtime(1)
    widget_control, id.tidx, get_value=tidx
    cw_view2d_event, {id:id.tidx,handler:ev.handler}
    widget_control, id.top, timer=tframe
    widget_control, id.play, set_uvalue=1
endif
    
if ev.id eq id.stop then begin
    widget_control, id.play, get_uvalue=play
    if n_elements(play) eq 0 then begin
        widget_control, child, set_uvalue=bd,/no_copy
        return
    endif
    if play eq 1 then begin
        widget_control, id.play, set_uvalue=0
    endif
endif


widget_control, id.serplot, get_value=serplot
serplot=serplot[0]
widget_control, id.sercont, get_value=sercont
sercont=sercont[0]

if (ev.id eq id.tidx) and (serplot eq 0) then begin
    widget_control, id.tidx, get_value=tidx
    widget_control, id.draw, get_value=win

    bd.id.lastact=id.tidx
    
    widget_control, id.sel, get_value=sel
    if sel eq 0 then widget_control, id.bnds, get_value=yr else begin
        if not istag(bd.dblock,'darr') then begin
            yr=[minnan([bd.dblock.data(tidx,*),bd.dblock.data2(tidx,*)]),$
                maxnan([bd.dblock.data(tidx,*),bd.dblock.data2(tidx,*)])]
        endif else begin
            nd=n_tags(bd.dblock.darr)
            mnarr=fltarr(nd) & mxarr=fltarr(nd)
            for i=0,nd-1 do begin
                mnarr(i)=minnan((bd.dblock.darr.(i))[tidx,*])
                mxarr(i)=maxnan((bd.dblock.darr.(i))[tidx,*])
            endfor
            yr=[minnan(mnarr),maxnan(mxarr)]
        endelse
    endelse

if !d.name ne 'PS' then wset,win
    if not istag(bd.dblock,'darr') then begin
        plot, bd.dblock.ch, bd.dblock.data(tidx,*), $
              title=bd.dblock.t[tidx],yrange=yr,ystyle=1
        oplot, bd.dblock.ch, bd.dblock.data2(tidx,*),color=2
    endif else begin
        nd=n_tags(bd.dblock.darr)

        title=title+string(' t = ',bd.dblock.t(tidx)*1.e3,format='(A,F7.2)')
        for i=0,nd-1 do begin
            if i eq 0 then plot, bd.dblock.ch, (bd.dblock.darr.(i))(tidx,*),$
              yrange=yr,ystyle=1,xstyle=1,$
              title=title,xtitle=ytitle,ytitle=ztitle,psym=-4 $
            else $
              oplot,  bd.dblock.ch, (bd.dblock.darr.(i))(tidx,*),color=i+1,psym=-4
        endfor
    endelse
end

if (ev.id eq id.chidx) and (serplot eq 0) then begin
    widget_control, id.chidx, get_value=chidx
    widget_control, id.draw, get_value=win

    bd.id.lastact=id.chidx

    widget_control, id.tbnds,get_value=xr
    widget_control, id.sel, get_value=sel
    if sel eq 0 then widget_control, id.bnds, get_value=yr else begin
        if not istag(bd.dblock,'darr') then begin
            yr=[minnan([bd.dblock.data(*,chidx),bd.dblock.data2(*,chidx)]),$
                maxnan([bd.dblock.data(*,chidx),bd.dblock.data2(*,chidx)])]
        endif else begin
            nd=n_tags(bd.dblock.darr)
            mnarr=fltarr(nd) & mxarr=fltarr(nd)
            ii0=value_locate(bd.dblock.t,xr(0))
            ii1=value_locate(bd.dblock.t,xr(1))

            for i=0,nd-1 do begin
                mnarr(i)=minnan((bd.dblock.darr.(i))[ii0:ii1,chidx])
                mxarr(i)=maxnan((bd.dblock.darr.(i))[ii0:ii1,chidx])
            endfor
            yr=[minnan(mnarr),maxnan(mxarr)]
        endelse
    endelse
;stop
    if !d.name ne 'PS' then wset,win

    if not istag(bd.dblock,'darr') then begin
        plot, bd.dblock.t, bd.dblock.data(*,chidx), $
              title=bd.dblock.ch[chidx],yrange=yr,ystyle=1,xrange=xr,$
              xsty=1,psym=-4
        oplot, bd.dblock.t, bd.dblock.data2(*,chidx),color=2,psym=-4
    endif else begin
        nd=n_tags(bd.dblock.darr)

        title=title+string(' pos = ',bd.dblock.ch(chidx),format='(A,G0)')

        for i=0,nd-1 do begin
            if i eq 0 then plot, bd.dblock.t, (bd.dblock.darr.(i))(*,chidx),$
              yrange=yr,ystyle=1,xstyle=1,xrange=xr,$
              title=title,xtitle=xtitle,ytitle=ztitle $
            else $
              oplot,  bd.dblock.t, (bd.dblock.darr.(i))(*,chidx),color=i+1
        endfor
    endelse
;    tek_color

end


if ev.id eq id.tseriesbut then begin
    widget_control, id.bnds, get_value=yr
    if not istag(bd.dblock,'darr') then val=bd.dblock.data else $
      val = bd.dblock.darr.(0)
    data={data:(val > yr(0)) < yr(1),$
          time:bd.dblock.t,$
          channels:indgen(n_elements(bd.dblock.ch)),$
          x_title: 'time (ms)',$
          y_title: 'position',$
          z_title: '',$
          title:''}

    if not istag(bd.dblock,'darr') then $
      val2=bd.dblock.data2 > yr(0) < yr(1) else $
      begin
        if n_tags(bd.dblock.darr) gt 1 then $
          val2 = bd.dblock.darr.(1) > yr(0) < yr(1) else $
          val2=0
    endelse

    
    data_ch2 = val2

    if xregistered('t_series') then $
      widget_control, id.tseriestlb, set_value=data $
      else begin
        t_series, data, apptlb=apptlb
        bd.id.tseriestlb=apptlb
;        widget_control, child, set_uvalue={id:id,dblock:dblock}
    endelse
endif
    
if (ev.id eq id.contour) and (serplot eq 0) then begin

    widget_control, id.bnds, get_value=yr 
    widget_control, id.tbnds, get_value=xr 

    widget_control, id.contopt,get_value=disc
    widget_control, id.ncont, get_value=ncont

    bd.id.lastact=id.contour

;    if (where(finite(bd.dblock.darr.(0)) eq 0))[0] ne -1 then begin
;        widget_control, child, set_uvalue=bd,/no_copy
;        return
;    endif
    zr=[yr(0),yr(1)]
    if disc eq 1 then nlev=ncont else nlev=50
      lev=linspace(zr(0),zr(1),nlev)
    
    common remblock, ctl
    if n_elements(ctl) eq 0 then ctl=-1
    if !d.name ne 'PS' then begin
        ccol=linspace(32,!d.table_size-1,nlev)
        if ctl ne 4 then begin
            loadct,4,bottom=32
            tek_color
        endif
        ctl=4
    endif else begin
;        ccol=linspace(!d.table_size-1,32,nlev)
        ccol=linspace(32,!d.table_size-1,nlev)
        if ctl ne 0 then begin
            loadct,4,bottom=32
;            loadct,0,bottom=32
            tek_color
            ctfix
        endif
        ctl=0
    endelse

    !p.color=1
    !p.background=0

    
    xthres=1e5
    nd=n_tags(bd.dblock.darr)
    if n_elements(bd.dblock.t) gt xthres then begin
        nt=n_elements(bd.dblock.t)
        mult=ceil(nt/xthres)
        nt2=nt/mult

        nch=n_elements(bd.dblock.ch)
        d0=(congrid(bd.dblock.darr.(0),nt2,nch) > yr(0)) < yr(1)
        if nd gt 1 then d1=$
          (congrid(bd.dblock.darr.(1),nt2,nch) > yr(0)) < yr(1)
        tr=congrid(bd.dblock.t,nt2)
    endif else begin
        d0=(bd.dblock.darr.(0) > yr(0)) < yr(1)
        if nd gt 1 then d1=(bd.dblock.darr.(1) > yr(0)) < yr(1)
        tr=bd.dblock.t
    endelse

    contournan, d0, tr, bd.dblock.ch,$
             levels=lev,c_col=ccol,/fill,xsty=1,ysty=1,xrange=xr,$
             xtitle=xtitle,ytitle=ytitle,title=title
    
    if ncont ne 0 then begin

        widget_control, id.contlab,get_value=lab
        if lab eq 1 then labs=replicate(1,ncont) else $
          labs=replicate(0,ncont)

        lev=linspace(zr(0),zr(1),ncont)
        contournan, d0, tr, bd.dblock.ch,$
                 levels=lev,/overplot,xrange=xr,$
                 c_lab=labs
        if nd gt 1 then $
          contournan, d1, tr, bd.dblock.ch,$
          levels=lev,/overplot,c_linesty=replicate(2,10),xrange=xr
    endif
endif

if ( (ev.id eq id.tidx) or (ev.id eq id.chidx) ) and $
  (serplot eq 1) and (sercont eq 0) then begin
    bd.id.lastact=ev.id
    if istag(bd.dblock,'darr') then nd=n_tags(bd.dblock.darr) else nd=1
    if nd gt 1 then begin
        widget_control, id.tidx, get_value=tidx
        widget_control, id.chidx, get_value=chidx
        x=bd.dblock.serarr
        y=fltarr(nd)
        ndim=size(bd.dblock.darr.(0),/n_dim)
        dim=size(bd.dblock.darr.(0),/dim)
        ndim2=2
        if (ndim eq 1) then ndim2=1
        if (ndim eq 2) then if (dim(0) eq 1) or (dim(1) eq 1) then ndim2=1
        if ndim2 eq 1 then begin
            nch=n_elements(bd.dblock.ch)
            for i=0,nd-1 do $
              y(i) = (reform(bd.dblock.darr.(i),$
                             n_elements(bd.dblock.darr.(i)) ))[tidx]
        endif else $
          for i=0,nd-1 do $
          y(i) = (bd.dblock.darr.(i))(tidx,chidx)
        idx=sort(x)
        x=x(idx)
        y=y(idx)

        widget_control, id.sel, get_value=sel
        if sel eq 0 then widget_control, id.bnds, get_value=yr else $
          yr=[minnan(y),maxnan(y)]
        
        title=title+string(' pos = ',bd.dblock.ch(chidx),$
                           't = ',bd.dblock.t(tidx)*1.e3,$
                           format='(A,F7.2,A,F7.2)')
        plot, x, y, title=title, xtitle=bd.dblock.sertitle,$
              ytitle=ztitle,xsty=1,ysty=1,yrange=yr,$
              psym=4,/nodata
        plots,x,y,color=idx+1,psym=4

        widget_control, id.serfit, get_value=serfit
        serfit=serfit[0]
        if serfit eq 1 then $
          fitgaussian,x,y,xi,yi,qty=ztitle,/nolast else $
          geninterp,x,y,xi,yi
        oplot,xi,yi,linesty=1,col=2
    endif
endif

if ( (ev.id eq id.tidx) or (ev.id eq id.chidx) ) and $
  (serplot eq 1) and (sercont eq 1) then begin
    bd2=bd

    widget_control, child, set_uvalue=bd2,/no_copy
    widget_control, id.bnds, get_value=zr 
    
    bd.id.lastact=ev.id

    if (where(finite(bd.dblock.darr.(0)) eq 0))[0] ne -1 then begin
        widget_control, child, set_uvalue=bd,/no_copy
        return
    endif

    widget_control, id.seropt,get_value=seropt
    nt=n_elements(bd.dblock.t)
    nd=n_tags(bd.dblock.darr)

    ser=bd.dblock.serarr
    seru=ser(uniq(ser,sort(ser)))
    nseru=n_elements(seru)

    nch=n_elements(bd.dblock.ch)
    if seropt eq 0 then begin
        ; freeze time
        widget_control, id.tidx, get_value=tidx
        dat=fltarr(nch,nseru)
        for i=0,nseru-1 do begin
            idx=where(seru(i) eq ser)
            nidx=n_elements(idx)
            arr=fltarr(nidx,nch)
            for j=0,nidx-1 do arr(j,*)=bd.dblock.darr.(idx(j))[tidx,*]
            for j=0,nch-1 do dat(j,i)=median(arr(*,j))
        endfor
        ytitle=bd.dblock.sertitle
        xtitle=bd.dblock.ytitle
        title=title+' t='+string(bd.dblock.t(tidx),format='(E10.3)')
        y=seru
        x=bd.dblock.ch
    endif
    if seropt eq 1 then begin
        ; freeze channel
        widget_control, id.chidx, get_value=chidx
        dat=fltarr(nt,nseru)
        for i=0,nseru-1 do begin
            idx=where(seru(i) eq ser)
            nidx=n_elements(idx)
            arr=fltarr(nidx,nt)
            for j=0,nidx-1 do arr(j,*)=bd.dblock.darr.(idx(j))[*,chidx]
            for j=0,nt-1 do dat(j,i)=median(arr(*,j))
        endfor

        ytitle=bd.dblock.sertitle
        xtitle=bd.dblock.xtitle
        title=title+' ch='+string(bd.dblock.ch(chidx),format='(I0)')
        y=seru
        x=bd.dblock.t
        widget_control, id.tbnds, get_value=xr
    endif

    widget_control, id.contopt,get_value=disc
    widget_control, id.ncont,get_value=ncont
    disc=disc[0]

    if disc eq 1 then nlev=ncont else nlev=50
    lev=linspace(zr(0),zr(1),nlev)
    
    common remblock, ctl
    if n_elements(ctl) eq 0 then ctl=-1
    if !d.name ne 'PS' then begin
        ccol=linspace(32,!d.table_size-1,nlev)
        if ctl ne 4 then begin
            loadct,4,bottom=32
            tek_color
        endif
        ctl=4
    endif else begin
;        ccol=linspace(!d.table_size-1,32,nlev)
        ccol=linspace(32,!d.table_size-1,nlev)
        if ctl ne 0 then begin
;            loadct,0,bottom=32
            loadct,4,bottom=32
            tek_color
            ctfix
        endif
        ctl=0
    endelse

    !p.color=1
    !p.background=0

    contournan, dat, x,y,$
             levels=lev,c_col=ccol,/fill,xsty=1,xrange=xr,ysty=1,$
             xtitle=xtitle,ytitle=ytitle,title=title
    
    widget_control, id.ncont, get_value=ncont
    if ncont ne 0 then begin
        lev=linspace(zr(0),zr(1),ncont)

        widget_control, id.contlab,get_value=lab
        if lab eq 1 then labs=replicate(1,ncont) else $
          labs=replicate(0,ncont)

        contournan, dat, x,y,$
                 levels=lev,/overplot,xrange=xr,ysty=1,$
                 c_label=labs
    endif

endif

if ev.id eq id.print then begin

    widget_control, id.print, get_uvalue=uv
    if n_elements(uv) eq 0 then uv={title:'',fname:'idl.eps',printer:0}

    id.pwid.top=widget_base(title='Print options',$
                            group_leader=id.top,$
                            event_pro='cw_view2d_event',$
                            /col,/modal,uvalue=id.top)
    
    r1=widget_base(id.pwid.top,/row)
    pr=['prl_helen','prl_h1','scu_colourlw','eps']
    id.pwid.printer=cw_bgroup(r1,pr, /excl, set_value=[uv.printer],uvalue=pr,$
                              col=3)
    id.pwid.fname=cw_field(r1,title='fname:',/string,xsize=10,$
                          value=uv.fname)
    r2=widget_base(id.pwid.top,/row)
    id.pwid.title=cw_field(r2,title='title:',/string,xsize=30,$
                          value=uv.title)
    r2a=widget_base(id.pwid.top,/row)
    id.pwid.size=cw_array(r2a,title='Dimensions (cm): ',xsize=7,$
                          value=[17.8,12.7])
    id.pwid.fontsize=cw_field(r2a,title='Font size (pt)',xsize=5,value=12)
    r3=widget_base(id.pwid.top,/row)
    id.pwid.print=widget_button(r3,value='Print')
    id.pwid.cancel=widget_button(r3,value='Cancel')
    
        

    widget_control, id.pwid.top,/realize 
    bd.id=id
endif

if ev.id eq id.pwid.cancel then begin
    widget_control, id.pwid.printer,get_value=printer
    widget_control, id.pwid.fname,get_value=fname
    widget_control, id.pwid.title,get_value=title
    widget_control, id.print, set_uvalue={fname:fname,title:title,$
                                         printer:printer}
    widget_control, id.pwid.top,/destroy
endif

if ev.id eq id.pwid.print then begin
    widget_control, id.pwid.fname,get_value=fname
    widget_control, id.pwid.title,get_value=title
    widget_control, id.pwid.size,get_value=psize
    widget_control, id.pwid.fontsize,get_value=fontsize
    widget_control, id.pwid.printer,get_value=pi
    widget_control, id.pwid.printer,get_uvalue=parr
    printer=parr(pi)

    set_plot,'ps'
    !p.font=0
    if printer eq 'eps' then begin
        xoff=(21.0-psize(0))/2.
        yoff=(29.6-psize(1))/2.
        device,file=fname,/color,/enc,font_size=fontsize,$
               xsize=psize(0),ysize=psize(1),xoff=xoff,yoff=yoff
        print, 'enc'
    endif else begin
        if !version.os eq 'VMS' then fname='idl.ps' else $
          fname='~/idl.ps'
        device,file=fname,/color,/portrait,encapsulated=0
        print, 'noenc'
    endelse
    tek_color
    ctfix
    !p.color=1
    !p.background=0

    titlestore=bd.dblock.title
    bd.dblock.title=title
    bd2=bd
    widget_control, child,set_uvalue=bd2

    cw_view2d_event, {id:id.lastact,handler:id.top} 

    bd.dblock.title=titlestore
    bd2=bd
    widget_control, child,set_uvalue=bd2

    device,/close
    set_plot,'x'
    print, 'before pfont-1'
    !p.font=-1
    print, 'after pfont-1'
    tek_color
    !p.color=1
    !p.background=0
    if printer eq 'eps' then begin
        fnamej=fname+'.jpg'
        spw='/usr/bin/gs -sDEVICE=jpeg -sOutputFile='+fnamej+' -dNOPAUSE -dBATCH -dSAFEr -dJPEGQ=85 -r300 -dEPSCrop -dTextAlphaBits=4 -dGraphicsAlphaBits=4 '+fname
;        stop
;        print,spw
        spawn,spw
    endif

    if printer ne 'eps' then begin
        if (!version.os eq 'OSF') or (!version.os eq 'linux') then $
            cmd='rsh rsphy6 lpr -P'+printer+' ~/idl.ps'
        if !version.os eq 'VMS' then $
            cmd='print /queue='+printer+' /delete idl.ps'
        spawn,cmd
        print, 'queued idl.ps'
    endif else begin
        if !version.os eq 'OSF' then $
          spawn,'ghostview '+fname
    endelse
            

    cw_view2d_event, {id:id.pwid.cancel,handler:id.top} 
endif

widget_control, child, set_uvalue=bd,/no_copy
    
end



pro cw_view2d_kill, theid
child=widget_info(theid,/child)
widget_control, child, get_uvalue=basedata
id=basedata.id
if xregistered('t_series') then widget_control, id.tseriestlb, /destroy
end



function cw_view2d, base, value=value,xsize=xsize,ysize=ysize

default, xsize, 640
default, ysize, 480
id={top:0L,draw:0L, tidx:0L,sel:0L,bnds:0L,tseriesbut:0L,tseriestlb:0L,$
   chidx:0L,play:0L,tframe:0L,stop:0L,contour:0L,ncont:0L,lastact:0L,$
   tbnds:0L,bndsfreeze:0L,tbndsfreeze:0L,contopt:0L,contlab:0L,$
   serplot:0L,seropt:0L,sercont:0L,serfit:0L,print:0L,$
   pwid:{top:0L,printer:0L,fname:0L,title:0L,$
         print:0L,cancel:0L,size:0L,fontsize:0L}}
id.top=widget_base(base,/row,$
                  event_pro='cw_view2d_event',$
                  pro_set_value='cw_view2d_setvalue',$
                  func_get_value='cw_view2d_getvalue')

b1=widget_base(id.top,/col)
id.chidx=widget_slider(b1,/vertical,minimum=0,maximum=100,ysize=ysize,$
                       /drag,scroll=1)
b2=widget_base(id.top,/col)
id.draw=widget_draw(b2,xsize=xsize,ysize=ysize)
id.tidx=widget_slider(b2,minimum=0,maximum=100,xsize=xsize,/drag,scroll=1)
bbase=widget_base(b2,/row)
id.sel=cw_bgroup(bbase,['Fxd','Var'],/exclusive,row=1)
widget_control, id.sel, set_value=1
id.bnds=cw_array(bbase,title='zbnds: ',value=[0.,1.],xsize=8,$
                format='(G0)')
id.bndsfreeze=cw_bgroup(bbase,['frz'],/nonexcl,set_value=[0])
id.contopt=cw_bgroup(bbase,['dsc'],/nonexcl,set_value=[0])
id.contlab=cw_bgroup(bbase,['lab'],/nonexcl,set_value=[0])
;id.tseriesbut=widget_button(bbase,value='t_series')
id.contour=widget_button(bbase,value='contour')
bbase2=widget_base(b2,/row)
id.play=widget_button(bbase2,value='Play')
id.stop=widget_button(bbase2,value='Stop')
id.tframe=cw_array(bbase2,title='Play f/t',value=[1.,0.],xsize=4)
id.tbnds=cw_array(bbase2,title='tbnds:',value=[0,1],xsize=10,$
                 format='(G0)')
id.tbndsfreeze=cw_bgroup(bbase2,['frz'],/nonexcl,set_value=[0])
id.ncont=cw_field(bbase2,title='ncont:',value=7,/integer,xsize=3)
bbase3=widget_base(b2,/row)
id.serplot=cw_bgroup(bbase3,['Series plot'],/nonexcl,set_value=[0])
id.seropt=cw_bgroup(bbase3,['Time','Channel'],/excl,set_value=[0],$
                   label_left='Freeze:',col=2)
id.sercont=cw_bgroup(bbase3,['Contour'],/nonexcl,set_value=[0])
id.serfit=cw_bgroup(bbase3,['Fit'],/nonexcl,set_value=[0])
id.print=widget_button(bbase3,value='Print')


child=widget_info(id.top,/child)
widget_control, child, set_uvalue={id:id}
if keyword_set(value) then cw_view2d_setvalue, id.top, value
return,id.top
end


