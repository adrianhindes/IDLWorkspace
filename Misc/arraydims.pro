function arrayDims, array

  ;Get size vector.
  S = SIZE(arr)

  ;Return NaNs for non 2D or 3D arrays
  NX = [!values.F_NAN]
  NY = [!values.F_NAN]
  NZ = [!values.F_NAN]
  
  if S[0] eq 2 then $
    NX = S[1] & NY = S[2] $
  endif
  if S[0] eq 3 then $
    NX = S[1] & NY = S[2] & NZ = S[3] $
  endif

  arrayDims = create_struct('x',NX,'y',NY,'z',NZ)
  
  return,arrayDims
  
  end