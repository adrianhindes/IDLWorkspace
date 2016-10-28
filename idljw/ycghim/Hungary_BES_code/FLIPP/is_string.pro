function is_string,input

; ************************ is_string.pro ******** S. Zoletnik	10.12.1998 ****
; Returns 1 if the input argument is string else 0
; ***************************************************************************

dim = (size(input))(0)
code = (size(input))(1+dim)
return,code eq 7
end
