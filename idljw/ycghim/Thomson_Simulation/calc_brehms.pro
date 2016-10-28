
function calc_brehms, dssys, dscon, dste, dsne

; Calculate Gaunt integral

  fgaunt = (dscon.gaunt1*alog(dste.te)-dscon.gaunt0)/sqrt(dste.te)

  gaunt_integral = int_tabulated(dste.te, fgaunt)

  ibrehms = dscon.cbrehms * dsne.nel^2 * dssys.z_eff * gaunt_integral / (4 * !Pi * dssys.lam)

  return, ibrehms

end
