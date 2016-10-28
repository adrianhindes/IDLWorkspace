pro translate_PMT_CSV_to_MDSPlus, shotno

if n_params() ne 1 then begin
  print, 'Please provide shot number
  return
end

filename = 'C:\haitao\papers\PMT camera\experiments on Magpie\dataes and picture\calibration datas with romanna\'+strtrim(shotno,2)+'.csv'

;r = QUERY_CSV( Filename , Info )
Data = READ_CSV( Filename, COUNT=count, HEADER= h)
time = data.field02

mdsopen, 'magpie', shotno, status=status, /quiet
if not status then begin &$
   mdstcl, 'set tree magpie',status=status  &$
   mdstcl, 'create pulse '+strtrim(shotno,2),status=status  &$
   mdstcl,'edit magpie /shot='+strtrim(shotno, 2), status=status &$
end

str2 = 'build_with_units($,"Seconds")'
str1 = 'build_with_units($,"Volts")'
str = "build_signal("+str1+",*,"+str2+")"

find_or_create_node, '.PMT'
mdssetdefault, '.PMT'
for i=0,15 do begin &$
   chan_name = 'CHANNEL_'+string(i,'(i02)') &$
   find_or_create_node, chan_name, usage='signal' &$
   mdsput, chan_name, str, data.(i+2), time, quiet=quiet, status=status &$
end
mdswrite, 'magpie', shotno

end


