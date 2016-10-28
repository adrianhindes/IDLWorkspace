function dcrycom, wavelength, l,alpha, del, sita,n_e=n_e,n_o=n_o ;veiras equation for BBO
 delta=bbo(wavelength, n_e=n_e,n_o=n_o)
 dnodt=-16.6*1d-6
 dnedt=-9.3*1d-6
 term1=(2*dnodt*n_o-sin(alpha)^2)/2.0/sqrt(n_o^2-sin(alpha)^2)
 term2=((2*dnodt*n_o-2*dnedt*n_e)*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_o^2-n_e^2)*(2*n_e*dnedt*sin(sita)^2+2*n_o*dnodt*cos(sita)^2))/((n_e^2*sin(sita)^2+n_o^2*cos(sita)^2))^2*sin(sita)*cos(sita)*cos(del)*sin(alpha)
 term3=(-dnodt)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*sqrt(n_e^2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_e^2-(n_e^2-n_o^2)*cos(sita)^2*sin(del)^2)*sin(alpha)^2)
 term4=-n_o/sqrt(n_e^2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)-(n_e^2-(n_e^2-n_o^2)*cos(sita)^2*sin(del)^2)*sin(alpha)^2)
 term5=2*dnedt*n_e-(2*n_e*dnedt*sin(alpha)^2-n_e^2*sin(alpha)^2*2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*(2*n_e*dnedt*sin(sita)^2-2*n_o*dnodt*cos(sita)^2))/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)^4-((n_e^2-n_o^2)*cos(sita)^2*sin(del)^2)*2*(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)*(2*n_e*dnedt*sin(sita)^2)/(n_e^2*sin(sita)^2+n_o^2*cos(sita)^2)^4
 phase_shift=2*!pi*l*1e-3/(wavelength*1e-9)*(term1+term2+term3*(term4+term5))
 
 return, phase_shift
end