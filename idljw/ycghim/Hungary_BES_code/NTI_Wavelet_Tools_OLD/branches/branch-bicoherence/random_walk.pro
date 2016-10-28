pro random_walk,c,n

;c: szórás
;n: lépések száma

  dphi=c*randomn(seed,n,/NORMAL)
  x=0
  y=0
  phi=0
  xx=dindgen(n_elements(dphi)+1)
  yy=dindgen(n_elements(dphi)+1)
  xx[0]=0
  yy[0]=0

    for i=0L,long(n_elements(dphi)-1) do begin
      phi=phi+dphi[i]
      x=x+cos(phi)
      y=y+sin(phi)
      xx[i+1]=x
      yy[i+1]=y
    end

  rel_length=(sqrt(x^2+y^2))/i

plot,xx,yy
print,'relativ_length: '+pg_num2str(rel_length)
print,'end of walk: (x,y)=('+pg_num2str(x)+','+pg_num2str(y)+')'
end