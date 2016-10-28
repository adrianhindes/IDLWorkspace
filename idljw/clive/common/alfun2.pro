function alfun2, alnew,xppp=xmuppp,ent=ent,cpen=cpen,cee=cxmuppp
common alfunc, smuppp,cmuppp, z, idx,chisq,caimt,pen,lmu
xmuppp = (alnew * smuppp - cmuppp) / (z+alnew+pen*lmu)
if idx(0) ne -1 then xmuppp(idx)=0.
z2=z+pen 
cxmuppp = chisq + total(cmuppp * xmuppp) + 0.5 * total(z * xmuppp^2)
cpen = chisq + total(cmuppp * xmuppp) + 0.5 * total(z2 * xmuppp^2)
ent=total(smuppp*xmuppp) + 0.5 * total(xmuppp^2)
return,cxmuppp-caimt
end
