function setcompl, set, excl
nexcl=n_elements(excl)
nset=n_elements(set)

mask=replicate(1,nset)
for i=0,nexcl-1 do mask = mask and (set ne excl(i))
setr=set(where(mask eq 1))
return,mask
end
