pro kstar_read_cxrs, Ti, Vt, kstar=kstar


Print,'Reading Ti ...'

for i=1,32 do begin &$
  stri = 'TI'+string(i,'(i02)') &$
  node = '\CES_'+stri &$
  node_local = 'KSTAR.CXRS:'+stri &$
  cmd = "TiChan = kstar_read_node('"+node+"', local = '"+node_local+"' )" &$
  ok = execute(cmd) &$
  if TiChan.units eq ' ' then TiChan.units = 'eV' &$
  if ok then begin &$
    if i eq 1 then Ti = replicate(TiChan, 32) &$
    Ti[i-1] = TiChan &$
  end &$
end

Print,'Reading Vtor ...'
for i=1,32 do begin &$
  stri = 'VT'+string(i,'(i02)') &$
  node = '\CES_'+stri &$
  node_local = 'KSTAR.CXRS:'+stri &$
  cmd = "VTChan = kstar_read_node('"+node+"', local = '"+node_local+"' )" 
  ok = execute(cmd) &$
  if VTChan.units eq ' ' then VTChan.units = 'km/s' &$
  if ok then begin &$
    if i eq 1 then VT = replicate(VTChan, 32) &$
    VT[i-1] = VTChan &$
  end &$
end

end
        