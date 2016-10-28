function mdf_interp_field, Bz, Br, pt

   Bzpt = bilinear(Bz, pt[0], pt[1])
   Brpt = bilinear(Br, pt[0], pt[1])

return, [Bzpt, Brpt]

end

