function flux_area, flux_array, rad_array, z1, z2, flux_val

;j=z axis
;i=rad

r1_index = value_locate(flux_array[z1,*],flux_val)
r2_index = value_locate(flux_array[z2,*],flux_val)

r1 = rad_array[r1_index]
r2 = rad_array[r2_index]

dr = r2-r1

A = 2*!pi*r1^2

dA = 2*!pi*(r1+dr)^2 - A
dA = dA

return, {Area: A, dA: dA, r1: r1, r2: r2}

end