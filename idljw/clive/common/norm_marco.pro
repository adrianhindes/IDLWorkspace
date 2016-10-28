function norm_marco, x

normID = '$Id: norm.pro 6 2008-02-26 11:11:29Z mwisse $'

on_error, 2
return, x/max(x)

end
