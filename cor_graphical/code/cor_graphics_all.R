#-----------------------------------------------
# obligatory to append to the top of each script
renv::activate(project = here::here(".."))
library(GGally)
library(stringr)
require(devtools)
#install_version("dummies", version = "1.5.6", repos = "http://cran.us.r-project.org")
library(cowplot) # for function plot_grid
library(grid)
library(gridExtra)
install.packages("wCorr", repos = "http://cran.us.r-project.org") # weighted correlation
library(wCorr)
library(ggnewscale) # for new_scale_color()
install.packages("weights", repos = "http://cran.us.r-project.org")
library(weights) # for wtd.cor()

# There is a bug on Windows that prevents renv from working properly. The following code provides a workaround:
#if (.Platform$OS.type == "windows") .libPaths(c(paste0(Sys.getenv ("R_HOME"), "/library"), .libPaths()))

source(here::here("code", "cor_graphics_functions.R"))
source(here::here("..", "_common.R"))
#colnames(assay_metadata) = gsub("X[.]+","", colnames(assay_metadata))
# add panel for bindN in assay_metadata
assay_metadata[which(assay_metadata$assay=="bindN"), "panel"] = "bindN"


# for the order of figure panels
assay_order = assay_metadata %>% dplyr::arrange(panel, order_in_panel) %>% select(assay_label_short) %>% pull()
assay_metadata = assay_metadata %>%
    mutate(assay_label_short = factor(assay_label_short,
                                      levels = assay_order
))

dat.longer.cor.subset.plot1 <- readRDS(here::here("data_clean", "longer_cor_data_plot1.rds"))
dat.longer.cor.subset.plot1.2 <- readRDS(here::here("data_clean", "longer_cor_data_plot1.2.rds"))
dat.longer.cor.subset.plot1.3 <- readRDS(here::here("data_clean", "longer_cor_data_plot1.3.rds"))
dat.longer.cor.subset.plot1.4 <- readRDS(here::here("data_clean", "longer_cor_data_plot1.4.rds"))
dat.longer.cor.subset.plot1.5 <- readRDS(here::here("data_clean", "longer_cor_data_plot1.5.rds"))
dat.cor.subset.plot3 <- readRDS(here::here("data_clean", "cor_data_plot3.rds")); dat.cor.subset.plot3$all_one <- 1 # as a placeholder for strata values
dat.long.cor.subset.plot5 <- readRDS(here::here("data_clean", "scatter_rug_data_plot5.rds"))

# path for figures and tables etc
save.results.to = here::here("output")
if (!dir.exists(save.results.to))  dir.create(save.results.to)
save.results.to = paste0(here::here("output"), "/", attr(config,"config"),"/");
if (!dir.exists(save.results.to))  dir.create(save.results.to)
#save.results.to = paste0(save.results.to, "/", COR,"/");
#if (!dir.exists(save.results.to))  dir.create(save.results.to)
print(paste0("save.results.to equals ", save.results.to))

###### Set 1 plots: BD1 and BD29 Ab distributions by case/non-case
set1_times <- c("BD1","BD29","DeltaBD29overBD1")
# ID50 614G and BA.1, at BD1, BD29, BD29-BD1
# bindSpike 614G and BA.1, at BD1, BD29, BD29-BD1
for (panel in c("pseudoneutid50", "bindSpike")){
    # by naive/non-naive, vaccine/placebo
    f_1 <- f_case_non_case_by_time_assay(
        dat = dat.longer.cor.subset.plot1,
        assays = paste0(panel,c("","_BA.1")),
        times = set1_times,
        axis.x.text.size = 28,
        strip.x.text.size = 25,
        panel.text.size = 8,
        facet.y.var = vars(Trt_nnaive), 
        facet.x.var = vars(assay_label_short),
        pointby = "cohort_col",
        lgdbreaks = c("Omicron Cases", "Non-Cases", "Non-Responders"),
        chtcols = setNames(c("#FF6F1B", "#0AB7C9", "#8F8F8F"), c("Omicron Cases", "Non-Cases", "Non-Responders")),
        chtpchs = setNames(c(19, 19, 2), c("Omicron Cases", "Non-Cases", "Non-Responders")))
    
    for (i in 1:length(set1_times)){
        
        file_name <- paste0(panel, "_2_strain_by_case_non_case_at_", set1_times[i], ".pdf")
        ggsave(plot = f_1[[i]], filename = paste0(save.results.to, file_name), width = 16, height = 16)
    }
    # pooling naive/non-naive, vaccine/placebo
    f_1.2 <- f_case_non_case_by_time_assay(
        dat = dat.longer.cor.subset.plot1.2,
        assays = paste0(panel,c("","_BA.1")),
        times = set1_times,
        axis.x.text.size = 28,
        strip.x.text.size = 25,
        panel.text.size = 8,
        facet.y.var = NULL, 
        facet.x.var = vars(assay_label_short),
        pointby = "cohort_col",
        lgdbreaks = c("Omicron Cases", "Non-Cases", "Non-Responders"),
        chtcols = setNames(c("#FF6F1B", "#0AB7C9", "#8F8F8F"), c("Omicron Cases", "Non-Cases", "Non-Responders")),
        chtpchs = setNames(c(19, 19, 2), c("Omicron Cases", "Non-Cases", "Non-Responders")))
    
    for (i in 1:length(set1_times)){
        
        file_name <- paste0(panel, "_2_strain_by_case_non_case_pooled_at_", set1_times[i], ".pdf")
        ggsave(plot = f_1.2[[i]], filename = paste0(save.results.to, file_name), width = 16, height = 16)
    }
    # by naive/non-naive, shape by vaccine/placebo
    f_1.3 <- f_case_non_case_by_time_assay(
        dat = dat.longer.cor.subset.plot1.3,
        assays = paste0(panel,c("","_BA.1")),
        times = set1_times,
        axis.x.text.size = 28,
        strip.x.text.size = 25,
        panel.text.size = 8,
        facet.y.var = vars(nnaive), 
        facet.x.var = vars(assay_label_short),
        pointby = "cohort_col2",
        lgdbreaks = c("Omicron Cases","Non-Cases", "Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo"),
        chtcols = setNames(c("#FF6F1B", "#0AB7C9", "#FF6F1B", "#FF6F1B", "#0AB7C9", "#0AB7C9"), c("Omicron Cases","Non-Cases", "Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo")),
        chtpchs = setNames(c(8, 8, 17, 1, 17, 1), c("Omicron Cases","Non-Cases", "Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo")))
    
    for (i in 1:length(set1_times)){
        
        file_name <- paste0(panel, "_2_strain_by_case_non_case_pooled_v2_at_", set1_times[i], ".pdf")
        ggsave(plot = f_1.3[[i]], filename = paste0(save.results.to, file_name), width = 16, height = 16)
    }

}

# bindSpike D614, Gamma, Alpha, Beta, Delta, BA.1, at BD1, BD29, BD29-BD1
for (panel in c("bindSpike")){
    # by naive/non-naive, vaccine/placebo
    f_1 <- f_case_non_case_by_time_assay(
        dat = dat.longer.cor.subset.plot1,
        assays = paste0(panel,c("", "_Gamma", "_Alpha", "_Beta", "_Delta", "_BA.1")),
        times = set1_times,
        axis.x.text.size = 11,
        strip.x.text.size = 12,
        panel.text.size = 4.5,
        facet.y.var = vars(Trt_nnaive), 
        facet.x.var = vars(assay_label_short),
        pointby = "cohort_col",
        lgdbreaks = c("Omicron Cases", "Non-Cases", "Non-Responders"),
        chtcols = setNames(c("#FF6F1B", "#0AB7C9", "#8F8F8F"), c("Omicron Cases", "Non-Cases", "Non-Responders")),
        chtpchs = setNames(c(19, 19, 2), c("Omicron Cases", "Non-Cases", "Non-Responders")))
    
    for (i in 1:length(set1_times)){
        
        file_name <- paste0(panel, "_6_strain_by_case_non_case_at_", set1_times[i], ".pdf")
        ggsave(plot = f_1[[i]], filename = paste0(save.results.to, file_name), width = 16, height = 16)
    }
    # pooling naive/non-naive, vaccine/placebo
    f_1.2 <- f_case_non_case_by_time_assay(
        dat = dat.longer.cor.subset.plot1.2,
        assays = paste0(panel,c("", "_Gamma", "_Alpha", "_Beta", "_Delta", "_BA.1")),
        times = set1_times,
        axis.x.text.size = 11,
        strip.x.text.size = 12,
        panel.text.size = 4.5,
        facet.y.var = NULL, 
        facet.x.var = vars(assay_label_short),
        pointby = "cohort_col",
        lgdbreaks = c("Omicron Cases", "Non-Cases", "Non-Responders"),
        chtcols = setNames(c("#FF6F1B", "#0AB7C9", "#8F8F8F"), c("Omicron Cases", "Non-Cases", "Non-Responders")),
        chtpchs = setNames(c(19, 19, 2), c("Omicron Cases", "Non-Cases", "Non-Responders")))
    
    for (i in 1:length(set1_times)){
        
        file_name <- paste0(panel, "_6_strain_by_case_non_case_pooled_at_", set1_times[i], ".pdf")
        ggsave(plot = f_1.2[[i]], filename = paste0(save.results.to, file_name), width = 16, height = 16)
    }
    # by naive/non-naive, shape by vaccine/placebo
    f_1.3 <- f_case_non_case_by_time_assay(
        dat = dat.longer.cor.subset.plot1.3,
        assays = paste0(panel,c("", "_Gamma", "_Alpha", "_Beta", "_Delta", "_BA.1")),
        times = set1_times,
        axis.x.text.size = 11,
        strip.x.text.size = 12,
        panel.text.size = 4.5,
        facet.y.var = vars(nnaive), 
        facet.x.var = vars(assay_label_short),
        pointby = "cohort_col2",
        lgdbreaks = c("Omicron Cases","Non-Cases", "Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo"),
        chtcols = setNames(c("#FF6F1B", "#0AB7C9", "#FF6F1B", "#FF6F1B", "#0AB7C9", "#0AB7C9"), c("Omicron Cases","Non-Cases", "Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo")),
        chtpchs = setNames(c(8, 8, 17, 1, 17, 1), c("Omicron Cases","Non-Cases", "Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo")))
    
    for (i in 1:length(set1_times)){
        
        file_name <- paste0(panel, "_6_strain_by_case_non_case_pooled_v2_at_", set1_times[i], ".pdf")
        ggsave(plot = f_1.3[[i]], filename = paste0(save.results.to, file_name), width = 16, height = 16)
    }
}

###### Set 2 plots: Longitudinal plots BD1 to BD29 (and to DD1)
set2_assays = c("bindSpike","bindSpike_BA.1","pseudoneutid50","pseudoneutid50_BA.1")
# bindSpike 614G and BA.1 non-cases and cases, at BD1, BD29, DD1
# ID50 614G and BA.1 non-cases and cases, at BD1, BD29, DD1

# by naive/non-naive, vaccine/placebo
f_2 <- f_longitude_by_assay(
    dat = dat.longer.cor.subset.plot1,
    x.var = "time_cohort",
    x.lb = c("BD1 Non-Cases","BD29 Non-Cases","BD1 Omicron Cases","BD29 Omicron Cases","DD1 Omicron Cases"),
    assays = set2_assays,
    times = c("BD1","BD29","DD1"),
    panel.text.size = 6,
    facet.y.var = vars(Trt_nnaive), 
    facet.x.var = vars(assay_label_short),
    split.var = "panel",
    pointby = "cohort_col",
    lgdbreaks = c("Omicron Cases", "Non-Cases", "Non-Responders"),
    chtcols = setNames(c("#FF6F1B", "#0AB7C9", "#8F8F8F"), c("Omicron Cases", "Non-Cases", "Non-Responders")),
    chtpchs = setNames(c(19, 19, 2), c("Omicron Cases", "Non-Cases", "Non-Responders"))
)

for (i in 1:length(c("bindSpike","pseudoneutid50"))){
    
    panel = c("bindSpike","pseudoneutid50")[i]

    file_name <- paste0(panel, "_longitudinal_by_case_non_case.pdf")
    ggsave(plot = f_2[[i]], filename = paste0(save.results.to, file_name), width = 16, height = 11)
    
}
# pooling naive/non-naive, vaccine/placebo
f_2.2 <- f_longitude_by_assay(
    dat = dat.longer.cor.subset.plot1.2,
    x.var = "time_cohort",
    x.lb = c("BD1 Non-Cases","BD29 Non-Cases","BD1 Omicron Cases","BD29 Omicron Cases","DD1 Omicron Cases"),
    assays = set2_assays,
    times = c("BD1","BD29","DD1"),
    panel.text.size = 6,
    facet.y.var = NULL, 
    facet.x.var = vars(assay_label_short),
    split.var = "panel",
    pointby = "cohort_col",
    lgdbreaks = c("Omicron Cases", "Non-Cases", "Non-Responders"),
    chtcols = setNames(c("#FF6F1B", "#0AB7C9", "#8F8F8F"), c("Omicron Cases", "Non-Cases", "Non-Responders")),
    chtpchs = setNames(c(19, 19, 2), c("Omicron Cases", "Non-Cases", "Non-Responders"))
)

for (i in 1:length(c("bindSpike","pseudoneutid50"))){
    
    panel = c("bindSpike","pseudoneutid50")[i]
    
    file_name <- paste0(panel, "_longitudinal_by_case_non_case_pooled.pdf")
    ggsave(plot = f_2.2[[i]], filename = paste0(save.results.to, file_name), width = 16, height = 11)
    
}
# by naive/non-naive, shape by vaccine/placebo
f_2.3 <- f_longitude_by_assay(
    dat = dat.longer.cor.subset.plot1.3,
    x.var = "time_cohort",
    x.lb = c("BD1 Non-Cases","BD29 Non-Cases","BD1 Omicron Cases","BD29 Omicron Cases","DD1 Omicron Cases"),
    assays = set2_assays,
    times = c("BD1","BD29","DD1"),
    panel.text.size = 6,
    facet.y.var = vars(nnaive), 
    facet.x.var = vars(assay_label_short),
    split.var = "panel",
    pointby = "cohort_col2",
    lgdbreaks = c("Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo"),
    chtcols = setNames(c("#FF6F1B", "#FF6F1B", "#0AB7C9", "#0AB7C9"), c("Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo")),
    chtpchs = setNames(c(17, 1, 17, 1), c("Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo"))
)

for (i in 1:length(c("bindSpike","pseudoneutid50"))){
    
    panel = c("bindSpike","pseudoneutid50")[i]
    
    file_name <- paste0(panel, "_longitudinal_by_case_non_case_pooled_v2.pdf")
    ggsave(plot = f_2.3[[i]], filename = paste0(save.results.to, file_name), width = 16, height = 11)
    
}

# adhoc request for manuscript: cross-panel longitudinal analysis: BD1, BD29, by naive/non-naive, case/non-case, shape by vaccine/placebo
# BD1, BD29
dat.longer.cor.subset.plot1.4.sub1 = dat.longer.cor.subset.plot1.4 %>% 
    filter(time %in% c("BD1","BD29") & assay %in% c("pseudoneutid50_BA.1","bindSpike_BA.1","pseudoneutid50","bindSpike")) %>%
    mutate(assay_variant = case_when(grepl("BA.1", assay) ~ "BA.1",
                                     TRUE ~ "D614(G)")) %>%
    mutate(y.upperlim = case_when(grepl("bindSpike", assay) ~ 6,
                                  grepl("pseudoneutid50", assay) ~ 4.5,
                                  TRUE ~ NA_real_),
           y.lowerlim = case_when(grepl("bindSpike", assay) ~ 1.7,
                                  grepl("pseudoneutid50", assay) ~ 0.6,
                                  TRUE ~ NA_real_),
           rate.y.pos = case_when(assay=="bindSpike" ~ 6,
                              assay=="pseudoneutid50" ~ 4.5,
                              assay=="bindSpike_BA.1" ~ 6,
                              assay=="pseudoneutid50_BA.1" ~ 4.5,
                              TRUE ~ NA_real_)
           ) %>%
    filter((grepl("bindSpike", assay) & value <= 6 & value >= 1) | (grepl("pseudoneutid50", assay) & value <= 4.5 & value >= 0)) #%>%
    #filter(time %in% c("BD1","BD29")) %>%
    #rowwise() %>%
    #mutate(time_jitter = as.numeric(factor(time, levels=c("BD1","BD29"))) + runif(1)/4 - 0.1)

# f_2.4.1 <- f_longitude_by_assay(
#     dat = dat.longer.cor.subset.plot1.4.sub1,
#     x.var = "time",
#     x.lb = c("BD1","BD29"),
#     assays = c("pseudoneutid50_BA.1","bindSpike_BA.1","pseudoneutid50","bindSpike"),
#     times = c("BD1","BD29"),
#     panel.text.size = 6,
#     facet.y.var = vars(factor(assay_label_short, levels = c("Pseudovirus-nAb BA.1 (AU/ml)",
#                                                             "Pseudovirus-nAb D614G (AU/ml)",
#                                                             "Anti Spike IgG BA.1 (AU/ml)",
#                                                             "Anti Spike IgG D614 (AU/ml)"))), 
#     facet.x.var = vars(Trt_nnaive2),
#     split.var = "assay_variant",
#     pointby = "cohort_col2",
#     lgdbreaks = c("Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo"),
#     chtcols = setNames(c("#FF6F1B", "#FF6F1B", "#0AB7C9", "#0AB7C9"), c("Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo")),
#     chtpchs = setNames(c(17, 1, 17, 1), c("Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo")),
#     strip.text.y.size = 18,
#     axis.text.x.size = 18
# )

f_2.4.1 <- f_longitude_by_assay_adhoc(
    dat = dat.longer.cor.subset.plot1.4.sub1,
    x.var = "time",
    x.lb = c("BD1","BD29"),
    assays = c("pseudoneutid50_BA.1","bindSpike_BA.1","pseudoneutid50","bindSpike"),
    times = c("BD1","BD29"),
    panel.text.size = 6,
    facet.y.var = vars(factor(assay_label_short, levels = c("Pseudovirus-nAb BA.1 (AU/ml)",
                                                            "Pseudovirus-nAb D614G (AU/ml)",
                                                            "Anti Spike IgG BA.1 (AU/ml)",
                                                            "Anti Spike IgG D614 (AU/ml)"))), 
    facet.x.var = vars(Trt_nnaive2),
    split.var = "assay_variant",
    pointby = "cohort_col2",
    lgdbreaks = c("Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo"),
    chtcols = setNames(c("goldenrod2","#378252","goldenrod2","#378252"), c("Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo")),
    chtpchs = setNames(c(17, 1, 17, 1), c("Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo")),
    strip.text.y.size = 18,
    axis.text.x.size = 18
)

for (i in 1:length(c("BA.1","D614(G)"))){
    
    variant = c("BA.1","D614(G)")[i]
    
    file_name <- paste0(variant, "_longitudinal_by_case_non_case_BD1_BD29_pooled_v3.pdf")
    ggsave(plot = f_2.4.1[[i]], filename = paste0(save.results.to, file_name), width = 16, height = 11)
    
}

# BD1, DeltaBD29overBD1
dat.longer.cor.subset.plot1.4.sub2 = dat.longer.cor.subset.plot1.4 %>% 
    mutate(assay_variant = case_when(grepl("BA.1", assay) ~ "BA.1",
                                     TRUE ~ "D614(G)"))

f_2.4.2 <- f_longitude_by_assay(
    dat = dat.longer.cor.subset.plot1.4.sub2,
    x.var = "time",
    x.lb = c("BD1","DeltaBD29overBD1"),
    assays = c("pseudoneutid50_BA.1","bindSpike_BA.1","pseudoneutid50","bindSpike"),
    times = c("BD1","DeltaBD29overBD1"),
    panel.text.size = 6,
    facet.y.var = vars(factor(assay_label_short, levels = c("Pseudovirus-nAb BA.1 (AU/ml)",
                                                            "Pseudovirus-nAb D614G (AU/ml)",
                                                            "Anti Spike IgG BA.1 (AU/ml)",
                                                            "Anti Spike IgG D614 (AU/ml)"))),
    facet.x.var = vars(Trt_nnaive2),
    split.var = "assay_variant",
    pointby = "cohort_col2",
    lgdbreaks = c("Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo"),
    chtcols = setNames(c("#FF6F1B", "#FF6F1B", "#0AB7C9", "#0AB7C9"), c("Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo")),
    chtpchs = setNames(c(17, 1, 17, 1), c("Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo")),
    strip.text.y.size = 18,
    axis.text.x.size = 18
)

for (i in 1:length(c("BA.1","D614(G)"))){

    variant = c("BA.1","D614(G)")[i]

    file_name <- paste0(variant, "_longitudinal_by_case_non_case_BD1_DeltaBD29overBD1_pooled_v3.pdf")
    ggsave(plot = f_2.4.2[[i]], filename = paste0(save.results.to, file_name), width = 16, height = 11)

}

# requested on 6/3/2024, similar to 2.4.1 but also at gender level, by gender, only for BA.1
f_2.5 <- f_longitude_by_assay_adhoc(
    dat = dat.longer.cor.subset.plot1.5 %>%
        mutate(Sex = ifelse(Sex == 0, "Male", ifelse(Sex == 1, "Female", "")),
               rate.y.pos = case_when(assay=="bindSpike" ~ 5.5,#6,
                                      assay=="pseudoneutid50" ~ 3.5,#,4.5,
                                      assay=="bindSpike_BA.1" ~ 5.5,#6,
                                      assay=="pseudoneutid50_BA.1" ~ 3.5,#4.5,
                                      TRUE ~ NA_real_)),
    x.var = "time",
    x.lb = c("BD1","BD29"),
    assays = c("pseudoneutid50_BA.1","bindSpike_BA.1"),
    times = c("BD1","BD29"),
    panel.text.size = 6,
    facet.y.var = vars(factor(assay_label_short, levels = c("Pseudovirus-nAb BA.1 (AU/ml)",
                                                            "Anti Spike IgG BA.1 (AU/ml)"))), 
    facet.x.var = vars(Trt_nnaive2),
    split.var = "Sex",
    pointby = "cohort_col2",
    lgdbreaks = c("Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo"),
    chtcols = setNames(c("goldenrod2","#378252","goldenrod2","#378252"), c("Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo")),
    chtpchs = setNames(c(17, 1, 17, 1), c("Omicron Cases Vaccine", "Omicron Cases Placebo", "Non-Cases Vaccine", "Non-Cases Placebo")),
    strip.text.y.size = 18,
    axis.text.x.size = 18
)

for (i in 1:length(c("female","male"))){
    
    sex = c("female","male")[i]
    
    file_name <- paste0("BA.1_longitudinal_by_case_non_case_BD1_BD29_pooled_v3", "_", sex, ".pdf")
    ggsave(plot = f_2.5[[i]], filename = paste0(save.results.to, file_name), width = 16, height = 11)
    
}

###### Set 3 plots: Correlation plots across markers at a given time point
# 9 markers, three timepoints
for (t in c("BD1","BD29","DeltaBD29overBD1")) {
    
    subset_columns <- dat.cor.subset.plot3[, paste0(t, assays)]
    cleaned_data <- subset_columns[rowSums(is.na(subset_columns)) < ncol(subset_columns), ] # Remove rows where all columns in the subset are missing
    
    covid_corr_pairplots(
        plot_dat = dat.cor.subset.plot3,
        time = t,
        assays = assays,
        strata = "all_one",
        weight = "wt.BD29",
        corr_size = 3,
        plot_title = paste0(
            "Correlations of 9 ", t, " antibody markers, Corr = Weighted Spearman Rank Correlation. n=", 
            nrow(cleaned_data)
        ),
        column_labels = paste(t, assay_metadata$assay_label_short),
        height = max(1.3 * length(assays) + 0.1, 5.5),
        width = max(1.3 * length(assays), 5.5),
        column_label_size = ifelse(max(nchar(paste(t, assay_metadata$assay_label_short)))>40, 3.3, 3.8),
        filename = paste0(
            save.results.to, "/pairs_by_time_", t,
            "_9_markers.pdf"
        )
    )


    # 4 markers, three timepoints
    assay_metadata_sub <- subset(assay_metadata, assay %in% c("bindSpike", "bindSpike_BA.1", "pseudoneutid50", "pseudoneutid50_BA.1"))
    subset_columns <- dat.cor.subset.plot3[, paste0(t, assay_metadata_sub$assay)]
    cleaned_data <- subset_columns[rowSums(is.na(subset_columns)) < ncol(subset_columns), ] # Remove rows where all columns in the subset are missing
    
    covid_corr_pairplots(
        plot_dat = dat.cor.subset.plot3,
        time = t,
        assays = assay_metadata_sub$assay,
        strata = "all_one", 
        # currently strata is hard-coded to 1's and hard-coded not being used in the correlation calculation
        # strata-based model is currently commented out in the function, ggally_statistic_resample
        weight = "wt.BD29",
        corr_size = 4,
        plot_title = paste0(
            "Correlations of 4 ", t, " antibody markers, ", if (grepl("Delta", t)) "\n", "Corr = Weighted Spearman Rank Correlation. n=", 
            nrow(cleaned_data)
        ),
        column_labels = paste(t, assay_metadata_sub$assay_label_short),
        height = max(1.3 * length(assay_metadata_sub$assay) + 0.1, 5.5),
        width = max(1.3 * length(assay_metadata_sub$assay), 5.5),
        column_label_size = ifelse(max(nchar(paste(t, assay_metadata_sub$assay_label_short)))>40, 3.3, 4.3),
        filename = paste0(
            save.results.to, "/pairs_by_time_", t,
            "_4_markers.pdf"
        )
    )
    
    # 4 markers, three timepoints, among Naive participants, adhoc request by Bo
    subset_columns <- subset(dat.cor.subset.plot3, nnaive == 0)[, paste0(t, assay_metadata_sub$assay)]
    cleaned_data <- subset_columns[rowSums(is.na(subset_columns)) < ncol(subset_columns), ] # Remove rows where all columns in the subset are missing
    
    covid_corr_pairplots(
        plot_dat = subset(dat.cor.subset.plot3, nnaive == 0),
        time = t,
        assays = assay_metadata_sub$assay,
        strata = "all_one", 
        # currently strata is hard-coded to 1's and hard-coded not being used in the correlation calculation
        # strata-based model is currently commented out in the function, ggally_statistic_resample
        weight = "wt.BD29",
        corr_size = 4,
        plot_title = paste0(
            "Correlations of 4 ", t, " antibody markers, among naive participants\n", "Corr = Weighted Spearman Rank Correlation. n=", 
            nrow(cleaned_data)
        ),
        column_labels = paste(t, assay_metadata_sub$assay_label_short),
        height = max(1.3 * length(assay_metadata_sub$assay) + 0.1, 5.5),
        width = max(1.3 * length(assay_metadata_sub$assay), 5.5),
        column_label_size = ifelse(max(nchar(paste(t, assay_metadata_sub$assay_label_short)))>40, 3.3, 4.3),
        filename = paste0(
            save.results.to, "/pairs_by_time_", t,
            "_4_markers_N.pdf"
        )
    )
    
    
    # 4 markers, three timepoints, among Non-naive participants, adhoc request by Bo
    subset_columns <- subset(dat.cor.subset.plot3, nnaive == 1)[, paste0(t, assay_metadata_sub$assay)]
    cleaned_data <- subset_columns[rowSums(is.na(subset_columns)) < ncol(subset_columns), ] # Remove rows where all columns in the subset are missing
    
    covid_corr_pairplots(
        plot_dat = subset(dat.cor.subset.plot3, nnaive == 1),
        time = t,
        assays = assay_metadata_sub$assay,
        strata = "all_one", 
        # currently strata is hard-coded to 1's and hard-coded not being used in the correlation calculation
        # strata-based model is currently commented out in the function, ggally_statistic_resample
        weight = "wt.BD29",
        corr_size = 4,
        plot_title = paste0(
            "Correlations of 4 ", t, " antibody markers, among non-naive participants\n", "Corr = Weighted Spearman Rank Correlation. n=", 
            nrow(cleaned_data)
        ),
        column_labels = paste(t, assay_metadata_sub$assay_label_short),
        height = max(1.3 * length(assay_metadata_sub$assay) + 0.1, 5.5),
        width = max(1.3 * length(assay_metadata_sub$assay), 5.5),
        column_label_size = ifelse(max(nchar(paste(t, assay_metadata_sub$assay_label_short)))>40, 3.3, 4.3),
        filename = paste0(
            save.results.to, "/pairs_by_time_", t,
            "_4_markers_NN.pdf"
        )
    )
}


###### Set 4 plots: Correlation plots for a given marker across time points
# 9 markers, by naive/non-naive, vaccine/placebo
for (a in assays){
    panels_set <- list()
    i <- 1
    dat.cor.subset.plot3$Trt_nnaive = with(dat.cor.subset.plot3, 
                                           case_when(Trt == 1 & nnaive == 0 ~ "Vaccine Naive", 
                                                     Trt == 1 & nnaive == 1 ~ "Vaccine Non-naive", 
                                                     Trt == 0 & nnaive == 0 ~ "Placebo Naive", 
                                                     Trt == 0 & nnaive == 1 ~ "Placebo Non-naive"))
    for (tn in c("Vaccine Naive", "Vaccine Non-naive", "Placebo Naive", "Placebo Non-naive")){
        for (ce in c("Non-Cases", "Omicron Cases")){
            times_sub = c("BD1","BD29",if(ce=="Omicron Cases") "DD1")
            
            panels_set[[i]] = covid_corr_pairplots(
                plot_dat = dat.cor.subset.plot3 %>% filter(Trt_nnaive == tn & cohort_event == ce),
                time = times_sub,
                assays = a,
                strata = "all_one",
                weight = "wt.BD29",
                plot_title = "",
                corr_size = 2,
                column_labels = times_sub,
                height = 5.5,
                width = 5.5,
                column_label_size = 10,
                write_to_file = F
            ) 
            i = i + 1
        }
    }
    
    y.grob.1 <- textGrob("Vaccine     \nNaive", gp=gpar(fontface="bold", col="black", fontsize=9))
    y.grob.2 <- textGrob("Vaccine   \nNon-naive", gp=gpar(fontface="bold", col="black", fontsize=9))
    y.grob.3 <- textGrob("Placebo     \nNaive", gp=gpar(fontface="bold", col="black", fontsize=9))
    y.grob.4 <- textGrob("Placebo   \nNon-naive", gp=gpar(fontface="bold", col="black", fontsize=9))
    
    #x.grob <- textGrob(paste0(
    #    "Correlations of ", a, " Levels at BD1, BD29 (and DD1) by Cases/Non-cases, Corr = Weighted Spearman Rank Correlation."
    #), gp=gpar(fontface="bold", col="black", fontsize=9))
   
    #add to plot
    combined_p <- grid.arrange(
        grid.arrange(arrangeGrob(plot_grid(
            ggmatrix_gtable(panels_set[[1]]), ggmatrix_gtable(panels_set[[2]])), left = y.grob.1), nrow=1),
        grid.arrange(arrangeGrob(plot_grid(
            ggmatrix_gtable(panels_set[[3]]), ggmatrix_gtable(panels_set[[4]])), left = y.grob.2), nrow=1),
        grid.arrange(arrangeGrob(plot_grid(
            ggmatrix_gtable(panels_set[[5]]), ggmatrix_gtable(panels_set[[6]])), left = y.grob.3), nrow=1),
        grid.arrange(arrangeGrob(plot_grid(
            ggmatrix_gtable(panels_set[[7]]), ggmatrix_gtable(panels_set[[8]])), left = y.grob.4), nrow=1),
        #bottom = x.grob,
        ncol = 1
    )
    
    ggsave(filename = paste0(
        save.results.to, "/pairs_by_timepoints_", a, ".pdf"), plot = combined_p, width = 8, height = 10, units="in")
}


# 9 markers, by naive, non-naive
for (a in assays){
    panels_set <- list()
    i <- 1
    dat.cor.subset.plot3$nnaive_lb = with(dat.cor.subset.plot3, 
                                           case_when(nnaive == 0 ~ "Naive", 
                                                     nnaive == 1 ~ "Non-naive"))
    for (tn in c("Naive", "Non-naive")){
        for (ce in c("Non-Cases", "Omicron Cases")){
            times_sub = c("BD1","BD29",if(ce=="Omicron Cases") "DD1")
            
            panels_set[[i]] = covid_corr_pairplots(
                plot_dat = dat.cor.subset.plot3 %>% filter(nnaive_lb == tn & cohort_event == ce),
                time = times_sub,
                assays = a,
                strata = "all_one",
                weight = "wt.BD29",
                plot_title = "",
                corr_size = 3,
                column_labels = times_sub,
                height = 5.5,
                width = 5.5,
                column_label_size = 10,
                write_to_file = F
            ) 
            i = i + 1
        }
    }
    
    y.grob.1 <- textGrob("Naive", gp=gpar(fontface="bold", col="black", fontsize=9))
    y.grob.2 <- textGrob("Non-\nnaive", gp=gpar(fontface="bold", col="black", fontsize=9))
    
    #x.grob <- textGrob(paste0(
    #    "Correlations of ", a, " Levels at BD1, BD29 (and DD1) by Cases/Non-cases, Corr = Weighted Spearman Rank Correlation."
    #), gp=gpar(fontface="bold", col="black", fontsize=9))
    
    #add to plot
    combined_p <- grid.arrange(
        grid.arrange(arrangeGrob(plot_grid(
            ggmatrix_gtable(panels_set[[1]]), ggmatrix_gtable(panels_set[[2]])), left = y.grob.1), nrow=1),
        grid.arrange(arrangeGrob(plot_grid(
            ggmatrix_gtable(panels_set[[3]]), ggmatrix_gtable(panels_set[[4]])), left = y.grob.2), nrow=1),
        #bottom = x.grob,
        ncol = 1
    )
    
    ggsave(filename = paste0(
        save.results.to, "/pairs_by_timepoints_", a, "_pooled.pdf"), plot = combined_p, width = 8, height = 10, units="in")
}


## adhoc figure 5
assays_adhoc <- c("bindSpike","pseudoneutid50","bindSpike_BA.1","pseudoneutid50_BA.1")
for (i in 1:length(assays_adhoc)){
    x.var <- paste0("BD1", assays_adhoc)[i]
    y.var <- paste0("DeltaBD29overBD1", assays_adhoc)[i]
    x.lb <- paste("BD1", assay_labels_short[match(assays_adhoc, names(assay_labels_short))])[i]
    y.lb <- paste("DeltaBD29overBD1\n", assay_labels_short[match(assays_adhoc, names(assay_labels_short))])[i]
    
    dat_plot <- dat.long.cor.subset.plot5 %>%
        mutate(Trt_nnaive2 = factor(paste(nnaive, cohort_event), 
                                    levels = c("Naive Omicron Cases", "Naive Non-Cases", "Non-naive Omicron Cases", "Non-naive Non-Cases"),
                                    labels = c("Naive\nOmicron Cases", "Naive\nNon-Cases", "Non-naive\nOmicron Cases", "Non-naive\nNon-Cases")),
               Trt = factor(Trt, levels = c("Vaccine", "Placebo")))
    
    plot_theme <- theme_bw() +
        theme(plot.title = element_text(hjust = 0.5),
              axis.title = element_text(size = 24, face="bold"),
              axis.text = element_text(size = 20),
              strip.text.x = element_text(size = 25), # facet label size
              strip.text.y = element_text(size = 13),
              strip.background = element_rect(fill=NA,colour=NA),
              strip.placement = "outside",
              legend.position = "bottom", 
              legend.text = element_text(size = 16, face="plain"),
              legend.key = element_blank(), # remove square outside legend key
              plot.caption = element_text(size = 26, hjust=0, face="plain"), 
              panel.grid.major = element_blank(), 
              panel.grid.minor = element_blank(),
              plot.margin = margin(5.5, 12, 5.5, 5.5, "pt")) 
    
    sample_sizes <- dat_plot %>%
        filter(assay == assays_adhoc[i]) %>%
        group_by(Trt_nnaive2) %>%
        dplyr::summarize(n = n())
    
    p2 <- 
        ggplot(dat_plot %>% filter(assay == assays_adhoc[i]), 
               aes_string(x.var, y.var, color = "Trt")) +
        geom_text(data = sample_sizes, aes(x = 3, y = -0.5, label = paste0("n = ", n)),
                  hjust = 1.1, vjust = 1.5, color = "black", size = 4, inherit.aes = FALSE) +
        facet_grid(cols = vars(Trt_nnaive2)) +
        geom_point(size = 2) +
        geom_smooth(method = "loess", se=FALSE, color="red") +
        geom_rug(alpha = 0.6, position = "jitter") +
        geom_hline(aes(yintercept = 0), linetype = "dashed", color = "gray", na.rm = TRUE) +
        scale_color_manual(name = "", values = c("goldenrod2","#378252"), drop=FALSE) +
        scale_x_continuous(
            #limits = c(1.5, 5),
            labels = scales::label_math(10^.x)
        ) +
        scale_y_continuous(
            #limits = c(-1, 3),
            labels = scales::label_math(10^.x)
        ) +
        xlab(x.lb) + 
        ylab(y.lb) + 
        theme_bw() +
        coord_fixed(ratio = 1) +
        plot_theme
    
    file_name <- paste0(assays_adhoc[i], "_scatter_BD1_DeltaBD29overBD1_adhoc2.pdf")
    ggsave(plot = p2, filename = paste0(save.results.to, file_name), width = 16, height = 11)
    
}
