function apdcam10g_4x16_channel_map
; Do not edit this file.
; This is an automatically generated program.
; This function returns a 2D matrix with ADC channel numbers (1...64)
; for the 4x16 channel APDCAM 10G. 
; [0,0] is the upper left corner of the array while [15,3] is the lower right.
map = intarr(16,4)
map[0,0] = 22
map[0,1] = 64
map[0,2] = 40
map[0,3] = 39
map[1,0] = 24
map[1,1] = 62
map[1,2] = 14
map[1,3] = 13
map[2,0] = 9
map[2,1] = 10
map[2,2] = 59
map[2,3] = 57
map[3,0] = 35
map[3,1] = 36
map[3,2] = 17
map[3,3] = 19
map[4,0] = 21
map[4,1] = 23
map[4,2] = 15
map[4,3] = 16
map[5,0] = 63
map[5,1] = 61
map[5,2] = 37
map[5,3] = 38
map[6,0] = 34
map[6,1] = 33
map[6,2] = 60
map[6,3] = 18
map[7,0] = 12
map[7,1] = 11
map[7,2] = 58
map[7,3] = 20
map[8,0] = 52
map[8,1] = 26
map[8,2] = 43
map[8,3] = 44
map[9,0] = 50
map[9,1] = 28
map[9,2] = 1
map[9,3] = 2
map[10,0] = 6
map[10,1] = 5
map[10,2] = 29
map[10,3] = 31
map[11,0] = 48
map[11,1] = 47
map[11,2] = 55
map[11,3] = 53
map[12,0] = 51
map[12,1] = 49
map[12,2] = 4
map[12,3] = 3
map[13,0] = 25
map[13,1] = 27
map[13,2] = 42
map[13,3] = 41
map[14,0] = 45
map[14,1] = 46
map[14,2] = 30
map[14,3] = 56
map[15,0] = 7
map[15,1] = 8
map[15,2] = 32
map[15,3] = 54
return,map
end