function apdcam_channel_map,data_source=data_source
; This function returns the ADC channel number for a detector element in APDCAM.
; Channel numbers start with 1
; Arrangement as wiewed trough the F-mount of the detector
; (4,1)......(4,8)
; (3,1)......(3,8)
; (2,1)......(2,8)
; (1,1)......(1,8)

map = intarr(5,9)
map[1,1] = 18
map[1,2] = 20
map[1,3] = 21
map[1,4] = 23
map[1,5] = 25
map[1,6] = 27
map[1,7] = 28
map[1,8] = 30
map[2,1] = 19
map[2,2] = 17
map[2,3] = 22
map[2,4] = 24
map[2,5] = 26
map[2,6] = 32
map[2,7] = 29
map[2,8] = 31
map[3,1] = 15
map[3,2] = 13
map[3,3] = 16
map[3,4] = 10
map[3,5] = 8
map[3,6] = 6
map[3,7] = 1
map[3,8] = 3
map[4,1] = 14
map[4,2] = 12
map[4,3] = 11
map[4,4] = 9
map[4,5] = 7
map[4,6] = 5
map[4,7] = 4
map[4,8] = 2

return,map[1:4,1:8]
end