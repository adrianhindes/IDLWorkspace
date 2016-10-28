sh=fix(intspace(9427,8964))
nsh=n_elements(sh)
for i=0,nsh-1 do load_all_data_from_kstar,sh(i),/force
end
