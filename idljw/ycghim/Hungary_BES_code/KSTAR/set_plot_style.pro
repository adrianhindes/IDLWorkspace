pro set_plot_style,style

if style eq 'small' then begin
  ch1=0.9 & chth1=1. & th1=1. & th2=1 & s_size=1.
  !p.charsize = ch1
  !p.charthick = chth1
  !p.thick = th2
  !x.thick=th1
  !y.thick=th1
  !p.font=0
endif

if style eq 'small1' then begin
  ch1=1.1 & chth1=1. & th1=3. & th2=3. & s_size=1.
  !p.charsize = ch1
  !p.charthick = chth1
  !p.thick = th2
  !x.thick=th1
  !y.thick=th1
  !p.font=0
endif

if style eq 'cikk1' then begin
  ch1=1. & chth1=2. & th1=3. & th2=3. & s_size=1.
  !p.charsize = ch1
  !p.charthick = chth1
  !p.thick = th2
  !x.thick=th1
  !y.thick=th1
  !p.font=0
  !p.symsize=0.2
endif

if style eq 'normal' then begin
  ch1=1.&chth1=1.&th1=1.&th2=1&s_size=1.
  !p.charsize = ch1
  !p.charthick = chth1
  !p.thick = th2
  !x.thick=th1
  !y.thick=th1
endif

if style eq 'foile_1' then begin
  ch1=1.1&chth1=4.&th1=3.&th2=1&s_size=1.
  !p.charsize = ch1
  !p.charthick = chth1
  !p.thick = th2
  !x.thick=th1
  !y.thick=th1
endif

if style eq 'foile_kg' then begin
  ch1=1.2 &  chth1=3. &  th1=3.  &  th2=1  &  s_size=1.
  !p.charsize = ch1
  !p.charthick = chth1
  !p.thick = th2
  !x.thick=th1
  !y.thick=th1
  !p.font=0
;  DEVICE, SET_FONT='Times', /TT_FONT
endif

if style eq 'foile_kg_eps' then begin
  ch1=0.8 &  chth1=3. &  th1=3.  &  th2=2  &  s_size=1.
  !p.charsize = ch1
  !p.charthick = chth1
  !p.thick = th2
  !x.thick=th1
  !y.thick=th1
  !p.font=0
;  DEVICE, SET_FONT='Times', /TT_FONT
endif

if style eq 'poster_kg_eps' then begin
  ch1=1.8 &  chth1=3. &  th1=3.  &  th2=2  &  s_size=1.
  !p.charsize = ch1
  !p.charthick = chth1
  !p.thick = th2
  !x.thick=th1
  !y.thick=th1
  !p.font=0
endif

if style eq 'poster_kg_eps_1' then begin
  ch1=.9 &  chth1=4. &  th1=4.  &  th2=4.
  !p.charsize = ch1
  !p.charthick = chth1
  !p.thick = th2
  !x.thick=th1
  !y.thick=th1
  !p.font=0
endif

if style eq 'foile_kg_eps_large' then begin
  ch1=0.8 &  chth1=3. &  th1=3.  &  th2=1  &  s_size=1.
  !p.charsize = ch1
  !p.charthick = chth1
  !p.thick = th2
  !x.thick=th1
  !y.thick=th1
  !p.font=0
;  DEVICE, SET_FONT='Times', /TT_FONT
endif


if style eq 'paper' then begin
  ch1=1. &  chth1=3. &  th1=3.  &  th2=1  &  s_size=1.
  !p.charsize = ch1
  !p.charthick = chth1
  !p.thick = th2
  !x.thick=th1
  !y.thick=th1
  !p.font=0
endif

if style eq 'paper1' then begin
  ch1=.95 &  chth1=3. &  th1=3.  &  th2=3  &  s_size=1.
  !p.charsize = ch1
  !p.charthick = chth1
  !p.thick = th2
  !x.thick=th1
  !y.thick=th1
  !p.font=0
endif

if style eq 'paper2' then begin
  ch1=1.15 &  chth1=3. &  th1=3.  &  th2=4  &  s_size=1.
  !p.charsize = ch1
  !p.charthick = chth1
  !p.thick = th2
  !x.thick=th1
  !y.thick=th1
  !p.font=0
endif

if style eq 'a4_paper' then begin
  ch1=1.5 &  chth1=1.5 &  th1=6.  &  th2=4  &  s_size=1.
  !p.charsize = ch1
  !p.charthick = chth1
  !p.thick = th2
  !x.thick=th1
  !y.thick=th1
  !p.font=0
endif


end
