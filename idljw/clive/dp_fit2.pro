function dp_fit2,v,fit_params
i = fit_params(0) * (tanh(v/2/fit_params(1)))
pder1=(tanh(v/2/fit_params(1)))
pder2=-fit_params(0) * v * 1/cosh( v/2/fit_params(1) )^2 / 2 / fit_params(1)^2
rval=[[i],[pder1],[pder2]]
return,rval

end

