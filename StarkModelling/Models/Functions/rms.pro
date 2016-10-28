function rms, approx

n = n_elements(approx)

mean_approx = mean(approx)

diffs = (double(approx - mean_approx))^2

errorval = sqrt(total(diffs))


return,errorval

end