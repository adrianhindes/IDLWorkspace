function read_interpolation_arrays, shotno, path=path

s = load_mse_demod_settings( shotno )
default, path, '.mse.intersect'

mdsopen, s.tree, s.reg_shot

  mdssetdefault, path
  rgrid = mdsvalue( '.interpolate:rgrid' )
  zgrid = mdsvalue( '.interpolate:zgrid' )
  indices = mdsvalue( '.interpolate:indices' )
  distance = mdsvalue( '.interpolate:distance' )

mdsclose

interp = {rgrid:rgrid, zgrid: zgrid, indices:indices, distance: distance}

return,  interp

end
