pro mdstest, tree, shot, sig, time,y

mdsopen,tree,shot
time=mdsvalue('DIM_OF('+sig+')')
y=mdsvalue(sig)
mdsclose

end
