pro mdsedit, tree, shotno, status=status, quiet=quiet

mdstcl,'edit ' + tree + '/shot='+strtrim(shotno, 2), status=status, quiet=quiet
if not status then print, 'Cannot open '+tree+' for edit at shot '+strtrim(shotno,2)

end
