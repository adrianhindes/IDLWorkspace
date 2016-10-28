
z=image(dist(10),/axis_style,font_size=10,title='aa',dimensions=[900,600])
; 900 by 600 -- in ppt it ends up that 100 pixels is 1" for
;               landscape ppt, is about 9 or 10 inches wide then can
;               use font_size for thefont size_appropriately

z.scale, 80,50  ; scale a 10x10 image to 800x500 (leaving some space for axes etc)

z.save,'~/test.png',resolution=300
; save it with 300dpi resolution

end

