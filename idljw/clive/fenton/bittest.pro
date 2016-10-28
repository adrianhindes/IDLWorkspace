; Function to test the value of a bit in a binary number. Useful for
; hardware conversations. The bit number (BitNum) is 1
; indexed. i.e. 2^0 is the first bit and here BitNum=1
; Written by Fenton Glass, Jan. 2000


function bittest, CurByteVal, BitNum, Testfor

BitNumVal=2^(BitNum-1)
TestVal=CurByteVal and BitNumVal
if Testfor eq 1 then begin
    if TestVal eq BitNumVal then ans=1B else ans=0B
    end
if Testfor eq 0 then begin
    if TestVal eq 0 then ans =1B else ans=0B
    end
return, ans
end


