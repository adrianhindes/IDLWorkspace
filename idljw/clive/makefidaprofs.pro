pro makefidaprofs,dens=densk,temp=tempk,lindens=lindens,lintemp=lintemp,sh=sh,targsh=targsh,targt=targt
;m-3 and ev
default,targsh,26887
default,targt,0.23
default,densk,1.2e19
default,tempk,1000.
default,lindens,0
default,lintemp,1


path='/users/prl/cam112/finp/KSTAR/profiles/'+string(targsh,format='(I0)')+'/'
rho=linspace(0,1,60)
if keyword_set(lindens) then dens = linspace(1,0,60)*densk/1e19 else $
  dens = rho*0+densk/1e19 

if keyword_set(lintemp) then temp = linspace(1,0,60)*tempk/1e3 else $
  dens = rho*0+tempk/1e3


ne_str={rho_dens:rho,dens:dens}
te_str={rho_te:rho,te:temp}
ti_str={rho_ti:rho,ti:temp}

base=string(targsh,targt*1000,format='(I0,".",I5.5)')
save,ne_str,file=path+'dne'+base,/verb
save,te_str,file=path+'dte'+base,/verb
save,ti_str,file=path+'dti'+base,/verb
plot,rho,dens
plot,rho,temp,/noer,col=2
stop
end
