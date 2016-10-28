;==========================================================================================

;NTI_WAVELET_RUN.PRO

;==========================================================================================
;-- This is the main program of NTI WAVELET TOOLS (in MTR)
;-- This program call the routines of calculations
;==========================================================================================

pro nti_wavelet_run,data_block

;This is a test message
nti_wavelet_gui_addmessage, addtext="Hello World, I'm nti_wavelet_run"

;print,"-----------------------------------------------------"
;help,/st,state
;print,"-----------------------------------------------------"


;Testing handle of state structure
shotnumber=data_block.shotnumber
nti_wavelet_gui_addmessage, addtext="shotnumber:"
nti_wavelet_gui_addmessage, addtext=string(shotnumber)

end