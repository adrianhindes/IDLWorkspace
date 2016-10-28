pro time_legend,txt
f=!p.font
!p.font=0
xyouts,0.80,1,txt+' at '+systime(),charsize=0.6,/normal
!p.font=f
end
