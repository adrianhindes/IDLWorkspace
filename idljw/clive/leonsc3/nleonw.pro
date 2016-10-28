 ;;
 @distort
 @hidelines ;;
 @convwrl
 @cutd0
 @leon_loadimg
 @savewidget_nlw
 @loadwidget
 @leon_search

 pro nleonw_event,ev

 common nleonwb, id,id1,id2,id3,id4,defsz
 common cbleon, sim,sobj;img,imset
 common cbleon2, sobjim
 common cbleon3, spts

 if ev.id eq id.top then begin; resize the
     g=widget_info(id.c1,/geometry)
     ymin=g.scr_ysize+50
     print,g.scr_ysize,g.ysize
     sx=ev.x-300
     sy=ev.y>ymin
     print,sx,sy
     widget_control,id.draw,scr_xsize=sx,scr_ysize=sy,xoffset=300 
 endif

 ;help,/str,ev


 ;;--- base level
 if ev.id eq id.imbut then begin
     widget_control,id1.top,map=1
 endif
 if ev.id eq id1.dismiss then begin
     widget_control,id1.top,map=0
 endif
 if ev.id eq id.soptbut then begin
     widget_control,id2.top,map=1
 endif
 if ev.id eq id2.dismiss then begin
     widget_control,id2.top,map=0
 endif

 if ev.id eq id.savbut then begin
     widget_control,id3.top,map=1
 endif
 if ev.id eq id3.dismiss then begin
     widget_control,id3.top,map=0
 endif

 if ev.id eq id.objbut then begin
     widget_control,id4.top,map=1
 endif
 if ev.id eq id4.dismiss then begin
     widget_control,id4.top,map=0
 endif


 if ev.id eq id.plot then begin
     savewidget,id,view,/str
     ln=sobj.lns

     common cbbtan, dotan
     dotan=1
     transc, ln,view
     n=n_elements(ln(0,0,*))

 ;    plot,ln(0,*,*),ln(1,*,*),/nodata
 ;    for i=0,n-1 do oplot, ln(0,0:1,i),ln(1,0:1,i)
;     set_plot,'z'
;     tek_color
;     if !version.os ne 'Win32' then 
;     DEVICE, SET_PIXEL_DEPTH=24, SET_RESOLUTION=sim.sz ;else      DEVICE,  SET_RESOLUTION=sim.sz

     erase
     tv,sim.pic,/true
     if dotan eq 0 then begin
         px=reform(ln(0,0:1,*))*view.flen/sim.del(0)+ sim.sz(0)*view.distcx
         py=reform(ln(1,0:1,*))*view.flen/sim.del(1) + sim.sz(1)*view.distcy
     endif
     if dotan eq 1 then begin
         thxc=0;(view.distcx-0.5)*sim.dim(0)/view.flen
         thyc=0;(view.distcy-0.5)*sim.dim(1)/view.flen
         px=(tan(reform(ln(0,0:1,*))-thxc)+tan(thxc))*view.flen/sim.del(0)+ sim.sz(0)*view.distcx
         py=(tan(reform(ln(1,0:1,*))-thyc)+tan(thyc))*view.flen/sim.del(1) + sim.sz(1)*view.distcy

     endif

;    px=px>0<sim.sz(0)
;    py=py>0<sim.sz(1) ; not beyond edge
    px=px>(-sim.sz(0)*0.2)<sim.sz(0)*1.2
    py=py>(-sim.sz(1)*0.2)<sim.sz(1)*1.2 ; not beyond edge

    distort,px,py,view,sim.sz,sim.del
    sobjim={px:px/sim.sz(0),py:py/sim.sz(1)}

    for i=0l,n-1 do plots, px(*,i),py(*,i),/device,col='ff0000'x

 ;   im=tvrd(/true)

 ;   if !version.os ne 'Win32' then set_plot,'x' else set_plot,'Win'

;    tv,im xor sim.pic ,/true
 ;   tv,im,/true

    nleonw_event,{id:id2.showpt}
;or sim.pic,/true
;    stop
endif


;---im source

if ev.id eq id1.load then begin

savewidget,id1,set,/str
leon_loadimg, set
endif


;;;;; srch options

if ev.id eq id2.add or ev.id eq id.add then begin

    a=findgen(17)*(!pi*2/16.0)
    usersym,cos(a),sin(a)
    
    cursor,xc,yc,/norm,/up
    plots,xc,yc,col='0000ff'x,psym=8,/norm ; clicked pos
    dst=(sobjim.px-xc)^2 + (sobjim.py-yc)^2
    dum=min(dst,imin) & ifnd2=imin/2 & ifnd1 = imin mod 2
    
    
    
    usersym,cos(a),sin(a),/fill
    plots,sobjim.px(ifnd1,ifnd2),sobjim.py(ifnd1,ifnd2),col='0000ff'x,psym=8,/norm
    
    cursor,xd,yd,/norm,/up
    plots,xd,yd,col='00ff00'x,psym=5,/norm ;  clicked pos
    if n_elements(spts) eq 0 then spts={npts:1,xim:xd,yim:yd,ifnd1:ifnd1,ifnd2:ifnd2} else $
      spts={npts:spts.npts+1,xim:[spts.xim,xd],yim:[spts.yim,yd],ifnd1:[spts.ifnd1,ifnd1],ifnd2:[spts.ifnd2,ifnd2]}

    widget_control, id2.npts,set_value='npts: '+string(spts.npts,format='(I0)')

    help,/str,spts

endif



if ev.id eq id2.update then begin

    widget_control,id2.update,get_value=iupdate

    cursor,xd,yd,/norm,/up
    plots,xd,yd,col='00ff00'x,psym=5,/norm ;  clicked pos

    spts.xim(iupdate)=xd
    spts.yim(iupdate)=yd

endif

if ev.id eq id2.updatep then begin

    widget_control,id2.updatep,get_value=iupdate

    a=findgen(17)*(!pi*2/16.0)
    usersym,cos(a),sin(a)
    
    cursor,xc,yc,/norm,/up
    plots,xc,yc,col='0000ff'x,psym=8,/norm ; clicked pos
    dst=(sobjim.px-xc)^2 + (sobjim.py-yc)^2
    dum=min(dst,imin) & ifnd2=imin/2 & ifnd1 = imin mod 2
    
    usersym,cos(a),sin(a),/fill
    plots,sobjim.px(ifnd1,ifnd2),sobjim.py(ifnd1,ifnd2),col='0000ff'x,psym=8,/norm
    spts.ifnd1(iupdate)=ifnd1
    spts.ifnd2(iupdate)=ifnd2
    nleonw_event,{id:id.plot}
 endif



if ev.id eq id2.showpt then begin
    if n_elements(spts) eq 0 then return
    a=findgen(17)*(!pi*2/16.0)
    usersym,cos(a),sin(a),/fill
    for i=0,spts.npts-1 do begin
        ifnd1=spts.ifnd1(i)
        ifnd2=spts.ifnd2(i)
        plots,sobjim.px(ifnd1,ifnd2),sobjim.py(ifnd1,ifnd2),col='0000ff'x,psym=8,/norm
        
        xim=spts.xim(i)
        yim=spts.yim(i)
        plots,xim,yim,col='00ff00'x,psym=5,/norm
        xyouts,xim,yim,string(i,format='(I0)'),col='00ff00'x,charsize=2,/norm
        print,'point#=',i
        print,xim,yim,'col=green'
        print,sobjim.px(ifnd1,ifnd2),sobjim.py(ifnd1,ifnd2),'col=red'
        print,sobj.lns(*,ifnd1,ifnd2)
    endfor
endif

if ev.id eq id2.clear then begin
    dum=temporary(spts)
    widget_control, id2.npts,set_value='npts: '+string(0,format='(I0)')
endif

if ev.id eq id2.wrem then begin
    widget_control, id2.wrem,get_value=wdel
    ip=indgen(spts.npts)
    idx=where(ip ne wdel)
    spts={npts:spts.npts-1,xim:spts.xim(idx),yim:spts.yim(idx),ifnd1:spts.ifnd1(idx),ifnd2:spts.ifnd2(idx)}

    widget_control, id2.npts,set_value='npts: '+string(spts.npts,format='(I0)')

endif
    

if ev.id eq id2.search or ev.id eq id.search then begin

    widget_control,id2.mask,get_value=pmask
    widget_control,id2.smask,get_value=smask
    widget_control,id2.swt,get_value=swt

    savewidget,id,view,/str
    view=create_struct(view,'pmask',pmask,'smask',smask,'swt',swt)
    leon_search, view
    loadwidget,id,view,/str
    nleonw_event,{id:id.plot}
    nleonw_event,{id:id2.showpt}


endif



;--- object selection
if ev.id eq id4.dir1an then begin
    widget_control,id4.dir1,get_value=dir1
    fils=file_search(dir1+'/*.wrl',count=cnt)
    if cnt ne 0 then begin
        fils2=strarr(cnt)
        for i=0,cnt-1 do begin
            dum=strsplit(fils(i),'/',/extr) & nex=n_elements(dum)
            dum2=strsplit(dum(nex-1),'.',/extr) & nex2=n_elements(dum2)
            fils2(i)=dum2(0)
        endfor
        widget_control,id4.selwrl,set_value=fils2,set_uvalue=fils2
    endif
endif
if ev.id eq id4.dir1proc then begin
    widget_control,id4.dir1,get_value=dir1
    widget_control,id4.dir2,get_value=dir2
    widget_control,id4.selwrl,get_uvalue=fils
    isel=widget_info(id4.selwrl,/list_select)
    print,fils(isel)
;    widget_control, id.draw,draw_xsize=defsz(0),draw_ysize=defsz(1),get_value=win

    widget_control,id.draw,get_value=win
    

    wset,win
    convwrl,fils(isel),dir1,dir2
endif



if ev.id eq id4.dir2an then begin
    widget_control,id4.dir2,get_value=dir2
    fils=file_search(dir2+'/*show.sav',count=cnt)
    if cnt ne 0 then begin
        fils2=strarr(cnt)
        for i=0,cnt-1 do begin
            dum=strsplit(fils(i),'/',/extr) & nex=n_elements(dum)
            len=strlen(dum(nex-1))
            dum2=strmid(dum(nex-1),0,len-8)
            fils2(i)=dum2
        endfor
        widget_control,id4.selwrl,set_value=fils2,set_uvalue=fils2
    endif
endif

if ev.id eq id4.dir2proc then begin
    widget_control,id4.dir2,get_value=dir2
    widget_control,id4.file3,get_value=file3
    widget_control,id3.dir,get_value=dir
    widget_control,id4.selwrl,get_uvalue=fils
    widget_control,id4.refmirr,get_value=refmirr
    isel=widget_info(id4.selwrl,/list_select)
    print,fils(isel)
;    widget_control, id.draw,draw_xsize=defsz(0),draw_ysize=defsz(1),get_value=win
    widget_control,id.draw,get_value=win
    wset,win
    savewidget,id,view,/str
    hidelines,fils(isel),dir+'/'+file3,view,dir2,refmirr=refmirr
;auto load what's been processsed
    restore,file=dir+'/'+file3,/verb
    sobj={lns:lns}
    nleonw_event,{id:id.plot}
endif


if ev.id eq id4.file3proc then begin
    widget_control,id4.file3,get_value=file3
    widget_control,id3.dir,get_value=dir
    restore,file=dir+'/'+file3,/verb
    sobj={lns:lns}
    nleonw_event,{id:id.plot}
endif


    
        




;--- save/load
if ev.id eq id3.savefname0 then begin
    widget_control, id3.fname0,get_value=fname0
    widget_control, id3.dir,get_value=dir
    savewidget,id,dir+'/'+fname0
endif
if ev.id eq id3.loadfname0 then begin
    widget_control, id3.fname0,get_value=fname0
    widget_control, id3.dir,get_value=dir
    loadwidget,id,dir+'/'+fname0
endif

if ev.id eq id3.savefname1 then begin
    widget_control, id3.fname1,get_value=fname1
    widget_control, id3.dir,get_value=dir
    savewidget,id1,dir+'/'+fname1
endif
if ev.id eq id3.loadfname1 then begin
    widget_control, id3.fname1,get_value=fname1
    widget_control, id3.dir,get_value=dir
    loadwidget,id1,dir+'/'+fname1
endif

if ev.id eq id3.savefname2 then begin
    widget_control, id3.fname2,get_value=fname2
    widget_control, id3.dir,get_value=dir
    savewidget,id2,str,/str
    save,str,spts,file= dir+'/'+fname2
endif
if ev.id eq id3.loadfname2 then begin
    widget_control, id3.fname2,get_value=fname2
    widget_control, id3.dir,get_value=dir
    restore,file=dir+'/'+fname2,/verb
    loadwidget,id2,str,/str
    if n_elements(spts) ne 0 then widget_control, id2.npts,set_value='npts: '+string(spts.npts,format='(I0)')
endif


if ev.id eq id3.savefname4 then begin
    widget_control, id3.fname4,get_value=fname4
    widget_control, id3.dir,get_value=dir
    savewidget,id4,dir+'/'+fname4
endif
if ev.id eq id3.loadfname4 then begin
    widget_control, id3.fname4,get_value=fname4
    widget_control, id3.dir,get_value=dir
    loadwidget,id4,dir+'/'+fname4
endif

if ev.id eq id3.saveall then begin
    nleonw_event,{id:id3.savefname0}
    nleonw_event,{id:id3.savefname1}
    nleonw_event,{id:id3.savefname2}
    nleonw_event,{id:id3.savefname4}
endif


if ev.id eq id3.mapsave then begin
    widget_control,id3.mapno,get_value=mapsave
;    mapcollect,x
    savewidget,id,str,/str
    savewidget,id1,str1,/str
    x=[str1.sh,str1.frnum,str1.cont(0),str1.cont(1),$
       str.flen,str.rad,str.tor,str.hei,str.yaw,str.pit,str.rol,str.dist,str.distcx,str.distcy]
    writemapping,mapsave,x
endif

if ev.id eq id3.mapload then begin
    widget_control,id3.mapno,get_value=mapsave
    readmapping,mapsave,x
    savewidget,id,str,/str
    savewidget,id1,str1,/str
;    x=[str1.sh,str1.frnum,str1.cont(0),str1.cont(1),$
;       str.flen,str.rad,str.tor,str.hei,str.yaw,str.pit,str.rol,str.dist,str.distcx,str.distcy]
    i=0
    str1.sh=x(i++)
    str1.frnum=x(i++)
    str1.cont(0)=x(i++)
    str1.cont(1)=x(i++)
    str.flen=x(i++)
    str.rad=x(i++)
    str.tor=x(i++)
    str.hei=x(i++)
    str.yaw=x(i++)
    str.pit=x(i++)
    str.rol=x(i++)
    str.dist=x(i++)
    str.distcx=x(i++)
    str.distcy=x(i++)
    loadwidget,id,str,/str
    loadwidget,id1,str1,/str
    
endif

if ev.id eq id3.loadall then begin
    nleonw_event,{id:id3.loadfname0}
    nleonw_event,{id:id3.loadfname1}
    nleonw_event,{id:id3.loadfname2}
    nleonw_event,{id:id3.loadfname4}
endif

    

if ev.id eq id.bl then begin

    a=findgen(17)*(!pi*2/16.0)
    usersym,cos(a),sin(a)
    
    cursor,xc,yc,/norm,/up
    plots,xc,yc,col='00ff00'x,psym=8,/norm ; clicked pos

    savewidget,id,view,/str
    leon_bl,xc,yc,view
endif




;if ev.id eq id1.load then begin



end

pro nleonw,dir=dir
default,dir,'gregali'

common nleonwb, id,id1,id2,id3,id4,defsz
id={top:0L,draw:0L,flen:0L,dist:0L,rad:0L,tor:0L,hei:0L,yaw:0L,pit:0L,rol:0l,plot:0l,imbut:0L,soptbut:0L,objbut:0L,savbut:0L,distcx:0L,distcy:0L,c1:0L,add:0L,search:0L,bl:0L}

defsz=[600,600]
def={id3dir:getenv('HOME')+'/idl/clive/nleonw/'+dir+'/',id3fname1:'imset.sav',id3fname2:'srchset.sav',id3fname0:'irset.sav',id3fname4:'objset.sav'}


device,decomp=1,retain=2

id.top=widget_base(/tlb_size_events) ; xsize=defsz(0),ysize=defsz(1),
c1=widget_base(id.top,/col)
id.c1=c1
winwid=100
winht=100
id.flen=CW_FIELD(c1,title='focal length (mm)',/float)
id.rad=CW_FIELD(c1,title='radius (m)',/float)
id.tor=CW_FIELD(c1,title='toroidal angle (deg)',/float)
id.hei=CW_FIELD(c1,title='height (m)',/float)
id.yaw=CW_FIELD(c1,title='yaw',/float)
id.pit=CW_FIELD(c1,title='pitch',/float)
id.rol=CW_FIELD(c1,title='roll',/float)
id.dist=CW_FIELD(c1,title='distortion (1/rad^2)',/float)
id.distcx=CW_FIELD(c1,title='cent x (normaliz)',/float)
id.distcy=CW_FIELD(c1,title='cent y (normaliz)',/float)

id.plot=WIDGET_BUTTON(c1,value='Plot')
id.imbut=WIDGET_BUTTON(c1,value='Image Source')
id.soptbut=WIDGET_BUTTON(c1,value='Search Options')
id.objbut=WIDGET_BUTTON(c1,value='Object Selection etc')
id.savbut=WIDGET_BUTTON(c1,value='Save/Load etc.')
rw=widget_base(c1,/row)
id.add=WIDGET_BUTTON(rw,value='Add p')
id.search=WIDGET_BUTTON(rw,value='Search')
id.bl=WIDGET_BUTTON(c1,value='Backlight')

id.draw=widget_draw(id.top,xsize=1200,ysize=1200,$
                    x_scroll_size=600,y_scroll_size=600,xoffset=300)
;id.draw=widget_draw(id.top,xsize=winwid,ysize=winht,xoffset=200,yoffset=0)


id1={top:0L,type:0L,sh:0L,pre:0L,filename:0L,frnum:0L,format:0L,dim:0L,expfact:0L,avg4:0L,cont:0L,load:0L,dismiss:0L,pretransp:0L,dolog:0L}
id1.top=widget_base(/column,title='Image Source',group_leader=id.top,event_pro='nleonw_event',map=0,/tlb_kill)
id1.type=cw_bgroup(id1.top,['MAST DB','free file'],/excl,row=1)
dum=widget_label(id1.top,value='either::')
id1.sh=cw_field(id1.top,/long,title='Shot ')
id1.pre=cw_field(id1.top,/string,title='diag prefix [eg rbb]')

dum=widget_label(id1.top,value='or::')

id1.filename=cw_field(id1.top,/string,title='free file path')
dum=widget_label(id1.top,value='and::')
id1.frnum=cw_field(id1.top,/integer,title='frame #')
id1.format=cw_bgroup(id1.top,['ipx','tif','png','mse','cxrs'],/excl,row=1,label_top='format')
id1.dim=cw_array(id1.top,title='chip dims (x,y) (mm)',value=[1,1.])
id1.expfact=cw_field(id1.top,title='Load Expansion factor',value=1,/floating)
id1.pretransp=cw_field(id1.top,title='Pretranspose: argument to ROTATE command',value=0)

id1.avg4=cw_bgroup(id1.top,['no','yes'],/excl,row=1,label_left='avg4')
id1.cont=cw_array(id1.top,title='contrast enhance (min,max)',value=[0,255])
id1.dolog=cw_bgroup(id1.top,['no','yes'],/excl,row=1,label_left='log intens')
id1.load=widget_button(id1.top,value='Load')
id1.dismiss=widget_button(id1.top,value='Dismiss')

id2={top:0L,plot:0l,point:0l,search:0l,scalfac:0l,add:0l,mask:0l,undo:0l,fil:0L,save:0L,load:0l,fibp:0l,npts:0l,remove:0l,clear:0l,wrem:0l,showpt:0l,smask:0l,swt:0l,update:0l,click:0l,popt:0l,dismiss:0l,updatep:0L}

id2.top=widget_base(/column,title='Search Options',group_leader=id.top,event_pro='nleonw_event',map=0,/tlb_kill)
c1=id2.top

;id2.plot=WIDGET_BUTTON(c1,value='Plot',uvalue='done')
id2.search=WIDGET_BUTTON(c1,value='Search')
id2.smask=cw_array(c1,title='Selection points to use',value=[0,1,2,3,4,5,6,7,8,9,10,11])
id2.swt=cw_array(c1,title='Weight of selected points',value=[1,1,1,1,1,1,1,1,1,1,1,1])
id2.npts=widget_text(c1,value='npts: 0')
;id2.remove=widget_button(c1,value='remove 1')
rw=widget_base(c1,/row)
id2.clear=widget_button(rw,value='clear all pts')
id2.wrem=CW_FIELD(rw,title='remove a point [enter activates]:',/integer,value=1,xsize=4,/return)
rw=widget_base(c1,/row)
id2.showpt=widget_button(rw,value='Show all points')
id2.update=CW_FIELD(rw,title='Move image lock point [green, enter activates]:',/integer,value=1,xsize=4,/return)
id2.updatep=CW_FIELD(c1,title='Move object lock point [red, enter activates]:',/integer,value=1,xsize=4,/return)
;id2.scalfac=CW_FIELD(c1,title='descale',/float,value=1.)
rw2=widget_base(c1,/row)
id2.add=widget_button(rw2,value='Add new search point')
;id2.click=widget_button(rw2,value='click p')
id2.mask=cw_array(c1,title='Paramters: Free (1)/Locked(0),order as in main list',value=[1,0,1,1,1,1,1,1])
;id2.popt=cw_bgroup(c1,['nomodel','w/model'],/exclusive,set_value=1,column=2)
id2.dismiss=widget_button(id2.top,value='Dismiss')






id4={top:0L,dir1:0L,dir2:0L,file3:0L,selwrl:0L,dismiss:0L,dir1an:0L,dir1proc:0L,dir2an:0L,dir2proc:0L,file3proc:0L, refmirr:0L}
id4.top=widget_base(/column,title='Object selection',group_leader=id.top,event_pro='nleonw_event',map=0,/tlb_kill)

dum=widget_base(id4.top,/row)
id4.dir1=cw_field(dum,/string,title='Path to Wrl files')
id4.dir1an=widget_button(dum,value='Show')
id4.dir1proc=widget_button(dum,value='Process selected')

dum=widget_base(id4.top,/row)
id4.dir2=cw_field(dum,/string,title='Path to interpreted wrl files (..show.sav)')
id4.dir2an=widget_button(dum,value='Show')
id4.dir2proc=widget_button(dum,value='Do hidden line removal on selected')

dum=widget_base(id4.top,/row)
id4.refmirr=cw_array(dum,value=[-1,-1,-1],title='mirrir d0, phi, theta')




dum=widget_base(id4.top,/row)
id4.file3=cw_field(dum,/string,title='filename of rendered objects [rel to dir in load/save]')
id4.file3proc=widget_button(dum,value='Load into memory (for image comparison)')

id4.selwrl=widget_list(id4.top,ysize=15,/multiple)
;ulist={txt:list,set:ptrarr(n_elements(list),2)}
id4.dismiss=widget_button(id4.top,value='Dismiss')





id3={top:0L,dir:0L,fname1:0L,fname2:0L,fname0:0L,fname4:0L,loadfname1:0L,loadfname2:0L,loadfname0:0L,loadfname4:0L,savefname1:0L,savefname2:0L,savefname0:0L,savefname4:0L,loadall:0L,saveall:0L,dismiss:0L,mapno:0L,mapload:0L,mapsave:0L}
id3.top=widget_base(/column,title='Load/Save',group_leader=id.top,event_pro='nleonw_event',map=0,/tlb_kill)
id3.dir=cw_field(id3.top,/string,value=def.id3dir,title='Path ')
id3.fname1=cw_field(id3.top,/string,value=def.id3fname1,title='Image settings')
id3.loadfname1=widget_button(id3.top,value='Load Image settings')
id3.savefname1=widget_button(id3.top,value='Save Image settings')

id3.fname2=cw_field(id3.top,/string,value=def.id3fname2,title='Search settings')
id3.loadfname2=widget_button(id3.top,value='Load Search settings')
id3.savefname2=widget_button(id3.top,value='Save Search settings')
id3.fname4=cw_field(id3.top,/string,value=def.id3fname4,title='Object settings')
id3.loadfname4=widget_button(id3.top,value='Load Object settings')
id3.savefname4=widget_button(id3.top,value='Save Object settings')
id3.fname0=cw_field(id3.top,/string,value=def.id3fname0,title='Iris settings')
id3.loadfname0=widget_button(id3.top,value='Load Iris settings')
id3.savefname0=widget_button(id3.top,value='Save Iris settings')
id3.loadall=widget_button(id3.top,value='Load All')
id3.saveall=widget_button(id3.top,value='Save All')
id3.mapno=cw_field(id3.top,/string,value='7345.16')
id3.mapload=widget_button(id3.top,value='load map')
id3.mapsave=widget_button(id3.top,value='save map')

id3.dismiss=widget_button(id3.top,value='Dismiss')



widget_control,id.top,/realize
widget_control, id1.top,/realize
widget_control, id2.top,/realize
widget_control, id3.top,/realize
widget_control, id4.top,/realize


;catch,err
err=0
if err ne 0 then goto,af
nleonw_event,{id:id3.loadfname0}
nleonw_event,{id:id3.loadfname1}
nleonw_event,{id:id3.loadfname2}
nleonw_event,{id:id3.loadfname4}
nleonw_event,{id:id1.load}
nleonw_event,{id:id4.file3proc}
af:
catch,/cancel
;xmanager,catch=0
xmanager,'nleonw',id.top;,/no_block



end

