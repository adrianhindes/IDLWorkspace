
function setup_channels, ntm

; Measurement channel radii and radial resolutions

; HFS edge channels

  rch1 = [.251, .275, .3, .325, .35, .375, .4]
  nch1 = n_elements(rch1)
  spch1 = fltarr(nch1)
  spch1[*] = 1     ; WSL - edge
  sys1 = intarr(nch1)
  sys1[*] = 0
  loc1 = intarr(nch1)
  loc1[*] = 0
  mul1 = fltarr(nch1)
  mul1[*] = 2.

; Inner core channels

    rch2 = [.44, .48, .52, .56, .6, .64, .68, .72]
    nch2 = n_elements(rch2)
    spch2 = intarr(nch2)
    spch2[*] = 0     ; WSL - core
    sys2 = intarr(nch2)
    sys2[*] = 0
    loc2 = intarr(nch2)
    loc2[*] = 0
    mul2 = fltarr(nch2)
    mul2[*] = 2.

; Central core channels

    rch3 = [.76, .8, .84, .88, .92, .96, 1., 1.04]
    nch3 = n_elements(rch3)
    spch3 = intarr(nch3)
    spch3[*] = 2
    sys3 = intarr(nch3)
    sys3[*] = 0
    loc3 = intarr(nch3)
    loc3[*] = 0
    mul3 = fltarr(nch3)
    mul3[*] = 1.

; Outer core channels

    rch4 = [1.09, 1.115, 1.14, 1.165, 1.19, 1.215, 1.24, 1.265, 1.29, 1.315]
    nch4 = n_elements(rch4)
    dxch4 = fltarr(nch4)
    dxch4[*] = .025
    spch4 = intarr(nch4)
    spch4[*] = 0  ; WSL - core
    sys4 = intarr(nch4)
    sys4[*] = 0
    loc4 = intarr(nch4)
    loc4[*] = 0
    mul4 = fltarr(nch4)
    mul4[*] = 2.

; LFS edge channels

    rch5 = [1.33, 1.34, 1.35, 1.36, 1.37, 1.38, 1.39, 1.40, $
                1.41, 1.42, 1.43, 1.44, 1.45, 1.46, 1.47, 1.48]
    nch5 = n_elements(rch5)
    spch5 = intarr(nch5)
    spch5[*] = 1        ; WSL - edge
    sys5 = intarr(nch5)
    sys5[*] = 1
    loc5 = intarr(nch5)
    loc5[*] = 0
    mul5 = fltarr(nch5)
    mul5[*] = 2.

; Concatenate channel data

    rch = [rch1, rch2, rch3, rch4, rch5]
    spch = [spch1, spch2, spch3, spch4, spch5]
    system = [sys1, sys2, sys3, sys4, sys5]
    location = [loc1, loc2, loc3, loc4, loc5]
    multi = [mul1, mul2, mul3, mul4, mul5]

    if ntm then begin
      rntm = 1.101
      rch6 = [.0, .01, .02, .03, .04, .05, .06, .07, .08, .09, $
                  .1, .11, .12, .13, .14, .15, .16, .17, .18, .19] + rntm
      nch6 = n_elements(rch6)
      spch6 = intarr(nch6)
      spch6[*] = 3      ; WSL - NTM
      sys6 = intarr(nch6)
      sys6[*] = 2
      rch = [rch, rch6]
      spch = [spch, spch6]
      system = [system, sys6]
      loc6 = intarr(nch6)
      loc6[*] = 1
      location = [location, loc6]
      mul6 = fltarr(nch6)
      mul6[*] = 1.
      multi = [multi, mul6]

    endif    

; Order channels in ascending radius

    order = sort(rch)

    rch = rch[order]
    spch = spch[order]
    system = system[order]
    location = location[order]
    multi = multi[order]

; Total number of channels
    nch = n_elements(rch)

; Channel data structure
    dsch = {nch:nch, rch:rch, spch:spch, system:system, location:location, multi:multi}

    return, dsch

end

