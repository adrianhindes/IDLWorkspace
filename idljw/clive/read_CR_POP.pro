; read population density and emisssion coef from CR_POP.dat
; -----------------------------------------------------------------
PRO read_CR_POP, cr_pop, file=file

   if (n_elements(file) eq 0) then $
;      file = 'C:\cygwin\home\Plasma\crm\CR_POP' 
      file = '~/crm/crm/CR_POP' 
   file = file + '.dat'   

   fmt0 = '' 
   fmt1 = '' 
   fmt2 = ''
   
   openr, lun, file, /get_lun
   
   ; records, data format
   readf, lun, format = '(/,/,/,a1,i6,i6,i6,i6,a13,a13,/)', $
      fmt0, steps, nte, nne, ULC, fmt1, fmt2 
   pos1 = strpos(fmt1,'(')
   pos2 = strpos(fmt2,'(')
   num1 = fix(strmid(fmt1, 0, pos1))
   num2 = fix(strmid(fmt2, 0, pos2))
   fmt1 = '(/,' + fmt1
   fmt2 = '(/,' + fmt2
   
   pop  = make_array(num1, steps, value=0d, /double) ; nte*nne
   lam  = make_array(num2, value=0d, /double)
   emi  = make_array(num2, steps, value=0d, /double) ; nte*nne
   
   ; read pop, lam, emi
   readf, lun, format = fmt1, pop
   readf, lun, format = fmt2, lam
   readf, lun, format = fmt2, emi
   cr_pop = {steps:steps, nte:round(nte), nne:round(nne), pop:pop, lam:lam, emi:emi}
   
   free_lun, lun
   
END
