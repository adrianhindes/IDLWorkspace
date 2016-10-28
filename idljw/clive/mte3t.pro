sh=312;50
;sh=412
sh=456;47 ; 30kHz, single probe?
sh=457
sh=460;half amplitude
;sh=465
sh=482
sh=495;84;pmt on cur probe 1A/V
isat=magpie_data('probe_isat',sh) &isat.vvector=isat.vvector/200;(sh eq 465 ? 50 : 200.)
isat2=magpie_data('probe_isat_rot',sh) &isat2.vvector/= 400. 

isata=magpie_data('single_pmt',sh)

print,mean(isat.vvector)
print,mean(isata.vvector)

end
