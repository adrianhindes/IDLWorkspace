pro read_data,num
num=strtrim(string(num),2)
file=strtrim('D:\MDSPLUS_DATA\PLL2_DATA\pll_0'+num+'.lvm',2)
dum=read_ascii(file,data_start=23,delim=string(byte(9)))
data=dum.field1
plot, data(1,*)
yn=''
read,'Do you want to save data(y/n)',yn
if yn ne 'y' then retall
af:
save, data, file='D:\MDSPLUS_DATA\PLL2_DATA\'+'data'+num+'.save'
stop
end