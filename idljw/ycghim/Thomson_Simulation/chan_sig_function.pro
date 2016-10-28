
pro chan_sig_function, x, a, f, pder, dsch=dsch, dssys=dssys, dscon=dscon, $
                                  chan=chan, amask=amask

  tel = a[0]
  nel = a[1]

  dsts = ts_measurement(dsch, dssys, dscon, chan=chan, tel=tel, nel=nel, /single)

  f = reform(dsts.signal - dsts.bgsig)

  pder = transpose([dsts.dsig_dte[0, x], dsts.dsig_dne[0, x]])

; Select only signals for which initial signal is gt 0
  f = f[fix(x)]

  return

end

