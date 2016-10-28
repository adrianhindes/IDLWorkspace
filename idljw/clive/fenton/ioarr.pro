; Procedure to determine fibre array element for input
; and output arrays
; Written by Fenton Glass, Apr, 2000

pro ioarr
@ioarr.ini
io=''
print, 'In Array (I/O)?'
input, io

print, 'x-element?'
input, x
print, 'y-element?'
input, y

if io eq 'i' then print 'Corresponding output array element is ', O_arr(x+1,y+1)if io eq 'o' then print 'Corresponding input array element is ', I_arr(x+1,y+1)

end
