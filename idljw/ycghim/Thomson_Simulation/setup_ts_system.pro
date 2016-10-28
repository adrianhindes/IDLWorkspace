
function setup_ts_system, dsch, dscon

; Laser parameters
  lam0 = 1064.                   ; Laser wavelength [nm]
  laser_energy = 1.            ; Laser energy nergy [J]
  wlaser = 0.005                  ; Laser beam width [m]

; Gating period of image intensifier [s]
  dtgate = 4e-8

; Locations along laser path - cartesian coordinates
  laser_pr = [[-2., -.25, 0.], [2., -.25, 0.]]

; Collection optics (System indices: 0 - core, 1 - LFS edge, 2 - NTM)
  f_im = [12., 6., 6.]                  ; f-number at fibres
  f_fib = [1.75, 1.75, 1.75]         ; F# at image
  dxfib = [3.91, 1.42, 1.42]        ; Width of fibre bundle [mm]
  dzfib = [0.838, 2.18, 2.18]     ; Height of fibre bundle [mm]
  magn = f_im / f_fib                ; Effective magnification
  lens_pr = [[-1.055, -2.117, 0.], [-2.5, 0.336, 0.], [2.276, .178, 0.]]   ; Lens locations

  dxfib = dxfib * 1e-3               ; Convert [mm] to [m]
  dzfib = dzfib * 1e-3               ; Convert [mm] to [m]

  dxim = magn * dxfib              ; Image width in plasma
  dzim = magn * dzfib              ; Image height in plasma

; Transmission of optical system
  trans = 0.25

; Quantum efficiency of APDs
  qeff = 0.85

; Noise factor
  f_noise = 2.

; Noise level from electronics (photo-electron equivalent)
  noise = 1e4

; Nominal path length of view through plasma for background calculation
  dlview = 4.0

; Zeff for bremsstrahlung calculation
  zeff = 2.0

; Factor of background intensity above bremstralung
  bgfact = 2.0
 
; Wavelength array
  nlam = 500
  lrange = [200., 1200]
  lam = (lrange[1] - lrange[0]) * findgen(nlam) / (nlam-1) + lrange[0]
  dlam = lam[1] - lam[0]

; Spectrometer parameters

; Number of filters
  nfilt = 8

; Central wavelengths of filters [nm]
  f_lam0 = [755., 917., 1020., 1049., 1059., 920., 1015., 1042.]

; Spectral widths of filters [nm]
  f_dlam = [170., 155., 43., 14.3, 5.2, 140., 80., 16.]

; Spectral bandpasses of filters [nm]
  bandpass = fltarr(2, nfilt)
  bandpass[0, *] = f_lam0 - f_dlam/2
  bandpass[1, *] = f_lam0 + f_dlam/2

; Bandpass transmission of each spectral channel
  t_band = [0.80, 0.85, 0.85, 0.83, 0.75, 0.8, 0.8, 0.8]

; Filter transmission functions
  f_trans = fltarr(nlam, nfilt)
  for i=0, nfilt-1 do begin
    band = where(lam ge bandpass[0, i] and lam le bandpass[1, i])
    f_trans[band, i] = t_band[i]
  endfor

; Arrays describing which filters used in spectrometers
  specfilt = [[1, 1, 1, 1, 0, 0, 0, 0], $ ; WSL - core
                [0, 1, 1, 1, 1, 0, 0, 0], $ ; WSL - edge
                [0, 0, 0, 0, 0, 1, 1, 1], $    ; COMPASS
                [0, 0, 1, 1, 1, 0, 0, 0]]      ; WSL - NTM

; Arrays describing which filters are used for each channel
  usefilt = intarr(dsch.nch, nfilt)

  for i=0, dsch.nch-1 do $
    usefilt[i, *] = specfilt[*, dsch.spch[i]]

  ds = {lam0:lam0, laser_energy:laser_energy, f_fib:f_fib, qeff:qeff, nfilt:nfilt, trans:trans, $
           noise:noise, lam:lam, f_trans:f_trans, wlaser:wlaser, dxfib:dxfib, dzfib:dzfib, $
           nlam:nlam, dlam:dlam, magn:magn, specfilt:specfilt, usefilt:usefilt, t_band:t_band, $
           laser_pr:laser_pr, lens_pr:lens_pr, dxim:dxim, dzim:dzim, f_im:f_im, dtgate:dtgate, $
           dlview:dlview, zeff:zeff, bgfact:bgfact, f_noise:f_noise}

  return, ds

end

