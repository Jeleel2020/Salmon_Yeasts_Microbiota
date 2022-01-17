# Salmon_Yeasts_Microbiota
This repository contains the codes used to generate the figures in the manuscript 
# Effect of yeasts and processing on intestinal microbiota of Atlantic salmon (Salmo salar) fed soybean meal-based diets in seawater 

# Abstract
**Background:** Yeasts are gaining attention as alternative ingredients in aquafeeds. However, the impact of yeast inclusion on modulation of intestinal microbiota of fish fed plant-based ingredients is limited. Thus, the present study investigates the effects of yeast and processing on composition, diversity and predicted metabolic capacity of gut microbiota of Atlantic salmon smolt fed soybean meal (SBM)-based diet. Two yeasts, Cyberlindnera jadinii (CJ) and Wickerhamomyces anomalus (WA) yeasts were produced in-house and processed by direct heat-inactivation with spray-drying (ICJ and IWA) or autolyzed at 50 ºC for 16 h (ACJ and AWA), followed by spray-drying. In a 45-day feeding experiment, fish were fed one of six diets: a fishmeal (FM)-based diet, a challenging diet with 30% soybean meal (SBM) and four other diets containing 30% SBM and 10% of each of the four yeast fractions (i.e., ICJ, ACJ, IWA and AWA). Microbial profiling of digesta samples was conducted using 16s rRNA gene sequencing, and the predicted metabolic capacities of gut microbiota were determined using genome-scale metabolic models.      
**Results:** The microbial composition and predicted metabolic capacity of gut microbiota was different between fish fed FM diet compared with those fed SBM diet. The digesta of fish fed SBM diet was dominated by members of lactic acid bacteria, which was similar to microbial composition in the digesta of fish fed the inactivated yeasts (ICJ and IWA diets). Inclusion of autolyzed yeasts (ACJ and AWA diets) lowered the richness and diversity of gut microbiota in fish. The gut microbiota of fish fed ACJ diet was dominated by the genus Pediococcus and showed a predicted increase in mucin O-glycan degradation compared with the other diets. The gut microbiota of fish fed AWA diet was highly dominated by the family Bacillaceae.    
**Conclusions:** The present study showed that dietary inclusion of FM and SBM differentially modulate the composition and predicted metabolic capacity of gut microbiota of fish. Inclusion of inactivated yeasts did not modulate the intestinal microbiota of fish fed SBM-based diet. Fish fed ACJ diet increased relative abundance of Pediococcus, and mucin O-glycan degradation pathway compared with the other diets. 

Content of files in this resposiotry

Code -- all the scripts used for the analysis

functions -- functions for automating tasks

01_plot_frequency.R -- function to be used in the code '02_Pre-processing.Rmd'
02_plot_prevalance.R -- function to be used in the code '02_Pre-processing.Rmd'
03_make_taxa_barplot.R -- function to be used in the code '03_Taxonomic_analysis.Rmd'


01_Sequence_denoising_dada2.Rmd -- processing of raw data using DADA2 to generate ASV table
02_Pre_processing.Rmd -- creating phyloseq object and pre-processing to remove features
03_Taxonomic_analysis.Rmd -- analysis and visualization of taxonomic composition, core ASVs and microbial overlap
04_Alpha_diversity.Rmd -- visualization and statistical analysis of alpha-diversity
05_Beta_diversity.Rmd -- visualization and statistical analysis of beta-diversity
06_Metabolic_reaction_analysis.ipynb -- analysis of predictive metabolic reactions


Data -- all the data, including raw, reference and intermediate data

Data_Metabolic_reaction_analysis -- all the data used in metabolic reaction analysis
Figures -- for identification of contaminants

01_prevalance_contam.pdf
02_DNA_concentration.pdf
03_frequency_contam.pdf
04_prevalence_contam_mock.pdf


00_Metadata.csv -- sample metadata
01_PaboSeqtab.nochim.rds -- ASV table after removal of chimeras
02_LL.taxa.rds -- taxonomy table
03_sample_contaminants.xlsx -- removed contaminants
04_ps_noncontam.rds -- phyloseq object after removal of contaminants
05_ps_nocontam_mock.rds -- phyloseq object for positive control
06_contam_neg.rds -- phyloseq object for negative control
07_mock_merged_percent.xlsx -- taxa abundances in positive control samples
08_neg_merged_percent.xlsx -- taxa abundances in negative control samples
09_phylum_digesta_name.xlsx -- phylum abundances in digesta samples
10_phylum_feed_name.xlsx -- phylum abundances in feed samples
11_phylum_water_name.xlsx -- phylum abundances in water samples
12_genus_digesta_name.xlsx -- genus/lower taxonony abundances in digesta samples
13_genus_feed_name.xlsx -- genus/lower taxonony abundances in feed samples
14_genus_water_name.xlsx -- genus/lower taxonony abundances in water samples


LICENSE.md
README.md
