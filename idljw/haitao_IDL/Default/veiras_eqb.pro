function crycom, wavelength, l,alpha, del, sita,n_e=n_e,n_o=n_o ;veiras equation for BBO
 delta=bbo(wavelength, n_e=n_e,n_o=n_o)
 dnodt=-16.6*1d-5
 dnedt=-9.3*1d-6
 term1=sqrt(n_o*2*dnodt-sin(alpha)^2)
 term2=(n_o*2*dnodt-n_e*2*dnedt)*sin(sita)*cos(sita)*cos(del)*sin(alpha)/(n_e*2*dnedt*sin(sita)^2+n_o*2*dnodt*cos(sita)^2)
 term3=(-dnodt)/(n_e*2*dnedt*sin(sita)^2+n_o*2*dnodt*cos(sita)^2)*sqrt(n_e*2*dnedt*(n_e*2*dnedt*sin(sita)^2+n_o*2*dnodt*cos(sita)^2)-(n_e*2*dnedt-(n_e*2*dnedt-n_o*2*dnedt)*cos(sita)^2*sin(del)^2)*sin(alpha)^2)
 phase_shift=2*!pi*l*1e-3/(wavelength*1e-9)*(term1+term2+term3)
 return, phase_shift
end