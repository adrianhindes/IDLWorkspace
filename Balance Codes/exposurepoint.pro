function exposurePoint, shot
  ;Lookup arrays for plasma shots and exposure shots
  ;"There's always a better way" - Adrian H 4/12/16
 
  
  emissionShots = indgen(23,start=29)
  plasmaShots = [7708,7678,7648,7618,7378,7408,7438,7468,7498,7528,7558,7588,7760,7790,7820,7850, $
    7895,7927,7955,7982]
    
arrayPos = value_locate(plasmaShots,shot)
emissionShot = emissionShots[arrayPos]



return,emissionShot    
  
end