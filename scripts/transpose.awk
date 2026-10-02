BEGIN {
    # number of rows and columns in original input. rows is indexed by row,
    # then column.
    nr = 0;
    nc = 0;
}

# copies current input into rows
{
    for (i = 1; i <= NF; i++) {
        rows[nr][i-1] = $i
    }
    nr++
}

NF > nc { nc = NF; }

END {
    # prints each original input column as a row of output
    for (c = 0; c < nc; c++) {
        s = rows[0][c]
        for (r = 1; r < nr; r++) {
            s = s OFS rows[r][c]
        }
        print s
    }
}
