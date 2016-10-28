function exp_fit3,v,fit_params

i = fit_params(0) * (1-exp( (v-0)/fit_params(1)))
pder1=(1-exp( (v-0)/fit_params(1)))
;pder2=exp( (v-0)/fit_params(1))*fit_params(0)/fit_params(1)
pder3=exp( (v-0)/fit_params(1))*fit_params(0)/fit_params(1)^2 * (v-0)
rval=[[i],[pder1],[pder3]]
return,rval

end

