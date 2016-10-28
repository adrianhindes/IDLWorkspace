function getcamdims, p
if p.camera eq 'sensicam' then dim=[1376,1040.] else $
  if p.camera eq 'edge' then dim=[2560,2160.] else $
  if p.camera eq 'cascade512' then dim=[512,512] else $
  if p.camera eq 'pimax3' then dim=[1024,1024] else $
  if p.camera eq 'pixelfly' then dim=[1392,1040] else stop


return,dim


end
