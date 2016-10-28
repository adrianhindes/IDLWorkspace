function query_seg_images, tree, shotno, node, status=status

if n_params() ne 3 then stop, 'Query_seg_images: supply tree, shotno, node'

mdsopen, tree, shotno
n_images = mdsvalue('GetNumSegments('+node+')', status=status, /quiet)
mdsclose, tree, shotno

if status then return, n_images else return, -1

end
