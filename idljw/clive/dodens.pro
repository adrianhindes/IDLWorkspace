pro dodens,sh,oplot=oplot,col=col
demodsw,sh,10,yy,tt
if keyword_set(oplot) then oplot,tt,yy,col=col else plot,tt,yy
end
