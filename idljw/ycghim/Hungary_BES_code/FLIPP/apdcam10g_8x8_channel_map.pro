function apdcam10g_8x8_channel_map
; Do not edit this file.
; This is an automatically generated program.
; This function returns a 2D matrix with ADC channel numbers (1...64)
; for the 8x8 channel APDCAM 10G. 
; [0,0] is the upper left corner of the array while [7,7] is the lower right.
map = intarr(8,8)
map[0,0] = 33
map[0,1] = 9
map[0,2] = 24
map[0,3] = 22
map[0,4] = 60
map[0,5] = 58
map[0,6] = 39
map[0,7] = 16
map[1,0] = 10
map[1,1] = 34
map[1,2] = 23
map[1,3] = 21
map[1,4] = 59
map[1,5] = 15
map[1,6] = 57
map[1,7] = 40
map[2,0] = 11
map[2,1] = 63
map[2,2] = 36
map[2,3] = 61
map[2,4] = 19
map[2,5] = 17
map[2,6] = 13
map[2,7] = 37
map[3,0] = 35
map[3,1] = 12
map[3,2] = 64
map[3,3] = 62
map[3,4] = 20
map[3,5] = 18
map[3,6] = 38
map[3,7] = 14
map[4,0] = 46
map[4,1] = 6
map[4,2] = 50
map[4,3] = 52
map[4,4] = 30
map[4,5] = 32
map[4,6] = 44
map[4,7] = 3
map[5,0] = 5
map[5,1] = 45
map[5,2] = 49
map[5,3] = 51
map[5,4] = 29
map[5,5] = 4
map[5,6] = 31
map[5,7] = 43
map[6,0] = 8
map[6,1] = 25
map[6,2] = 47
map[6,3] = 27
map[6,4] = 53
map[6,5] = 55
map[6,6] = 2
map[6,7] = 42
map[7,0] = 48
map[7,1] = 7
map[7,2] = 26
map[7,3] = 28
map[7,4] = 54
map[7,5] = 56
map[7,6] = 41
map[7,7] = 1
return,map
end
