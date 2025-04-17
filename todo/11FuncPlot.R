#------------------------------------------------------------------------------
# Author: S. Mason Garrison
# Date: 2022-12-16
# Filename: 05FuncPlot.R
# Purpose: Write some helper functions for plotting
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Libraries

library(tidyverse)
library(readr)
library(scales)
library(ggsci)
library(ggthemes)
library(ICCbin)
library(RColorBrewer)


#------------------------------------------------------------------------------

cbbPalette_7 <- c("#000000", "#E69F00", "#56B4E9", 
                  "#009E73", #"#F0E442", 
                  "#0072B2", "#D55E00", "#CC79A7")

cbbPalette_5 <- c("#E69F00", "#56B4E9", 
                  "#009E73", #"#F0E442", 
                  "#0072B2","#000000")


#------------------------------------------------------------------------------
### Relatedness Correlations over 10 generations

#### 90% MtDNA

gens  <- 1:10
gens_subset=2
gens_offset=0
weight_a=.1 #reweights phenotypic influence to 10% autosomal
weight_m=1-weight_a  #reweights remaining phenotypic influence to mt
relatednames=c("Sibling","1st Cousin", "2nd Cousin", "3rd Cousin", "4th Cousin", "5th Cousin", "6th Cousin", "7th Cousin", "8th Cousin", "9th Cousin")

# Common Lables
lab_x = "Degree of Cousin"
lab_y = "Relatedness Coefficient"
lab_color = "Maternal Cousins\n"
lab_title= paste0(lab_y," using ")
lab_subtitle_full=paste0(":\nGenerations 1-",max(gens))
lab_subtitle_subset=paste0(":\nGenerations ",gens_subset+1,"-",max(gens))



#### Base Pairs
total_a=2875001522 #sum(df.wiki.auto$bp_total)
total_m=16569 #df.wiki.mt$bp_total
metric="bp"


mtdna_data <- function(total_a = 2875001522,
                    total_m = 16569,
                    metric = "bp",
                    weight_m,
                    weight_a){
  df=data.frame(
    related=c(related_coef(gens,
                           empirical=TRUE,
                           total_a=total_a,
                           total_m=total_m,
                           weight_a=weight_a,weight_m=weight_m[1]),
              related_coef(gens,maternal=TRUE,empirical=TRUE,
                           total_a=total_a,
                           total_m=total_m,weight_a=weight_a,
                           weight_m=weight_m[1])),
    generation=c(gens,gens-gens_offset),
    maternal=c(rep(FALSE,times=length(gens)),rep(TRUE,times=length(gens))),
    relatednames=rep(relatednames,2),
    weight_m=c(rep(0,times=length(gens)),rep(weight_m[1],times=length(gens)))
  )
  if(length(weight_m)>1){
    for(i in 2:length(weight_m)){
      df2=data.frame(
        related=c(related_coef(gens,empirical=TRUE,total_a=total_a,total_m=total_m,weight_a=weight_a,weight_m=weight_m[i]),
                  related_coef(gens,maternal=TRUE,empirical=TRUE,total_a=total_a,total_m=total_m,weight_a=weight_a,weight_m=weight_m[i])),
        generation=c(gens,gens-gens_offset),
        maternal=c(rep(FALSE,times=length(gens)),rep(TRUE,times=length(gens))),
        relatednames=rep(relatednames,2),
        weight_m=c(rep(0,times=length(gens)),rep(weight_m[i],times=length(gens)))
      )
      df= rbind(df,df2[(length(gens)+1):nrow(df2),])
    }
  }
  df$mtdna_prop= df$weight_m*total_m/(df$weight_m*total_m+total_a)
  return(df)
}


mtdnaplot <- function(df.plot,
                   lab_x,
                   lab_y = "Relatedness Coefficient",
                   lab_color = "mtDNA Proportion\n",
                   gens=1:10,
                   gens_subset=2,
                   gens_offset=0,
                   metric,
                   subset=FALSE,
                   title_g=FALSE,
                   ...
){
  df.plot$mtdna_prop=as.factor(df.plot$mtdna_prop)
  
  lab_title= paste0(lab_y," using ")
  if(subset){
    lab_subtitle=paste0(":\nGenerations ",gens_subset+1,"-",max(gens))
  }else{
    lab_subtitle=paste0(":\nGenerations 1-",max(gens))
  }
  titlef=NULL
  if(title_g){
    titlef= paste0(lab_title,metric,lab_subtitle)
  }
  
  ggplot(data=df.plot,
         aes(x=generation, 
             y=related, 
             group=mtdna_prop,
             color=mtdna_prop,
             shape = mtdna_prop,
             linetype=mtdna_prop)) +
    geom_line()+
    geom_point()+theme_bw()+
    scale_x_continuous(limits=c(min(df.plot$generation),
                                max(df.plot$generation)),
                       breaks=seq(min(df.plot$generation),
                                  max(df.plot$generation),by=1),
                       labels=unique(df.plot$relatednames))+
    theme(axis.text.x = element_text(size = 12, angle = -65, 
                                     hjust = 0),
          legend.position = "top")+
    labs(title = titlef, 
         x = lab_x, 
         y = lab_y, 
         color = lab_color,
         shape=lab_color,
         fill=lab_color,
         linetype=lab_color)
}





mtdnapw=function(
    mtdnaprop=.01,
    total_m=4000,
    total_a=1380155
){
  #  df_mult$mtdnaprop = df_mult$weight_m*total_m/(df_mult$weight_m*total_m+total_a)
  
  weight_m=(total_a*mtdnaprop/total_m)*1/(1-mtdnaprop)
  
  return(weight_m)
}


# Libraries
library(WebPower)
library(tidyverse)

fig2plot=function(related=c(1,.5),
                  h2=1){
  
  df=data.frame(
    r=related,
    h2=h2[1],
    kcor=related*h2[1])
  # if more than one heritability level
  if(length(h2)>1){
    for(i in 2:length(h2)){
      df1=data.frame(
        r=related,
        h2=h2[i],
        kcor=related*h2[i])
      
      df= rbind(df,df1)
    }}
  
  return(df)
  
}


#------------------------------------------------------------------------------
# End