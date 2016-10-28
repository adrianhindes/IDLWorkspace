function intspace, st,en
if en-st ge 0 then return,findgen(en-st+1)+st
if en-st lt 0 then return,reverse(findgen(st-en+1)+en)
end
