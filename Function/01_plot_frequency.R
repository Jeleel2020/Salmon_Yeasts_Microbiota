# load libararies
for (lib in c("ggplot2","tidyverse", "rlang", "RColorBrewer", "ggstatsplot", "cowplot")) {
  suppressPackageStartupMessages(require(lib, character.only = TRUE))
}

# define the function
plot_frequency <- function(data,
                           x, 
                           y,
                           facet_wrap,
                           facet_ncol = 2,
                           type = "parametric", 
                           conf_level = 0.95, 
                           xlab = NULL, 
                           ylab = NULL, 
                           title = NULL,
                           point_color = "grey50") {
  
  #------------------ variable names ---------------------------------------------
  # ensure the arguments work quoted or unquoted
  x <- ensym(x)
  y <- ensym(y)
  facet_wrap <- ensym(facet_wrap)
  point_color <- ensym(point_color)
  
  # if `xlab` and `ylab` is not provided, use the variable `x` and `y` name
  if(is.null(xlab)){xlab <- as_name(x)}
  if(is.null(ylab)){ylab <- as_name(y)}
  
  #------------------ correlation with all samples -------------------------------
  if(missing(facet_wrap)){
    # turn off stats if the number of observation is less than 6
    if(sum(!is.na(data[[y]])) < 6){ 
      p <- ggscatterstats(data = data,
                          x = {{x}}, 
                          y = {{y}},
                          type = type, # type of test that needs to be run
                          conf.level = conf_level, # confidence level
                          xlab = xlab, # label for x axis
                          ylab = ylab, # label for y axis
                          title = title, # plot title
                          results.subtitle = FALSE, # turn off stats
                          point.args = list(color = "white"), # make it easy for coloring points by geom_point()
                          k = 3, # no. of decimal places in the results
                          marginal = FALSE, # whether show ggExtra::ggMarginal() plots or not
                          messages = FALSE) # turn off messages and notes
    } else {
      # turn on stats if the number of observation is no less than 6
      p <- ggscatterstats(data = data,
                          x = {{x}}, 
                          y = {{y}},
                          type = type, 
                          conf.level = conf_level, 
                          xlab = xlab, 
                          ylab = ylab, 
                          title = title, 
                          results.subtitle = TRUE, # turn on stats
                          point.args = list(color = "white"), 
                          k = 3, 
                          marginal = FALSE, 
                          messages = FALSE)
    }
    
    if(as_name(point_color) %in% colnames(data) == TRUE){
      p <- p + geom_point(aes(color = {{point_color}})) 
      if(is.numeric(data[[point_color]]) == TRUE){
        p <- p + scale_color_gradient2(low = "blue", mid = "white", high = "red",  
                                       midpoint = mean(data[[point_color]], na.rm = TRUE)) 
      } else {
        if(n_distinct(data[[point_color]]) <= 9){
          p <- p + scale_color_brewer(palette = "Set1") +
            guides(color = guide_legend(nrow = 1)) +
            theme(legend.position = "bottom")
        } else {
          getPalette <- colorRampPalette(brewer.pal(9, "Set1"))
          colors <- getPalette(n_distinct(data[[point_color]]))
          p <- p + scale_color_manual(values = colors) +
            guides(color = guide_legend(nrow = 1)) +
            theme(legend.position = "bottom")
        }
      }
    } else {
      p <- p + geom_point(color = as_name(point_color)) +
        guides(color = guide_legend(nrow = 1)) +
        theme(legend.position = "bottom")
    }
  }  
  
  #---------- correlation within each level of the faceting variable -------------
  if(!missing(facet_wrap)){
    if(!as_name(facet_wrap) %in% colnames(data) == TRUE){
      stop(paste("The faceting variable", facet_wrap, "not found."))
    } else {
      plist <- group_split(data, {{facet_wrap}}, keep = TRUE) %>% 
        map(~if(sum(!is.na(.x[[y]])) < 6){ 
          ggscatterstats(data = .x,
                         x = {{x}}, 
                         y = {{y}},
                         type = type, 
                         conf.level = conf_level, 
                         xlab = xlab, 
                         ylab = ylab, 
                         title = paste("Correlation within:", unique(.x[[facet_wrap]])), 
                         results.subtitle = FALSE, # turn off stats
                         point.args = list(color = as_name(point_color)),
                         k = 3, 
                         marginal = FALSE, 
                         messages = FALSE) 
        } else {
          ggscatterstats(data = .x,
                         x = {{x}}, 
                         y = {{y}},
                         type = type, 
                         conf.level = conf_level, 
                         xlab = xlab, 
                         ylab = ylab, 
                         title = paste("Correlation within:", unique(.x[[facet_wrap]])), 
                         results.subtitle = TRUE, # turn on stats
                         point.args = list(color = as_name(point_color)),
                         k = 3, 
                         marginal = FALSE, 
                         messages = FALSE) 
        }
        )
      
      p <- plot_grid(plotlist = plist, ncol = facet_ncol, align = "vh", axis = "tblr") 
      
      if(!is.null(title)){
        main <- ggdraw() + draw_label(title, fontface='bold')
        p <- plot_grid(main, p, ncol = 1, rel_heights = c(1, 12)) 
      }
    }
  }
  
  return(p)
}



##Acknowldements

##Modified from Li et al. (2021).

##Li, Y., Bruni, L., Jaramillo-Torres, A., Gajardo, K., Kortner, T.M., Krogdahl, Å., 2021. Differential response of digesta- and mucosa-associated intestinal microbiota to dietary insect meal during the seawater phase of Atlantic salmon. Animal Microbiome. 3, 8. https://doi.org/10.1186/s42523-020-00071-3.
