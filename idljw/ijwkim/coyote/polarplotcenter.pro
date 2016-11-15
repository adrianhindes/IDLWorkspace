PRO PolarPlotCenter, radius, angle

  ; Fake data if needed.
  IF N_Params() EQ 0 THEN BEGIN
    angle = ((Randomu(seed, 360)*360) - 180) * !DtoR
    radius = Randomu(seed, 360) * 100
  ENDIF

  ; Establish plot coordinates
  cgPlot, radius, angle, /Polar, XStyle=5, YStyle=5, $
    /NoData, Aspect=1.0

  ; Draw axis through center.
  cgAxis, /XAxis, 0, 0
  cgAxis, /YAxis, 0, 0

  ; Plot data.
  cgPlot, radius, angle, PSym=2, Color='olive', /Overplot, /Polar

  ; Draw 25 and 75 percent circles.
  dataMax = Max(radius)
  percent25 = Circle(0, 0, 0.25*dataMax)
  percent75 = Circle(0, 0, 0.75*dataMax)
  cgPlotS, percent25, Color='red'
  cgPlotS, percent75, Color='red'

END