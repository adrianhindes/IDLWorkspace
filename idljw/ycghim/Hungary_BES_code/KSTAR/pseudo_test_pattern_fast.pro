function pseudo_test_pattern_fast,nsample,bits=adc_bits
; This routine generates the short pseudo random test pattern for the AD9252 ADC
; Returns nsample samples each adc_bits bit long

default,adc_bits,14

bits = 1022l
bitseq = bytarr(bits)
bitseq[0:7] = [1,1,1,1,1,0,1,1]
for i=1l,bits-8 do begin
  c = (bitseq[4] + bitseq[8]) mod 2
  bitseq[1:bits-1] = bitseq[0:bits-2]
  bitseq[0] = c
endfor

bitseq_1 = bitseq
for i=1,bits do begin
  if (i*bits mod adc_bits eq 0) then break
  bitseq = [bitseq,bitseq_1]
endfor
sample_len = i*bits/adc_bits

sample_seq_short = lonarr(sample_len)
mask = 2^lindgen(adc_bits)
for i=0l,sample_len-1 do begin
  sample_seq_short[i] = total(bitseq[n_elements(bitseq)-1-i*adc_bits-(adc_bits-1) : n_elements(bitseq)-1-i*adc_bits]*mask)
endfor

sample_seq = sample_seq_short
while (n_elements(sample_seq) lt nsample) do begin
  sample_seq = [sample_seq,sample_seq]
endwhile


return,sample_seq

end