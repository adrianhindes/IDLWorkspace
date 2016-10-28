pro kstar_read_PF_currents, PF1, PF2, PF3U, PF4U, PF5U, PF6U,$
                                 PF3L, PF4L, PF5L, PF6L, PF7, IVFC

print,'Reading poloidal field coil currents ...'
PF1 = kstar_read_node('\PCPF1U', local='KSTAR.PF:PF1')
PF2 = kstar_read_node('\PCPF2U', local='KSTAR.PF:PF2')
PF3U = kstar_read_node('\PCPF3U', local='KSTAR.PF:PF3U')
PF4U = kstar_read_node('\PCPF4U', local='KSTAR.PF:PF4U')
PF5U = kstar_read_node('\PCPF5U', local='KSTAR.PF:PF5U')
PF6U = kstar_read_node('\PCPF6U', local='KSTAR.PF:PF6U')

PF3L = kstar_read_node('\PCPF3L', local='KSTAR.PF:PF3L')
PF4L = kstar_read_node('\PCPF4L', local='KSTAR.PF:PF4L')
PF5L = kstar_read_node('\PCPF5L', local='KSTAR.PF:PF5L')
PF6L = kstar_read_node('\PCPF6L', local='KSTAR.PF:PF6L')

PF7 = kstar_read_node('\PCPF7U', local='KSTAR.PF:PF7')
IVFC = kstar_read_node('\PCIVCU', local='KSTAR.PF:IVFC')


end

