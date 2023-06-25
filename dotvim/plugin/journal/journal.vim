" Configure with g:journal_dir

augroup Journal
    autocmd!
    " Inserts journal template for new journal files
    autocmd BufNewFile journal/*/*.md 0r journal/entry-template.md
    " Inserts date into template
    autocmd BufNewFile journal/**/*.md call JournalToday()

    fun JournalToday()
        let line = 'date: ' . strftime("%F %T")
        call append(1, line)
    endfun
augroup END


function! CreateJournalFile()
    let year = strftime('%Y') . '/'
    let month = strftime('%m') . '/'
    let day = strftime('%d')
    let file_name = g:journal_dir . year . month . day . '.md'

    " Create the journal directory if it doesn't exist
    if !isdirectory(g:journal_dir)
        call mkdir(expand(fnamemodify(file_name, ':h')), 'p')
    endif

    " Create the file and open a buffer
    execute 'edit ' . file_name
    setlocal fdl=3
    normal! G
endfunction


function! ShowRecentJournalFiles(nr_files=5)

    " Get the list of files matching the format year/month/day
    let files = reverse(sort(glob(g:journal_dir . '*/**/*', 0, 1)))

    " Only keep the last 5 files
    let files = files[0 : (a:nr_files-1)]

    " Create a new split for the buffer
    botright new

    " Open a temporary read-only buffer
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile

    " Read the contents of the files into the buffer
    for file in files
        if isdirectory(file)
            continue
        endif
        let lines = ['[src](' . file . ')']
        call append(line("$"), lines)
        normal G
        silent execute 'read ' . file
        put=''
    endfor

    " Make the buffer read-only after we edit it
    setlocal ro
    setlocal ft=markdown
    setlocal fdl=3
endfunction


function! ReadJournalFilesInDirectory(directory)
    " Get the list of files in the directory
    let files = sort(glob(a:directory . '/*', 0, 1))

    " Create a new split for the buffer
    botright new

    " Open a temporary read-only buffer
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile

    call setline(1, '# Monthly Journal Summary (' . a:directory . ')')
    call setline(2, '')

    " you're a poopyhead,papi

    " Read the contents of each file and append them to the buffer
    for file in files
        if !filereadable(file)
            continue
        endif
        let file_content = readfile(file)
        call append(line('$'), '---')
        call append(line('$'), '[src](' . file . ')')
        call append(line('$'), file_content)
        call append(line('$'), '')
    endfor

    setlocal ro
    set ft=markdown
    setlocal fdl=3
endfunction
