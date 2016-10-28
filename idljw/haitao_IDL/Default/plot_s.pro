function add, data_y

y_new=data_y+10

return, y_new
end
;_________________________________________________
pro plot_s

print, 'plots'


ff=read_csv('C:\haitao\papers\PMT camera\PMT measurements\measurement data\300mm picture\scope_1_1.csv', n_table_header=2)
x=ff.field1
y=ff.field2

pl=plot(x,y)

new_y=add(y)

apples=add(x)

pl2=plot(apples, new_y)

stop
end