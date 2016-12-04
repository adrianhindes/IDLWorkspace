function zLookup, shot



  zVals = [1,2,3,4,4,3,2,1,1,2,3,4,1,2,3,4,4,3,2,1]
  plasmaShots = [7708,7678,7648,7618,7378,7408,7438,7468,7498,7528,7558,7588,7760,7790,7820,7850, $
    7895,7927,7955,7982]
    
arrayPos = value_locate(plasmaShots,shot)
z = zVals[arrayPos]


return,z

end