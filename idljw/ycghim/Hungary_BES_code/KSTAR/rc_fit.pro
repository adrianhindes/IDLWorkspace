function rc_fit, x, p

return, 1/(1+(x/p[0])^2)*p[1]
end
