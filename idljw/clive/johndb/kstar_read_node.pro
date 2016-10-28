function kstar_read_node, node, local=local, kstar=kstar, status=status

if keyword_set(local) then name=local else name=node

return, create_struct( $
                    'name', name, $   ; this is the name in the local database
                    'units', string(mdsvalue("units("+node+")",status=status,/quiet)), $
                    'data', mdsvalue(node,/quiet), $;/1e3
                    'time', mdsvalue('dim_of('+node+')',/quiet) )

end

