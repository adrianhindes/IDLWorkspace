function line_plane_intersection, line_a, line_b, plane_a, plane_b, plane_c

x1=plane_a[0]
y1=plane_a[1]
z1=plane_a[2]

x2=plane_b[0]
y2=plane_b[1]
z2=plane_b[2]

x3=plane_c[0]
y3=plane_c[1]
z3=plane_c[2]

x4=line_a[0]
y4=line_a[1]
z4=line_a[2]

x5=line_b[0]
y5=line_b[1]
z5=line_b[2]

det1=determ(transpose([[1 ,1 ,1 ,1 ],$
                       [x1,x2,x3,x4],$
                       [y1,y2,y3,y4],$
                       [z1,z2,z3,z4]]))
det2=determ(transpose([[1 ,1 ,1 ,0 ],$
                       [x1,x2,x3,x5-x4],$
                       [y1,y2,y3,y5-y4],$
                       [z1,z2,z3,z5-z4]]))
          

t=-det1/det2
return,[x4+(x5-x4)*t,y4+(y5-y4)*t,z4+(z5-z4)*t]
end