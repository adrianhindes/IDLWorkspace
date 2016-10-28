function doppler_broadening, temp, waves

phase = 2*!pi*waves

T_c = t_char(phase)
dBroadening = exp(-temp/(T_c))  ;fringe contrast from the doppler contribution

return,dBroadening

end