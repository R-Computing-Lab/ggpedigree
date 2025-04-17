read_MTDNA <- function(path='Z:/Data/2024/Smith_Burt_143000_Demographic_Export.txt',
                       var_nrows,
                       delim='|',
                       as.is=TRUE){

  require(data.table) # for transpose() list function
  require(stringi) # for stri_split_fixed() function
  
  temp_x <- readLines(
  path,
  n=var_nrows)


## extraxt var names
temp_n <- temp_x[1]
if(delim == '\\|' | delim == '|'){
  temp_n <- strsplit(temp_n, '|',fixed = TRUE)[[1]]
  temp_x <- temp_x[-1]

  #fix df
  df <- as.data.frame(data.table::transpose(stringi::stri_split_fixed(temp_x,
                                                   '|',
                                                   n=length(temp_n)))[],
                        col.names=temp_n)
} else if(delim == ','){

  temp_n <- strsplit(temp_n, ',')[[1]]
  temp_x <- temp_x[-1]

  #fix df
  df <- as.data.frame(data.table::transpose(stringi::stri_split_fixed(temp_x,
                                     ',',
                                     n=length(temp_n))),
                    col.names=temp_n)
} else {
  error("Uncoded Delim selected")
}

# when feeling lazy
df  <- type.convert(df ,
                        as.is=as.is) # keeps strings as strings

return(df)
}
