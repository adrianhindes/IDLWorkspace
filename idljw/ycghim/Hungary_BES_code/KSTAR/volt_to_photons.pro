function volt_to_photons,volts, gain=gain

 default,gain,50

; Converts the input volt signal to photon flux

; Crossimpedance gain of the electronics
imp_gain = 3.4e6

return,volts/imp_gain/gain/1.6E-19

end