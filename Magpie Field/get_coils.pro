function get_coils, s, m, mirror_c, source_c

  coil_pos = [-0.72, -0.54, -0.36, -0.18, 0., 0.264, 0.317,0.390, 0.443, 0.496, 0.549, 0.602]*100 ; cm


  n= 13.5 ;number of windings
  a=0.183 *100.0;coil radius in cmeters

  power_supply1=source_c
  I1=n*power_supply1
  I2=n*power_supply1
  I3=n*power_supply1
  I4=n*power_supply1
  I5=n*power_supply1

  power_supply2=mirror_c
  I6=n*power_supply2
  I7=n*power_supply2
  I8=n*power_supply2
  I9=n*power_supply2
  I10=n*power_supply2
  I11=n*power_supply2
  I12=n*power_supply2


  coil_I=[s[0]*I1,s[1]*I2,s[2]*I3,s[3]*I4,s[4]*I5,m[0]*I6,m[1]*I7,m[2]*I8,m[3]*I9,m[4]*I10,m[5]*I11,m[6]*I12]

  coil={position:coil_pos, current:coil_I, radius: a}
  return, coil
end