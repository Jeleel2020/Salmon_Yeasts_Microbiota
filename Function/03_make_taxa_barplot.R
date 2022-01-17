# load libararies
for (lib in c("tidyverse", "MicrobeR", "RColorBrewer")) {
  suppressPackageStartupMessages(require(lib, character.only = TRUE))
}

# define the function
make_taxa_barplot <- function(
  table, 
  metadata, 
  group_by, 
  ntaxa,
  nrow,
  plot_mean, 
  cluster_sample,
  sample_label,
  italize_taxa_name,
  colors){
  
  if(missing(ntaxa) & nrow(table)>10){
    ntaxa = 10} else if (missing(ntaxa)) {
      ntaxa = nrow(table)
    }
  
  if(missing(plot_mean)){plot_mean = F}
  
  if(missing(group_by) & plot_mean == T){stop('The argument "group_by" must be specified if plot_mean = TRUE')}
  
  table <- Make.Percent(table)
  table <- table[order(rowMeans(table), decreasing = T), ]
  if(ntaxa < nrow(table)){ 
    Others <- colSums(table[(ntaxa + 1):nrow(table), ])
    table <- rbind(table[1:ntaxa, ], Others)
  }
  
  # Get colors from row names (requires named colors)
  names <- row.names(table)
  names <- append(names, "Others")
  colors <- colors[names]
  
  forplot <- TidyConvert.ToTibble(table, "Taxa") %>% gather(-Taxa, key = "SampleID", value = "Abundance") 
  forplot$Taxa <- factor(forplot$Taxa,levels = rev(unique(forplot$Taxa)))
  
  if(!missing(metadata) & !missing(group_by)){
    if(TidyConvert.WhatAmI(metadata) == "data.frame" | TidyConvert.WhatAmI(metadata) == "matrix") {metadata <- TidyConvert.ToTibble(metadata, "SampleID")}
    forplot <- inner_join(forplot, metadata, by = "SampleID")
  }
  
  group_by <- enquo(group_by)
  
  # hierarchical clustering of samples
  if(missing(cluster_sample)){cluster_sample = F}
  
  if(cluster_sample == T & plot_mean == F){
    if(missing(group_by)){
      order <- select(forplot, Taxa, SampleID, Abundance) %>%
        spread(key = SampleID, value = Abundance) %>%
        column_to_rownames("Taxa") %>%
        t() %>%
        as.matrix() %>%
        dist() %>%
        hclust() %>%
        as.dendrogram() %>%
        labels()
      
    } else {
      hclust <- select(forplot, Taxa, SampleID, Abundance, !!group_by) %>%
        group_nest(!!group_by) %>%
        mutate(hclust = map(data, ~{
          spread(.x, key = SampleID, value = Abundance) %>%
            column_to_rownames("Taxa") %>%
            t() %>%
            as.matrix() %>%
            dist() %>%
            hclust() %>%
            as.dendrogram() %>%
            labels()
        }))
      
      order <- unlist(hclust$hclust)
      
      forplot <- arrange(forplot, match(SampleID, order)) %>%
        mutate(SampleID = factor(SampleID, levels = unique(SampleID)))
    }
  }
  
  # make an initial plot
  plot <- ggplot(forplot, aes(x = SampleID, y = Abundance, fill = Taxa)) +
    geom_bar(stat = "identity") +
    labs(x = "SampleID", y = "Relative abundance (%)") +
    scale_y_continuous(breaks = 0:10*10, expand = expansion(mult = c(0, 0.02))) + 
    theme_cowplot() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
          legend.justification = "top",
          legend.text.align = 0)
  
  # use group means for plotting if plot_mean = T
  if(!missing(group_by) & plot_mean == T){
    plot <- group_by(forplot, !!group_by, Taxa) %>% 
      summarise(Abundance_mean = mean(Abundance)) %>%
      ggplot(aes(x = !!group_by, y = Abundance_mean, fill = Taxa)) +
      geom_bar(stat = "identity") +
      labs(x = group_by, y = "Relative abundance (%)") +
      scale_y_continuous(breaks = 0:10*10, expand = expansion(mult = c(0, 0.02))) + 
      theme_cowplot() +
      theme(legend.text = element_text(size = 10), 
            #legend.justification = "top",
            legend.text.align = 0) 
  } 
  
  # add facets to the plot if group_by = T
  if(!missing(group_by) & plot_mean == F){
    if(missing(nrow)){nrow = 1}
    plot <- plot + 
      facet_wrap(vars(!!group_by), nrow = nrow, scales = "free_x")
  }
  
  # # fill color manually
  # if(ntaxa <= 11){
  #   plot <- plot + 
  #     scale_fill_manual(values = brewer.pal(n = 12, name = "Set3")) 
  # } else {
  #   getPalette <- colorRampPalette(brewer.pal(12, "Set3"))
  #   colors <- getPalette(ntaxa + 1)
  #   plot <- plot + scale_fill_manual(values = colors)
  # }
  plot <- plot + scale_fill_manual(values = colors)
  
  if(missing(italize_taxa_name)){italize_taxa_name = F}
  
  # make R regular expressions for costomizing legend text
  if(italize_taxa_name == T){
    labs <- forplot %>%
      mutate(Taxa = ifelse(Taxa == "Others", # italize all taxonomic ranks
                           paste0("plain(", Taxa, ")"), 
                           paste0("italic(", Taxa, ")")), 
             #Taxa = ifelse(grepl("__|Others", Taxa), # italize genus/species names only
             #paste0("plain(", Taxa, ")"), 
             #paste0("italic(", Taxa, ")")),
             # tilde (~) is recognized as a "space" in R expressions
             Taxa = gsub("\\s+", "~", Taxa))
  }
  
  # # define color scheme; use italic font for legend text if italize_taxa_name = T 
  # if(ntaxa <= 11){
  #   if(italize_taxa_name == T){
  #     plot <- plot + scale_fill_manual(values = brewer.pal(n = 12, name = "Set3"),
  #                                      labels = parse(text = rev(unique(labs$Taxa))))
  #   } else {
  #     plot <- plot + scale_fill_manual(values = brewer.pal(n = 12, name = "Set3"))
  #   }
  #   
  # } else {
  #   getPalette <- colorRampPalette(brewer.pal(12, "Set3"))
  #   colors <- getPalette(ntaxa + 1)
  #   if(italize_taxa_name == T){
  #     plot <- plot + scale_fill_manual(values = colors, labels = parse(text = rev(unique(labs$Taxa))))
  #   } else {
  #     plot <- plot + scale_fill_manual(values = colors)
  #   }
  #   
  # }
  if(italize_taxa_name == T){
    plot <- plot + scale_fill_manual(values = colors, labels = parse(text = unique(labs$Taxa)))
  } else {
    plot <- plot + scale_fill_manual(values = colors)
  }
  
  # customize the x-axis label and x-axis tick labels
  if(!missing(sample_label) & plot_mean == F){
    sample_label <- enquo(sample_label)
    xlab <- as.data.frame(forplot) %>%
      distinct(SampleID, !!sample_label) %>%
      mutate(sample_label = as.character(!!sample_label))
    
    plot <- plot + 
      scale_x_discrete(breaks = xlab$SampleID, labels = xlab$sample_label) +
      labs(x = sample_label)
  }
  
  # Reverse legend order to match order of colors in bar
  plot <- plot + guides(fill = guide_legend(reverse = TRUE))
  
  return(plot)
}

# Acknowldements

# Modified from Li et al. (2021). 
# Li, Y., Bruni, L., Jaramillo-Torres, A., Gajardo, K., Kortner, T.M., Krogdahl, Å., 2021. Differential response of digesta- and mucosa-associated intestinal microbiota to dietary insect meal during the seawater phase of Atlantic salmon. Animal Microbiome. 3, 8. https://doi.org/10.1186/s42523-020-00071-3.

