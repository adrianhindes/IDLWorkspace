function magpie_lower_hybrid,  I0, I1, r=r, z=z, scale=scale

default, I0, 50.
default, I1, 500.
 
field = Magpie_field( I0, I1, r=r, z=z, scale=scale )


stop

end
