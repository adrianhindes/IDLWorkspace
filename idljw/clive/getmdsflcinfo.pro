pro getmdsflcinfo,sh,tree,flc0per,flc0mark,flc0invert

  mdsopen,tree,sh
  
  pre='\'+tree+'::top'
  
  
  flc0mark=fix(mdsvalue(strupcase(pre+'.MSE.FLC.FLC__00:MARK'),/quiet))
  flc0space=fix(mdsvalue(strupcase(pre+'.MSE.FLC.FLC__00:SPACE'),/quiet))
  flc0invert=(mdsvalue(strupcase(pre+'.MSE.FLC.FLC__00:INVERT'),/quiet)) eq 'True'

  flc0per=flc0mark+flc0space
  print,'got flc info from db',flc0mark,flc0per,flc0invert
end
