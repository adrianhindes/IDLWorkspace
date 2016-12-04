function pLookup, shot



  pVals = [8.4,8.4,8.4,8.4,4.2,4.2,4.2,4.2,2.1,2.1,2.1,2.1,4.1,4.1,4.1,4.1,4.2,4.2,4.2,4.2]
  plasmaShots = [7708,7678,7648,7618,7378,7408,7438,7468,7498,7528,7558,7588,7760,7790,7820,7850, $
    7895,7927,7955,7982]
    
arrayPos = value_locate(plasmaShots,shot)
p = pVals[arrayPos]


return,p

end