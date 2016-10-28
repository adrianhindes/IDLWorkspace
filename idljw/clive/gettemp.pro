fil='/data/mse_2015_tests/TemperatureLog\[6_20_02_PM\]\[19_08_2015\].log'


ix=findgen(130)*6*10
d=(read_ascii(fil,delim=' ',data_start=10)).(0)
plot,d(2,ix)

end
