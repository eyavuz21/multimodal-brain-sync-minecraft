library(effectsize);library(car);library(writexl);library(openxlsx);library(ggplot2);library(readr);library(lm.beta);library(readxl); library(data.table); library(tidyr); library(tidyverse); library(zoo); library(dplyr);library(purrr);library(car);library(psych);library(GPArotation);library(lmerTest)

reshaped_df <- read.csv('/Users/macbook/Desktop/7 UCL PhD (2022-2025)/2 Minecraft fNIRS-fMRI Study/Study Files/Minecraftanalysis/Analysispipeline/Behaviouraldata/FINALFRAMEFORMATRIXRSTUDIOMAHAL.csv')
reshaped_df <- reshaped_df[order(reshaped_df$Dyad, reshaped_df$Participant), ]
reshaped_df <- reshaped_df[grepl('Chase', reshaped_df$Event), ]
reshaped_df$EventNumber <- as.numeric(sub("Chase ", "", reshaped_df$Event))
reshaped_df <- reshaped_df[order(reshaped_df$EventNumber, reshaped_df$Time), ]
reshaped_df$EventNumber <- NULL
combined_model_cols <- c(
  'Distance.between.self.and.prey',
  'Distance.between.self.and.other',
  'Scaled.self.facing.prey', 
  'Scaled.self.facing.other',
  'Lag.Score', 
  'Heart.Rate.self', 
  'Breathing.Rate.self', 
  'Time'
)
reshaped_df_z <- reshaped_df %>% mutate(across(combined_model_cols, scale)) %>% mutate(Dyad = as.factor(Dyad))
write_xlsx(reshaped_df_z, "/Users/macbook/Desktop/7 UCL PhD (2022-2025)/2 Minecraft fNIRS-fMRI Study/Study Files/Minecraftanalysis/Analysispipeline/Behaviouraldata/Behaviouralstatsanalysis/NEWMINECRAFTSAMPLE.xlsx")
#combined_formula <- as.formula(paste('Hunting.original ~', paste(combined_model_cols, collapse = " + "), '+ (1 | Dyad) + (1 | Participant)'))
#combined_model_mixed <- lmer(combined_formula, data = reshaped_df_z)
dyad_slopes <- c('Distance.between.self.and.other','Scaled.self.facing.other','Lag.Score')
participant_slopes <- c('Distance.between.self.and.prey', 'Scaled.self.facing.prey','Heart.Rate.self','Breathing.Rate.self')
fixed_effects <- combined_model_cols
random_slopes <- setdiff(combined_model_cols, "Time")
combined_formula <- as.formula(paste('Hunting.original ~',paste(fixed_effects, collapse = " + "),"+ (1 +", paste(dyad_slopes, collapse = " + "), "| Dyad)","+ (1 +", paste(participant_slopes, collapse = " + "), "| Participant)"))
combined_model_mixed <- lmer(combined_formula, data = reshaped_df_z, control = lmerControl(optimizer = "bobyqa"))
vif_combined <- vif(combined_model_mixed)
vif_combined_df <- as.data.frame(vif_combined)
vif_combined_df <- cbind(Variables = rownames(vif_combined_df), vif_combined_df)
write_xlsx(vif_combined_df, "/Users/macbook/Desktop/7 UCL PhD (2022-2025)/2 Minecraft fNIRS-fMRI Study/Study Files/Minecraftanalysis/Analysispipeline/Behaviouraldata/Behaviouralstatsanalysis/Combined_VIFFNIRS.xlsx")
effect_size_combined <- cohens_f(combined_model_mixed)
cohen_f2_combined_df <- data.frame(
  Variable = effect_size_combined$Parameter,
  Cohen_f2 = round((effect_size_combined$Cohens_f_partial)^2, 2),
  stringsAsFactors = FALSE
)
write_xlsx(cohen_f2_combined_df, "/Users/macbook/Desktop/7 UCL PhD (2022-2025)/2 Minecraft fNIRS-fMRI Study/Study Files/Minecraftanalysis/Analysispipeline/Behaviouraldata/Behaviouralstatsanalysis/Combined_Model_Cohen_f2.xlsx")
combined_model_summary <- summary(combined_model_mixed)
#combined_model_CI <- confint(combined_model_mixed)
fixef_vals <- fixef(combined_model_mixed)
se_vals <- sqrt(diag(vcov(combined_model_mixed)))
wald_lower <- fixef_vals - 1.96 * se_vals
wald_upper <- fixef_vals + 1.96 * se_vals
combined_model_CI <- cbind(Estimate = fixef_vals, Lower95 = wald_lower, Upper95 = wald_upper)
extract_coefficients <- function(model_summary, cohen_f_df, model_CI) {
  coef_table <- as.data.frame(model_summary$coefficients)
  coef_table <- coef_table[-1, c(1, 2, 4, 5)]
  colnames(coef_table) <- c("Estimate", "Std.Error", "t", "p")
  coef_table$sig <- ifelse(coef_table$p < 0.05, "*", "")
  variable_names <- rownames(coef_table)
  f2_values <- cohen_f_df$Cohen_f2[match(variable_names, cohen_f_df$Variable)]
  #ci_values <- confint(model_CI)[-c(1, 2, 3, 4), ]  # Remove intercept and random effects CIs
  ci_values <- combined_model_CI[variable_names, ] 
  if (!is.null(ci_values) && nrow(ci_values) == nrow(coef_table)) {
    ci_formatted <- apply(ci_values, 1, function(x) paste0("[", round(x[2], 2), ", ", round(x[1], 2), "]"))
  } else {
    ci_formatted <- rep(NA, nrow(coef_table))
  }
  coef_table <- cbind(Variable = variable_names, β = round(coef_table$Estimate, 2), 
                      `95% CI` = ci_formatted, t = round(coef_table$t, 2), 
                      p = round(coef_table$p, 3), sig = coef_table$sig, f2 = round(f2_values, 2))
  coef_table <- as.data.frame(coef_table)
  coef_table$p <- ifelse(coef_table$p < 0.001, "<0.001", coef_table$p)
  coef_table$f2 <- ifelse(coef_table$f2 < 0.01, "<0.01", coef_table$f2)
  return(coef_table)
}
combined_model_coefficients <- extract_coefficients(combined_model_summary, cohen_f2_combined_df, combined_model_mixed)
custom_order <- c(
 'Distance.between.self.and.prey',
 'Distance.between.self.and.other',
 'Scaled.self.facing.prey',
 'Scaled.self.facing.other',
 'Lag.Score', 
 'Heart.Rate.self', 
 'Breathing.Rate.self', 
 'Time'
)
combined_model_coefficients$Variable <- factor(combined_model_coefficients$Variable, levels = custom_order)
combined_model_coefficients <- combined_model_coefficients[order(combined_model_coefficients$Variable), ]
combined_model_coefficients$Variable <- as.character(combined_model_coefficients$Variable)
write_xlsx(combined_model_coefficients, "/Users/macbook/Desktop/7 UCL PhD (2022-2025)/2 Minecraft fNIRS-fMRI Study/Study Files/Minecraftanalysis/Analysispipeline/Behaviouraldata/Behaviouralstatsanalysis/Combined_Model_CoefficientsFNIRS.xlsx")

#plotting the raw data

library(ggplot2)
library(ggeffects)
library(dplyr)

raw_df <- read.csv('/Users/macbook/Desktop/7 UCL PhD (2022-2025)/2 Minecraft fNIRS-fMRI Study/Study Files/Minecraftanalysis/Analysispipeline/Behaviouraldata/PREZSCOREFRAMECHASE.csv')
#raw_df <- aggregate(raw_df,list(raw_df$Dyad),FUN=mean)
vars <- c(
  "Distance.between.self.and.prey",
  "Lag.Score",
  "Scaled.self.facing.prey",
  "Scaled.self.facing.other"
)
pretty_labels <- c(
  "Distance.between.self.and.prey" = "Distance Between Self and Prey",
  "Lag.Score" = "Speed Synchrony Between Self and Other",
  "Scaled.self.facing.prey" = "Heading Direction from Self to Prey",
  "Scaled.self.facing.other" = "Heading Direction from Self to Other"
)
for (v in vars) {
 print(v)
 if (v == 'Lag.Score'){
  mu <- mean(raw_df[[v]], na.rm = TRUE)       # raw values from reshaped_df
  sigma <- sd(raw_df[[v]], na.rm = TRUE)      # raw values from reshaped_df
  eff <- ggpredict(combined_model_mixed, terms = paste0(v, " [-3.5:7.5]"))
  eff$x_raw <- eff$x * sigma + mu
  p <- ggplot() +
    geom_point(data = raw_df, aes(x = !!sym(v), y = Hunting.Success), color = "black", alpha = 0.5) +
    labs(x = pretty_labels[v], y = "Time Taken to Catch the Prey (Seconds)") +
    coord_cartesian(xlim = c(0,0.4), ylim = c(0,60)) +
    theme_minimal() +
    theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.title.x = element_text(face = "bold", size = 17),
      axis.title.y = element_text(face = "bold", size = 17),
      axis.text.x = element_text(size = 15),
      axis.text.y = element_text(size = 15),
      axis.line = element_line(color = "black",
                               linewidth = 0.3,
                               linetype = 1)
    )
  print(p)
 }
  else if (v == 'Distance.between.self.and.prey'){
    mu <- mean(raw_df[[v]], na.rm = TRUE)       # raw values from reshaped_df
    sigma <- sd(raw_df[[v]], na.rm = TRUE)      # raw values from reshaped_df
    eff <- ggpredict(combined_model_mixed, terms = v)
    eff$x_raw <- eff$x * sigma + mu
    p <- ggplot() +
      geom_point(data = raw_df, aes(x = !!sym(v), y = Hunting.Success), color = "black", alpha = 0.5) +
      geom_line(data = eff, aes(x = x_raw, y = predicted), color = "black", size = 1.2) +
      labs(x = pretty_labels[v], y = "Time Taken to Catch the Prey (Seconds)") +
      coord_cartesian(xlim = c(NA, 25), ylim = c(0, NA))+
      theme_minimal() +
      theme(
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title.x = element_text(face = "bold", size = 17),
        axis.title.y = element_text(face = "bold", size = 17),
        axis.text.x = element_text(size = 15),
        axis.text.y = element_text(size = 15),
        axis.line = element_line(color = "black",
                                 linewidth = 0.3,
                                 linetype = 1)
      )
    print(p)
  }
  else{
    mu <- mean(raw_df[[v]], na.rm = TRUE)       # raw values from reshaped_df
    sigma <- sd(raw_df[[v]], na.rm = TRUE)      # raw values from reshaped_df
    eff <- ggpredict(combined_model_mixed, terms = v)
    eff$x_raw <- eff$x * sigma + mu
    p <- ggplot() +
      geom_point(data = raw_df, aes(x = !!sym(v), y = Hunting.Success), color = "black", alpha = 0.5) +
      labs(x = pretty_labels[v], y = "Time Taken to Catch the Prey (Seconds)") +
      coord_cartesian(xlim = c(NA, NA), ylim = c(0, NA)) +
      theme_minimal() +
      theme(
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title.x = element_text(face = "bold", size = 17),
        axis.title.y = element_text(face = "bold", size = 17),
        axis.text.x = element_text(size = 15),
        axis.text.y = element_text(size = 15),
        axis.line = element_line(color = "black",
                                 linewidth = 0.3,
                                 linetype = 1)
      )
    print(p)
  }
}

#Check assumptions of model and for outliers 

plot(combined_model_mixed)
qqmath(combined_model_mixed)
shapiro.test(resid(combined_model_mixed))
model_residuals <- residuals(combined_model_mixed)
model_residuals_abs_squared <- (abs(model_residuals))^2
reshaped_df_z$Model_Residuals_Squared <- model_residuals_abs_squared
Levene_Dyad_Model <- lm(Model_Residuals_Squared ~ Dyad, data = reshaped_df_z)
anova(Levene_Dyad_Model)
Levene_Participant_Model <- lm(Model_Residuals_Squared ~ Participant, data = reshaped_df_z)
anova(Levene_Participant_Model)
reshaped_df_z$residuals <- res1
participant_residuals <- aggregate(residuals ~ Participant, data = reshaped_df_z, FUN = mean)
outlier_participants <- participant_residuals[which(abs(participant_residuals$residuals) > 2.5), ]
dyad_residuals <- aggregate(residuals ~ Dyad, data = reshaped_df_z, FUN = mean)
outlier_dyads <- dyad_residuals[which(abs(dyad_residuals$residuals) > 2.5), ]
