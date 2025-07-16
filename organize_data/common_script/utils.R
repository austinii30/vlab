library(this.path)

# NOTE: if 'this.dir()' is written inside a function in a script, 
#       and another main.R sourced the script, and used the 
#       function, than the returned value will be the directory
#       of the main.R script, not the script with the function
outpath <- function (file) {
    return(file.path(this.dir(), "../output", file))
}

rawdatpath <- function (file) {
    return(file.path(this.dir(), "../data/raw", file))
}

ppdatpath <- function (file) {
    return(file.path(this.dir(), "../data/preprocessed", file))
}

lpdatpath <- function (file) {
    return(file.path(this.dir(), "../data/preprocessed/largefiles", file))
}

rlibs   <- function (file) {
    return(file.path(this.dir(), file))
}

rscript <- function (file) {
    return(file.path(this.dir(), file))
}

echo <- function (..., ln="\n", sep="") {
    cat(..., ln, sep=sep)
}

# execute/test scripts
execute <- function (path) { try(source(rscript(path))) }

import <- function (path) { source(rlibs(path)) }

# output stream
datlogpath <- function (datName, path) {  
    return(outpath(file.path(datName, 
                             paste0("[", datName, "]_", path, ".txt"))))
}

dirlogpath <- function (dir, path) {  
    return(outpath(file.path(dir, paste0(path, ".txt"))))
}

out <- function (datName, path) { 
    return (file.path(outdir_, datName,
                      paste0("[", datName, "]_", path, ".txt"))) 
}

# to separate sections of output
section <- function (description) {
    cat("\n", 
        strrep("$", 80), "\n\n", 
        strrep(" ", 10), description, "\n\n", 
        strrep("$", 80), "\n", sep="")
}

subsection <- function (description) {
    cat("\n", 
        strrep("=", 80), "\n", 
        strrep(" ", 10), description, "\n", 
        strrep("=", 80), "\n", sep="")
}

readableTime <- function (t) {
    return(format(t, "%Y-%m-%d %H:%M:%S"))
}

duration <- function (t, units="secs") {
    return(as.numeric(t, units=units))
}

pctg <- function (x, dec=2) {
    return(round(x, dec))
}
