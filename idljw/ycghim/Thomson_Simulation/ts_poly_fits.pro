
function ts_poly_fits, dsts, ncheby

  dstefit = fit_cheby(dsts.rch, dsts.temes, dsts.dtemes, ncheby)

  dsnefit = fit_cheby(dsts.rch, dsts.nemes, dsts.dnemes, ncheby)

  dsts = create_struct(dsts, 'ncheby', ncheby, 'dstefit', dstefit, 'dsnefit', dsnefit)

  return, dsts

end

