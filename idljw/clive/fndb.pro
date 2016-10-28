#!/bin/bash
lst2=`grep  -F -i -l  $1 *.pro`
#chmod 0 ~/idl/j
#chmod 0 ~/idl/anu
#lst2=`grep -r -i -l --include=\"*.pro\"  $1 *`
echo $lst2
ls -lart $lst2

#chmod o+rwx,g+rx,a+rx ~/idl/j
#chmod o+rwx,g+rx,a+rx ~/idl/anu
