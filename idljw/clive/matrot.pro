function matrot, r
mat=[$
[1.,0,0,0],$
[0,cos(2*r),sin(2*r),0],$
[0,-sin(2*r),cos(2*r),0],$
[0,0,0,1.]]
return,mat
end
