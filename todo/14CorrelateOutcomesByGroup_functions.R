#------------------------------------------------------------------------------
# Author Mason Garrison
# Date: 815
# Filename: functions_CorrelateOutcomesByGroup
# Purpose: this code calcuates the correlation between the outcomes for each kin group, groups by mtdna, cnu, and bins of R

#------------------------------------------------------------------------------

## First are the helper functions
options(scipen=10, digits=11)
## passes subset if slice_1000 is true, otherwise passes entire thing
sliceFuction <- function(tbl,slice_1000){
  if(slice_1000){
    tbl %>% slice(1:1000)
  } else {
    tbl
  }
}

# passes thru multiple grouping variables. right now I'm using groupby, but this could be replaced by expand grid. 
# it does allow for multiple groups
group_byFunction <- function(tbl,grouping_vars){
  if(is.na(grouping_vars)){
    tbl
  } else {
    grouping_call <- paste0("tbl %>% group_by(",
                            paste(grouping_vars,collapse =", "),")")
    
    eval(parse(text = grouping_call))
  }
}

mutateFunction <- function(tbl, mutate_vars){
  if(length(mutate_vars)==0||is.na(mutate_vars)){
   tbl
  }else if(mutate_vars=="linkagetype"){
       tbl  %>% # match
      mutate(same_matID = case_when(matID_k1 == matID_k2 ~ 1,
                                    matID_k1 != matID_k2 ~ 0,
                                    TRUE ~ NA_integer_),
             same_patID = case_when(patID_k1 == patID_k2 ~ 1,
                                    patID_k1 != patID_k2 ~ 0,
                                    TRUE ~ NA_integer_)) %>% 
      select(-c(patID_k1, patID_k2,matID_k1, matID_k2)) %>%
      mutate(linkagetype = case_when(same_matID==1 & same_patID==1 ~ "1_1",
                                     same_matID==0 & same_patID==0 ~ "0_0",
                                     same_matID==1 & same_patID==0 ~ "1_0",
                                     same_matID==0 & same_patID==1 ~ "0_1",
                                     TRUE ~ NA_character_))
  } else if(mode(mutate_vars)=="character"){
    mutate_call <- paste0("tbl %>% mutate(",mutate_vars,")")
    eval(parse(text = mutate_call))
  }else{
  tbl
  }}





# creates the group bys
## I tried A TON OF THINGS, but the most predictably behaving version...
## was to create a large string via mapply
summarizerFunction = function(tbl, outcome_vars,outcome_functions){
  if(length(outcome_vars) !=length(outcome_functions)){
    stop("The vectors of function names and variables must be the same length")
  }
  
  summarize_call <- "tbl %>% summarize( n_pairs = n()/(1+doubleentered), # if double entered this value is 2, and if not double entered this value is 1)
      addRel_min = try_NA(range_min),
      addRel_max = try_NA(range_max),
      addRel_emp_min = try_NA(min(addRel,na.rm=TRUE)),
      addRel_emp_mean = try_NA(mean(addRel,na.rm=TRUE)),
      addRel_emp_median = try_NA(median(addRel,na.rm=TRUE)), 
      addRel_emp_max = try_NA(max(addRel,na.rm=TRUE)),
      mtdna = mit[j],
      cnu = cnu[k],"
  summarize_parts <- mapply(function(var,fun){
    if(fun=="polychorFunction"){
      paste0(var,"_", fun, " = list(try_NA(polychor(",var,"_k1,",var,"_k2,std.err=TRUE)) %>% 
                 {list(rho = try_NA(.$rho),
                       se = sqrt(try_NA(.$var)),
                       chisq = try_NA(.$chisq),
                       df = try_NA(.$df))})")
    }else if(fun=="ml_polychorFunction" ){
      paste0(var,"_", fun, " = try_NA(polychor(",var,"_k1,",var,"_k2,ML=TRUE))")
    }else{
      paste0(var,"_", fun, " = try_NA(", fun, "(", var, "))")
    }}, outcome_vars, outcome_functions, SIMPLIFY = FALSE)
  # if unnesting variable is needed
  if("polychorFunction" %in% outcome_functions){
    # get vars to unlist
    var_polychor_unnest <- outcome_vars[outcome_functions=="polychorFunction"]
    unnest_call <- " %>% "
    unnest_parts <- mapply(function(var){
     # paste0("unnest_wider(",var,"_polychorFunction)")
      paste0("unnest_wider(",var,"_polychorFunction, names_sep = '_')")
      }, var_polychor_unnest, SIMPLIFY = FALSE)
    unnest_call <- paste0(unnest_call,paste(unnest_parts,collapse ="% "))
  }else{
    unnest_call <- unnest_parts <-""
    }
  
  # combine all the parts into a single call string
  
  summarize_call <- paste0(summarize_call,paste(summarize_parts,collapse =", "),")",unnest_call)
 # print(summarize_call)
  
  # evaluate the contucted function call and return result
  eval(parse(text = summarize_call))
}


meanFunction <- function(x){
  mean(x, na.rm=TRUE)
}
# here's the mega function
correlateOutcomesByGroup <- function(df_foldername = "longevity_skinny_matpat",
                                   binwidth_num=c(.1,.05),
                                   binwidth_cha=c("10","05"),
                                   kin_degree_max=12,
                                   kin_degree_min=0,
                                   max_kin_per_bin = 8.6*10^8, # 10^8 is 10 million
                                   cnu = c(1,0),
                                   mit  = c(1,0),
                                   doubleentered= TRUE,
                                   slice_1000=TRUE,
                                   drop_variables = c("mitRel","USA_quantile_k1","USA_quantile_k2",
                                                       "SWE_quantile_k1","SWE_quantile_k2"),
                                  # descriptive_vars=c("male","age"),
                                 #  outcome_vars=c("USA_flag_10",
                                 #                "USA_flag_15"),
                                   # alternative is var name and function to call
                                   # collumn of functions to call 
                                 outcome_vars =c("male","age",
                                                 "USA_flag_10",
                                                 "USA_flag_15",
                                                 "USA_flag_10",
                                                 "USA_flag_10",
                                                 "USA_flag_15",
                                                 "USA_flag_15"),
                                 outcome_functions = c("meanFunction",
                                                       "meanFunction",
                                                       "meanFunction",
                                                       "meanFunction",
                                                       "polychorFunction",
                                                       "ml_polychorFunction",
                                                       "polychorFunction",
                                                       "ml_polychorFunction"
                                                       ),
                                   grouping_vars=NA,
                                   grouping_filename=NULL,
                                   verbose=TRUE,
                                 mutate_vars=NULL
){
  
  # potential options 
  # expand.grid on unique values and filter via a loop
  ## make sure to use verbose to give folks a sense of what they;re asking for
  ## include a check to estimate time?
  # groupby
  options(scipen=10, digits=11)
  if(verbose){print("starting checks")}
  # Checks
  ## Is the bin length the same?
  if(length(binwidth_num) != length(binwidth_cha)){
    # return error
    stop(paste("The length of binwidth_num and binwidth_cha don't match. 
         binwidth_num has",length(binwidth_num),"but binwidth_cha has", length(binwidth_cha)))
  }
  ## Is range of degrees viable?
  if(!(mode(kin_degree_max) %in% c("numeric","integer"))){
    stop("kin_degree_max isn't a number")
  }
  if(!(mode(kin_degree_min) %in% c("numeric","integer"))){
    stop("kin_degree_min isn't a number")
  }
  if(kin_degree_max<1|kin_degree_max<kin_degree_min|kin_degree_max<0){
    stop("kin_degree_min or max isn't workable value. Either the value is too small or min is larger than max")
  }
  if(verbose){print("ending checks")} 
  # loop by bin width
  if(verbose){print("bin width")} 
  for(q in 1:length(binwidth_num)){
    
    # select the bin for the loop
    bin_width_num_q <- binwidth_num[q] 
    bin_width_cha_q <- binwidth_cha[q] 
    
    if(verbose){print(paste0("bin width ", bin_width_num_q))} 
    # create relatedness center values
    ## these don't diff by bin, but it made more sense to keep them nearby
    addRel_center <- 2^(0:(-kin_degree_max)) # bin center
    
    addRel_maxs_temp <- addRel_center*(1+bin_width_num_q)
    #inclusive
    addRel_mins_temp <- addRel_center*(1-bin_width_num_q) #min_bin
    
    # this is supposed to have one of each
    addRel_real_maxs <-  addRel_mins_temp[-length(addRel_mins_temp)]
    addRel_real_mins <-  addRel_maxs_temp[-1]
    
    addRel_maxs <- c(1.5, sort(c(addRel_real_maxs,addRel_maxs_temp),
                               decreasing =TRUE),
                     addRel_mins_temp[length(addRel_mins_temp)])
    addRel_mins <- c(addRel_maxs_temp[1],
                     sort(c(addRel_real_mins,addRel_mins_temp),
                          decreasing =TRUE),0)
    
    kin_degree <- c(0,0:(kin_degree_max+1))
    
    # Make csv name 
    ## is there a grouping variable
    if(is.null(grouping_filename)||length(grouping_filename)==0||is.na(grouping_filename)){
      file_path_txt <- paste0("Z:/mtdna/aim1_cor_",df_foldername,"_",binwidth_cha[q],".csv")
      
    }else{
      file_path_txt <- paste0("Z:/mtdna/aim1_cor_",grouping_filename,"_",df_foldername,"_",binwidth_cha[q],".csv")
      
    }
    
    if(verbose){print(file_path_txt)} 
    
    if(verbose){print("starting genetic loop")} 
  # loop by genetic relatedness
    for (i in 1:length(addRel_maxs)){
      range_max <- addRel_maxs[i]
      range_min <- addRel_mins[i]
      if(verbose){print(range_min)} 
  # loop by mit
      if(verbose){print("starting mit loop")} 
      for (j in 1:length(mit)){
        # craft the file name
        input_file <- paste0("data/",df_foldername,"_",binwidth_cha[q],"/df_mt",mit[j],"_r",range_min,"-r",range_max,".csv")
        if(verbose){print(input_file)} 
        
        # check if file exists
        ## if not exist, skip
        if(!file.exists(input_file)){
         # print("Your dumb file doesn't exist human")
          print(paste("Missing input file:",input_file))
          next
        }else{
          dataRelatedPair_merge  <- fread(input_file,
                                          header = TRUE,
                                          #  drop vars to slim
                                          drop = drop_variables) %>% mutate(addRel = round(addRel, digits =5)) %>% suppressWarnings()
          gc()
          if(verbose){print(paste0(input_file, "had ",nrow(dataRelatedPair_merge)," rows"))} 
        }

        
       if(nrow(dataRelatedPair_merge) > max_kin_per_bin){
        # this loop skips the file if it is too big, otherwise the loop fails 
        # and gives unhappy warning and fails without cleaning up
        print(paste(i,addRel_mins[i],
                    "was skipped because it was",
                    nrow(dataRelatedPair_merge),
                    "which is bigger than",max_kin_per_bin))
        remove(dataRelatedPair_merge)
        next
      }else{
        if(doubleentered){
          # double entered 
          if(verbose){print("Double entering the data")} 
          
          dxlist <- c("ID1","ID2", #intentional ordering
                      "addRel",#"mitRel", 
                      "cnuRel",
                      names(dataRelatedPair_merge)[endsWith(names(dataRelatedPair_merge),"_k2")],                                           
                      names(dataRelatedPair_merge)[endsWith(names(dataRelatedPair_merge),"_k1")])
          
          dataRelatedPair_merge <- rbindlist(list(dataRelatedPair_merge,
                                                  dataRelatedPair_merge[, ..dxlist]),
                                             use.names=FALSE)
          gc()
        }
      }
      # loop by common environment 
        if(verbose){print("loop by common environment")}
          for (k in 1:length(cnu)){
            if(nrow(dataRelatedPair_merge %>% dplyr::filter(cnuRel == cnu[k]))==0){
              # skip if no cnu
              next
            }else{
              
              if(verbose){
           #     print(head(dataRelatedPair_merge))
              }
              
              temp <- try_NA(dataRelatedPair_merge %>% dplyr::filter(cnuRel == cnu[k]) %>%
                               sliceFuction(slice_1000=slice_1000)%>%
                               mutateFunction(mutate_vars=mutate_vars)%>%
                               group_byFunction(grouping_vars) %>%
                               summarizerFunction(outcome_vars,outcome_functions)
                               ) %>% 
                suppressWarnings()
              if(verbose){
              #  print(head(temp))
              }
            }

            # skip row writing if NA
            if(length(temp)==1&&is.na(temp)){
              if(verbose){
                print("Temp was NA")
              } 
              
            }else{
            fwrite(temp, file=file_path_txt, sep=',',
                   append=TRUE, row.names=FALSE, col.names=FALSE)
            
            # temp get names
            file_names <- names(temp)  
          }
  # optional loop by grouping variable?
          } # end cnu
  }  #end mit
      if(verbose){
      print(paste(i,addRel_mins[i]))
      }
      gc()
      }#end add
    
    aim1_cors <- read.csv(file_path_txt, header=FALSE)
    
    
    names(aim1_cors) <- file_names
    fwrite(aim1_cors,
           file= file_path_txt, sep=',',
           append=FALSE, row.names=FALSE, col.names=TRUE)  
    } # end bin
  
  #clean up after
  remove(dataRelatedPair_merge)
  remove(temp)
  remove(aim1_cors)
  
  gc()
}
# note: these kin are double entered



