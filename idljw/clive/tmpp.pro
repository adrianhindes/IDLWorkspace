PRO test_event, ev

 

; The common block holds variables that are shared between the

; routine and its event handler:

COMMON T, draw, dbutt, done, image

 

; Define what happens when you click the "Draw ROI" button:

IF ev.id EQ dbutt THEN BEGIN

   ; The ROI definition will be stored in the variable Q:

   Q = CW_DEFROI(draw)

   IF (Q[0] NE -1) then BEGIN

      ; Show the size of the ROI definition array:

      HELP, Q

      ; Duplicate the original image.

      image2 = image

 

      ; Set the points in the ROI array Q equal to a single

      ; color value:

      image2(Q)=!P.COLOR-1

      ; Get the window ID of the draw widget:

      WIDGET_CONTROL, draw, GET_VALUE=W

 

      ; Set the draw widget as the current graphics window:

      WSET, W

 

      ; Load the image plus the ROI into the draw widget:

      TV, image2

   ENDIF

ENDIF

 

; Define what happens when you click the "Done" button:

IF ev.id EQ done THEN WIDGET_CONTROL, ev.top, /DESTROY

 

END

PRO test

COMMON T, draw, dbutt, done, image

 

; Create a base to hold the draw widget and buttons:

base = WIDGET_BASE(/COLUMN)

 

; Create a draw widget that will return both button and 

; motion events:

draw = WIDGET_DRAW(base, XSIZE=256, YSIZE=256, /BUTTON, /MOTION)

dbutt = WIDGET_BUTTON(base, VALUE='Draw ROI')

done = WIDGET_BUTTON(base, VALUE='Done')

WIDGET_CONTROL, base, /REALIZE

 

; Get the widget ID of the draw widget:

WIDGET_CONTROL, draw, GET_VALUE=W

 

; Set the draw widget as the current graphics window:

WSET, W

 

; Create an original image:

image = BYTSCL(SIN(DIST(256)))

 

; Display the image in the draw widget:

TV, image

 

; Start XMANAGER:

XMANAGER, "test", base

 

END
