function frameoftime, sh, tw,db=db
readpatch,sh,str,db=db
ifr= round((tw-str.t0)/str.dt)
return,ifr
end
