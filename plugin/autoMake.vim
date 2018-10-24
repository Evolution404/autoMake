"------------------------------------------------------------------------------
"  <一键编译运行>
"------------------------------------------------------------------------------

func! CompileGcc()  
    exec "w"  
    let compilecmd="!gcc "  
    let compileflag="-o %< "  
    if search("mpi\.h") != 0  
        let compilecmd = "!mpicc "  
    endif  
    if search("glut\.h") != 0  
        let compileflag .= " -lglut -lGLU -lGL "  
    endif  
    if search("cv\.h") != 0  
        let compileflag .= " -lcv -lhighgui -lcvaux "  
    endif  
    if search("omp\.h") != 0  
        let compileflag .= " -fopenmp "  
    endif  
    if search("math\.h") != 0  
        let compileflag .= " -lm "  
    endif  
    exec compilecmd." % ".compileflag  
endfunc  
func! CompileGpp()  
    exec "w"  
    let compilecmd="!g++ "  
    let compileflag="-o %< "  
    let link=""
    if search("mpi\.h") != 0  
        let compilecmd = "!mpic++ "  
    endif  
    if search("glut\.h") != 0  
        let compileflag .= " -lglut -lGLU -lGL "  
    endif  
    if search("cv\.h") != 0  
        let compileflag .= " -lcv -lhighgui -lcvaux "  
    endif  
    if search("omp\.h") != 0  
        let compileflag .= " -fopenmp "  
    endif  
    if search("math\.h") != 0  
        let compileflag .= " -lm "  
    endif  
"添加c++连接其他源文件编译
py3 <<eof
import vim
import re
import os
link = ""
for line in vim.current.buffer:
    if(re.match("#include[ ]*\".*\.h",line)):
        rex = re.compile("#include[ ]*\"(.*?)\.h")
        fileName =rex.findall(line)[0]+".cpp" 
        tfileName = vim.eval("expand('%:t')")
        if tfileName == fileName:
            continue;
        if os.path.isfile(fileName):
            link += rex.findall(line)[0]+".cpp "
vim.command("let link .="+"\""+link+"\"")
eof
    exec compilecmd.link." % ".compileflag  
endfunc  
  
func! RunPython()  
        exec "!python3 %"  
endfunc  
func! CompileJava()  
    exec "!javac %"  
endfunc  
  
  
func! CompileCode()  
		exe(":cd %:p:h")
        exec "w"  
        if &filetype == "cpp"  
                exec "call CompileGpp()"  
        elseif &filetype == "c"  
                exec "call CompileGcc()"  
        elseif &filetype == "python"  
                exec "call RunPython()"  
        elseif &filetype == "java"  
                exec "call CompileJava()"  
        endif  
endfunc 
" 在浏览器预览 for Mac
function! ViewInBrowser()
    let name = "cr"
    let file = expand("%:p")
    let l:browsers = {
        \"cr":"open -a \"Google Chrome\"",
        \"ff":"open -a Firefox",
    \}
    let htdocs='/Users/leon1/'
    let strpos = stridx(file, substitute(htdocs, '\\\\', '\', "g"))
    let file = '"'. file . '"'
    exec ":update " .file
    "echo file .' ## '. htdocs
    if strpos == -1
        exec ":silent ! ". l:browsers[name] ." file://". file
    else
        let file=substitute(file, htdocs, "http://127.0.0.1:8090/", "g")
        let file=substitute(file, '\\', '/', "g")
        exec ":silent ! ". l:browsers[name] file
    endif
endfunction 
  
func! RunResult()  
        if &filetype != "python"  
            call CompileCode()
        endif
        exec "w"  
        if search("mpi\.h") != 0  
            exec "!mpirun -np 4 ./%<"  
        elseif &filetype == "cpp"  
            exec "! ./%<"  
        elseif &filetype == "c"  
            exec "! ./%<"  
        elseif &filetype == "python"  
            exec "call RunPython()"  
        elseif &filetype == "java"  
            exec "!java %<"  
	elseif &filetype == "html"  
            exec "call ViewInBrowser()"
        endif  
endfunc  

func! <SID>Debug()
    packadd termdebug
    exec 'set makeprg=gcc\ -g\ '.expand("%").'\ -o\ '.expand("%<")
    make
    exec "Termdebug %<"
    exec "norm \<c-w>j"
    exec "norm \<c-w>j"
    exec "norm \<c-w>L"
    exec "norm \<c-w>h"
endf
  
  
map <F5> :call RunResult()<CR>
map <F6> :call <SID>Debug()<cr>

