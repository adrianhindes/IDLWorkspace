function error, approximate, actual


error = abs(approximate-actual)/float(actual)
error = error*100

return,error

end