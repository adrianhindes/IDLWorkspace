pro getphd,sh
mdsopen,'h1data',sh
nd2='\H1DATA::TOP.LOG.HEATING:SNMP:T2:OPERATIONAL:LLRF:STALLRFPHD'
nd1='\H1DATA::TOP.LOG.HEATING:SNMP:T1:OPERATIONAL:LLRF:STALLRFPHD'
p1=mdsvalue(nd1)
p2=mdsvalue(nd2)
print,sh,p1,p2
end


for sh=81746,81753 do begin
   getphd,sh

endfor
print,'new day'
for sh=81754,99999 do begin
   getphd,sh
wait,0.
endfor
end
