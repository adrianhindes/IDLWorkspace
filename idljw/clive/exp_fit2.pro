function exp_fit2,v,fit_params
i = fit_params(0) * (1-exp( (v-fit_params(1))/fit_params(2)))
pder1=(1-exp( (v-fit_params(1))/fit_params(2)))
pder2=exp( (v-fit_params(1))/fit_params(2))*fit_params(0)/fit_params(2)
pder3=exp( (v-fit_params(1))/fit_params(2))*fit_params(0)/fit_params(2)^2 * (v-fit_params(1))
rval=[[i],[pder1],[pder2],[pder3]]
return,rval

end

