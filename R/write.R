#' raw2gdx
#'
#' Save to a GAMS gdx file. Works on a named list providing
#' domains and data as given by gdxrrw::rgdx.
#' This is a *workaround* to fix bugs in the implementation of gdxrrw::wgdx,
#' namely the problems that domains are lost when writing the output of gdxrrw:rgdx
#' and that for variables, a `_field` domain has always to be given.
#' Using this wrapper, round-tripping data between R and gdx files should be possible.
#' @param gdx the gdx filename.
#' @param var list of properties of a gdx symbol as provided by gdxrrw::rgdx.
#' @import data.table

raw2gdx <- function(gdx, var){
    uels <- list()
    if (var$type == "variable" && var$field != "all"){
        ## create field dimension
        flds <- c("l", "m", "lo", "s")
        fld_idx <- match(var$field, flds)
        ## add it the matrix
        var$val <- cbind(var$val[, 1:var$dim], rep(fld_idx, nrow(var$val)), var$val[, var$dim + 1])
        ## add it to domains
        var$domains <- c(var$domains, "_field")
        ## add it to uels
        var$uels[[var$dim + 1]] <- flds
        ## field to all (required to write!)
        var$field <- "all"
    }
    for (n in 1:var$dim){
        uels[[n]] <- list(name=var$domains[[n]], type="set", uels=list(var$uels[[n]]))
    }
    gdxrrw::wgdx(gdx, var, uels)
}


#' writegdx
#'
#' Save a data.table to a GAMS gdx file.
#' @param gdx the gdx filename.
#' @param dt a data.table.
#' @param name name of the variable.
#' @param valcol name of data column.
#' @param uelcols vector of column names with index dimensions.
#' @param type type of symbol (variable or parameter)
#' @param field the field if `type == 'variable'`
#' @export
#' @examples
#' \dontrun{
#' dt <- as.data.table(mtcars, keep.rownames = TRUE)
#' tmpgdx <- file.path(tempdir(), "test.gdx")
#' test_var <- "mtcars"
#' writegdx(tmpgdx, dt, test_var, valcol="wt", uelcols="rn", type="parameter")
#' new_dt <- readgdx(tmpgdx, test_var)
#' }
#' @import data.table


writegdx <- function(gdx, dt, name, valcol, uelcols, type="parameter", field="l"){
    data <- list(name=name, type=type, domains=uelcols, dim=length(uelcols))
    if(type == "variable"){
        data[["field"]] <- field
    }

    uels <- list()
    nuel <- 1

    cols <- c(uelcols, valcol)
    dt <- dt[, cols, with=F]

    for(uel in uelcols){
        labels <- unique(dt[[uel]])
        uels[[nuel]] <- labels

        map <- data.table(1:length(labels), labels)
        setnames(map, "labels", uel)

        dt <- dt[map, on=uel]
        dt[, (uel) := NULL]
        setnames(dt, "V1", uel)
        nuel <- nuel + 1
    }

    data[["val"]] <- unname(as.matrix(dt[, cols, with=F]))
    data[["uels"]] <- uels
    ## type code is "free":
    data[["typeCode"]] <- 5

    raw2gdx(gdx, data)
}


#' writegdx.variable
#'
#' Save a data.table to a variable in a GAMS gdx file.
#' @param gdx the gdx filename.
#' @param dt a data.table.
#' @param name name of the variable.
#' @param valcol name of data column.
#' @param uelcols vector of column names with index dimensions.
#' @param field the field if `type == 'variable'`
#' @export
#' @examples
#' \dontrun{
#' dt <- as.data.table(mtcars, keep.rownames = TRUE)
#' tmpgdx <- file.path(tempdir(), "test.gdx")
#' test_var <- "mtcars"
#' writegdx.variable(tmpgdx, dt, test_var, valcol="wt", uelcols="rn", field="l")
#' new_dt <- readgdx(tmpgdx, test_var)
#' }

writegdx.variable <- function(gdx, dt, name, valcol, uelcols, field="l"){
    writegdx(gdx, dt, name, valcol, uelcols, type="variable", field="l")
}


#' writegdx.parameter
#'
#' Save a data.table to a parameter in a GAMS gdx file.
#' @param gdx the gdx filename.
#' @param dt a data.table.
#' @param name name of the parameter.
#' @param valcol name of data column.
#' @param uelcols vector of column names with index dimensions.
#' @export
#' @examples
#' \dontrun{
#' dt <- as.data.table(mtcars, keep.rownames = TRUE)
#' tmpgdx <- file.path(tempdir(), "test.gdx")
#' test_var <- "mtcars"
#' writegdx.parameter(tmpgdx, dt, test_var, valcol="wt", uelcols="rn")
#' new_dt <- readgdx(tmpgdx, test_var)
#' }

writegdx.parameter <- function(gdx, dt, name, valcol, uelcols){
    writegdx(gdx, dt, name, valcol, uelcols, type="parameter")
}
