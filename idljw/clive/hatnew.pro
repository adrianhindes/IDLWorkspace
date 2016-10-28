function hatnew, th0, thw, ang,sgexp=sgexp
rval1= ang gt th0-thw/2 and ang lt th0+thw/2
; make exp-6
;default,sgexp,4
;rval1 = exp( - ((ang - th0)/thw)^sgexp)
return,rval1
end
