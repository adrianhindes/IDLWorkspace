pro calch_nicholet,H,z_in,nofix1=nofix1,nofix2=nofix2
; ********************* calch_nicolet.pro ************************
; Calculates H (undulation) matrix for 1D cross-correlation vector
; z is the vector of z values for the density profile
; /nofix1: do not integrate undulation below z_in(0)
; /nofix2: do not integrate undulation above z_in(last)
; ****************************************************************
n=(size(z_in))(1)
fix1=z_in(0)-(z_in(1)-z_in(0))
fix2=z_in(n-1)+(z_in(n-1)-z_in(n-2))
z=float([fix1,z_in,fix2])
H=dblarr(n*n,n*n)
for i=0,n-1 do begin
  for j=0,n-1 do begin
    iz=i+1
    jz=j+1
		mask=[0,1,1,1,1]
		if (keyword_set(nofix1) and (i eq 0)) then begin
      mask(1)=0
			mask(3)=0
		endif	    
		if (keyword_set(nofix1) and (j eq 0)) then begin
      mask(1)=0
			mask(2)=0
		endif	    
		if (keyword_set(nofix2) and (i eq n-1)) then begin
      mask(2)=0
			mask(4)=0
		endif	    
		if (keyword_set(nofix2) and (j eq n-1)) then begin
      mask(3)=0
			mask(4)=0
		endif
		if (mask(1)) then begin
      H(i*n+j,i*n+j)=H(i*n+j,i*n+j)+1.0/3.0*(z(jz)-z(jz-1))/(z(iz)-z(iz-1))
      H(i*n+j,i*n+j)=H(i*n+j,i*n+j)+1.0/3.0*(z(iz)-z(iz-1))/(z(jz)-z(jz-1))
		endif	
		if (mask(2)) then begin
      H(i*n+j,i*n+j)=H(i*n+j,i*n+j)+1.0/3.0*(z(jz)-z(jz-1))/(z(iz+1)-z(iz))
      H(i*n+j,i*n+j)=H(i*n+j,i*n+j)+1.0/3.0*(z(iz+1)-z(iz))/(z(jz)-z(jz-1))
		endif	
		if (mask(3)) then begin
      H(i*n+j,i*n+j)=H(i*n+j,i*n+j)+1.0/3.0*(z(jz+1)-z(jz))/(z(iz)-z(iz-1))
      H(i*n+j,i*n+j)=H(i*n+j,i*n+j)+1.0/3.0*(z(iz)-z(iz-1))/(z(jz+1)-z(jz))
	  endif
		if (mask(4)) then begin
      H(i*n+j,i*n+j)=H(i*n+j,i*n+j)+1.0/3.0*(z(jz+1)-z(jz))/(z(iz+1)-z(iz))
      H(i*n+j,i*n+j)=H(i*n+j,i*n+j)+1.0/3.0*(z(iz+1)-z(iz))/(z(jz+1)-z(jz))
		endif	
  endfor
endfor

for i=0,n-2 do begin
  for j=0,n-1 do begin
    iz=i+1
    jz=j+1    
		mask=[0,0,1,0,1]
		if (keyword_set(nofix1) and (j eq 0)) then begin
			mask(2)=0
		endif	    
		if (keyword_set(nofix2) and (j eq n-1)) then begin
			mask(4)=0
		endif
		w=0
		if (mask(2)) then begin
      w=w-1.0/3.0*(z(jz)-z(jz-1))/(z(iz+1)-z(iz))
      w=w+1.0/6.0*(z(iz+1)-z(iz))/(z(jz)-z(jz-1))
		endif	
		if (mask(4)) then begin
      w=w-1.0/3.0*(z(jz+1)-z(jz))/(z(iz+1)-z(iz))
      w=w+1.0/6.0*(z(iz+1)-z(iz))/(z(jz+1)-z(jz))
		endif	
    H((i+1)*n+j,i*n+j)=w
    H(i*n+j,(i+1)*n+j)=w            
  endfor
endfor

for i=0,n-1 do begin
  for j=0,n-2 do begin
    iz=i+1
    jz=j+1    
		mask=[0,0,0,1,1]
		if (keyword_set(nofix1) and (i eq 0)) then begin
			mask(3)=0
		endif	    
		if (keyword_set(nofix2) and (i eq n-1)) then begin
			mask(4)=0
		endif	
		w=0
		if (mask(3)) then begin
      w=w+1.0/6.0*(z(jz+1)-z(jz))/(z(iz)-z(iz-1))
      w=w-1.0/3.0*(z(iz)-z(iz-1))/(z(jz+1)-z(jz))
		endif  
		if (mask(4)) then begin
      w=w+1.0/6.0*(z(jz+1)-z(jz))/(z(iz+1)-z(iz))
      w=w-1.0/3.0*(z(iz+1)-z(iz))/(z(jz+1)-z(jz))
		endif  
    H(i*n+j,i*n+j+1)=w
    H(i*n+j+1,i*n+j)=w             
  endfor
endfor                  

for i=0,n-2 do begin
  for j=0,n-2 do begin
    iz=i+1
    jz=j+1    
		w=-1.0/6.0*( $
				(z(jz+1)-z(jz))/(z(iz+1)-z(iz)) $
			  +(z(iz+1)-z(iz))/(z(jz+1)-z(jz)) )
    H(i*n+j,(i+1)*n+j+1)=w
    H((i+1)*n+j+1,i*n+j)=w             
  endfor
endfor                  

for i=1,n-1 do begin
  for j=0,n-2 do begin
    iz=i+1
    jz=j+1    
		w=-1.0/6.0*( $
				(z(jz+1)-z(jz))/(z(iz)-z(iz-1)) $
			  +(z(iz)-z(iz-1))/(z(jz+1)-z(jz)) )
    H(i*n+j,(i-1)*n+j+1)=w
    H((i-1)*n+j+1,i*n+j)=w             
  endfor
endfor                  

         
end    

 
