pro write_mse_process_settings, shotno, tree=tree, settings=s, blk_shot=blk_shot

default, tree, 'mse_2013'
default, blk_shot, shotno
default, s, default_mse_2013_settings(blk_shot = blk_shot)

; look up the offset
path = 'D:\DATA\MSE_2013_data\'
file = path + 'log_nskip.csv'
a = read_csv(file)

db = a.field2
mse = where(db eq 'k' or db eq 'cal' or db eq 'calbg')
shots = (a.field1)[mse]
nskips = (a.field3)[mse]
shotidx = (where(shots eq shotno))[0] 
 
if shotidx[0] ne -1 then s.frame_offset = nskips[shotidx]

; look up the timing
file = path + 'log_timing.csv'
a = read_csv(file)
db = a.field2
mse = where(db eq 'k' or db eq 'cal' or db eq 'calbg')
shots = a.field1[mse]
t0 = (a.field3*1000)[mse]
dt = (a.field4*1000)[mse]
shotidx = (where(shotno lt shots))[0] - 1 
if shotidx[0] ge 0 then begin
  s.dt = dt[shotidx]
  s.t0 = t0[shotidx]
end

;help,s,/str

mdsedit, tree, shotno, status=status
find_or_create_node, '.settings'
mdssetdefault, '.settings'

tn = tag_names(s)
for i = 0, n_elements(tn)-1 do begin
   tag = tn[i]
   node =  ':'+tn[i]
   if type(s.(i)) eq 7 then usage='text' else usage='numeric'
   find_or_create_node, node, usage=usage
   mdsput, node, '$', s.(i),  status = status,  quiet = quiet
end

mdswrite, tree, shotno

end
 