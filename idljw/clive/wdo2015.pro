pro wdo2015
common cbwdo2015, id

id={top:0L,plot:0L}


plx=500
ply=500
id.top=widget_base(/row,title='wdo2015')
id.plot=cw_view2d(id.top,xsize=plx,ysize=ply)
widget_control,id.top,/realize
xmanager,'wdo2015',id.top

end

