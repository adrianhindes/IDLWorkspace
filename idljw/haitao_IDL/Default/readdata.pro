pro readdata

;data 06-02-2013 for probe
fil1='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\md_81746.SPE'
fil2='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\md_81747.SPE'
fil3='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\md_81748.SPE'
fil4='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\md_81749.SPE'
fil5='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 06-02-2014\md_81750.SPE'
pfile=[fil1,fil2,fil3,fil4,fil5]
save, pfile,filename='data for probe.save'

stop
end










;data 11-12-2013, change i-ring, rfpower and keep the RF freq 4.5 MHz to see the pattern
;keep i -ring around 3990

fil1='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81538.SPE'
fil2='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81535.SPE'
fil3='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81554.SPE'
fil4='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81532.SPE'
fil5='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81541.SPE'

i_3990=[fil1, fil2,fil3,fil4,fil5]
power3990=[6.47,11.68,15.26,18.81,25.93]
save, i_3990, power3990,filename='data of i equals 3990.save'

;keep i -ring around 4190
fil6='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81539.SPE'
fil7='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81536.SPE'
fil8='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81533.SPE'
fil9='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81556.SPE'
fil10='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81542.SPE'

i_4190=[fil6, fil7,fil8,fil9,fil10]
power4190=[6.38,11.65,18.17,18.43,25.29]
save, i_4190, power4190,filename='data of i equals 4190.save'

;keep i -ring around 4390
fil11='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81540.SPE'
fil12='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81543.SPE'
fil13='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81537.SPE'
fil14='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81534.SPE'
fil15='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81557.SPE'

i_4390=[fil11, fil12,fil13,fil14,fil15]
power4390=[6.43,10.88,11.70,17.85,18.02]
save, i_4390, power4390,filename='data of i equals 4390.save'


; keep power around 18-19 kw
fil16='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81532.SPE'
fil17='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81533.SPE'
fil18='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81534.SPE'
fil19='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81558.SPE'
fil20='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81559.SPE'

p_18=[fil16, fil17,fil18,fil19,fil20]
i18=[3992.0,4190.0,4391.0,4593.0,4789.0]
save, p_18,i18,filename='data of power equals 18.save'

; keep power around 11 kw
fil21='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81536.SPE'
fil22='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81537.SPE'
fil23='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81543.SPE'

p_11=[fil21, fil22,fil23]
i11=[4191.0,4390.0,4391.0]
save, p_11,i11,filename='data of power equals 11.save'

; keep power around 6 kw
fil24='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81538.SPE'
fil25='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81539.SPE'
fil26='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81540.SPE'

p_6=[fil24, fil25,fil26]
i6=[3989.0,4190.0,4390.0]
save, p_6,i6,filename='data of power equals 6.save'


; keep power around 25 kw
fil26='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81541.SPE'
fil27='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\md_81542.SPE'

p_25=[fil26, fil27]
i25=[3989.0,4190.0]
save, p_25,i25,filename='data of power equals 25.save'


;spectrometer data
fil28='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\spectrometer\shaun_81538.spe' ;i=3990,p=16.83
fil29='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\spectrometer\shaun_81535.spe' ;i=4190, p=18.17
fil30='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\spectrometer\shaun_81555.spe'
fil31='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\spectrometer\shaun_81532.spe'
fil32='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\spectrometer\shaun_81541.spe'

is_3990=[fil28,fil29,fil30,fil31,fil32]
power3990=[6.47,11.68,16.83,18.81,25.93]
save, is_3990, power3990,filename='sp data when i equals 3990.save'

fil33='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\spectrometer\shaun_81532.spe' ;i=3990,p=16.83
fil34='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\spectrometer\shaun_81533.spe' ;i=4190, p=18.17
fil35='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\spectrometer\shaun_81534.spe'
fil36='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\spectrometer\shaun_81558.spe'
fil37='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\spectrometer\shaun_81559.spe'

ps_18=[fil33,fil34,fil35,fil36,fil37]
i18=[3992.0,4190.0,4391.0,4593.0,4789.0]
save, ps_18, i18,filename='sp data when power equals 18.save'








stop
end


