" use syntax folding
setlocal foldmethod=syntax

" make
setlocal makeprg=javac\ -g\ $*\ %
setlocal errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#,%-G%.%#

