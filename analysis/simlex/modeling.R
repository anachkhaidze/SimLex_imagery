# Load lme4 for mixed models
# load libraries
suppressMessages(library(tidyverse))
suppressMessages(library(lmerTest))
suppressMessages(library(MuMIn))
suppressMessages(library(broom.mixed))
suppressMessages(library(lavaan))
suppressMessages(library(reshape2))
suppressMessages(library(psych))
suppressMessages(library(glue))
suppressMessages(library(optimx))
library(ggplot2)
library(RColorBrewer)
library(extrafont)
library(magick)
library(Rcpp)
library(sjPlot)
library(effects)
library(corrplot)
library(RColorBrewer)
library(aod)
library(ResourceSelection)
library(glmtoolbox)
library(fmsb)

df_final <- read.csv("simLex_questionnaire_cleaned.csv", stringsAsFactors = FALSE)

# Full model
visual_model_full <- lmer(value ~ vviq_z * lancsensorymotorsim +
                            vviq_z * glovesim + (1 | subject), data = df_final)

# Reduced model 1
visual_model_reduced_1 <- lmer(value ~ vviq_z + lancsensorymotorsim +
                                 vviq_z * glovesim + (1 | subject), data = df_final)

# Reduced model 2
visual_model_reduced_2 <- lmer(value  ~ vviq_z * lancsensorymotorsim +
                                 vviq_z + glovesim + (1 | subject), data = df_final)

# Print the summary of the models
cat("Full Model Summary:\n")
print(summary(visual_model_full))
cat("\nReduced Model 1 Summary:\n")
print(summary(visual_model_reduced_1))
cat("\nReduced Model 2 Summary:\n")
print(summary(visual_model_reduced_2))

# Plot residuals for the full model
plot(residuals(visual_model_full) ~ fitted(visual_model_full), main = "Residuals vs Fitted for Full Model", xlab = "Fitted values", ylab = "Residuals")

# Histogram of random effects (subject intercepts)
hist(ranef(visual_model_full)$subject[,1], main = "Histogram of Random Effects for Subject", xlab = "Random Effects", ylab = "Frequency")

# Calculate AIC for each model
aic_full <- AIC(visual_model_full)
aic_reduced_1 <- AIC(visual_model_reduced_1)
aic_reduced_2 <- AIC(visual_model_reduced_2)

# Calculate R^2 for each model
r2_full <- performance::r2(visual_model_full)
r2_reduced_1 <- performance::r2(visual_model_reduced_1)
r2_reduced_2 <- performance::r2(visual_model_reduced_2)

# Print results
cat("AIC and R^2 Comparison:\n")

cat(sprintf("Full Model: AIC = %f, R^2 = %f\n", aic_full, r2_full))
cat(sprintf("Reduced Model 1: AIC = %f, R^2 = %f\n", aic_reduced_1, r2_reduced_1))
cat(sprintf("Reduced Model 2: AIC = %f, R^2 = %f\n", aic_reduced_2, r2_reduced_2))

anova(visual_model_full,visual_model_reduced_1)
anova(visual_model_full,visual_model_reduced_2)


# Full model verbal
verbal_model_full <- lmer(value ~ z_osivq_verbal_mean * lancsensorymotorsim +
                            z_osivq_verbal_mean * glovesim + (1 | subject), data = df_final)

# Reduced model 1
verbal_model_reduced_1 <- lmer(value ~ z_osivq_verbal_mean * lancsensorymotorsim +
                                 z_osivq_verbal_mean + glovesim + (1 | subject), data = df_final)

# Reduced model 2
verbal_model_reduced_2 <- lmer(value ~ z_osivq_verbal_mean + lancsensorymotorsim +
                                 z_osivq_verbal_mean * glovesim + (1 | subject), data = df_final)

# Print the summary of the models
cat("Full Model Summary:\n")
print(summary(verbal_model_full))
cat("\nReduced Model 1 Summary:\n")
print(summary(verbal_model_reduced_1))
cat("\nReduced Model 2 Summary:\n")
print(summary(verbal_model_reduced_2))

# Plot residuals for the full model
plot(residuals(verbal_model_full) ~ fitted(verbal_model_full), main = "Residuals vs Fitted for Full Model", xlab = "Fitted values", ylab = "Residuals")

# Histogram of random effects (subject intercepts)
hist(ranef(verbal_model_full)$subject[,1], main = "Histogram of Random Effects for Subject", xlab = "Random Effects", ylab = "Frequency")

# Calculate AIC for each model
aic_full <- AIC(verbal_model_full)
aic_reduced_1 <- AIC(verbal_model_reduced_1)
aic_reduced_2 <- AIC(verbal_model_reduced_2)

# Calculate R^2 for each model
r2_full <- performance::r2(verbal_model_full)
r2_reduced_1 <- performance::r2(verbal_model_reduced_1)
r2_reduced_2 <- performance::r2(verbal_model_reduced_2)

# Print results
cat("AIC and R^2 Comparison:\n")
cat(sprintf("Full Model: AIC = %f, R^2 = %f\n", aic_full, r2_full))
cat(sprintf("Reduced Model 1: AIC = %f, R^2 = %f\n", aic_reduced_1, r2_reduced_1))
cat(sprintf("Reduced Model 2: AIC = %f, R^2 = %f\n", aic_reduced_2, r2_reduced_2))

anova(verbal_model_full,verbal_model_reduced_1)
anova(verbal_model_full,verbal_model_reduced_2)

model_summary <- summary(verbal_model_full)
plot_model(visual_model_full)
plot_model(verbal_model_full)
summary(visual_model_full)
summary(verbal_model_full)

# Creating a new data frame with the three variables
data_for_correlation <- data.frame(glovesim = scale(df_final$glovesim), 
                                   value = scale(df_final$value), 
                                   lancsensorymotorsim = scale(df_final$lancsensorymotorsim))

# Renaming columns using dplyr
data_for_correlation <- data_for_correlation %>%
  rename(GloVe_sim = glovesim,
         Human_sim = value,
         LS_sim = lancsensorymotorsim)

# Compute the correlation matrix
cor_matrix <- cor(data_for_correlation, use = "complete.obs")

melted_cor_matrix <- reshape2::melt(cor_matrix)

# Plot with correlation values in the boxes
ggplot(melted_cor_matrix, aes(Var1, Var2, fill = value)) +
  geom_tile(color = "white") +  # Add tiles
  geom_text(aes(label = sprintf("%.2f", value)), color = "black", size = 4) +  # Add text labels formatted to 2 decimal places
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1, 1), space = "Lab", 
                       name="") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1),
        axis.ticks = element_blank(),) +  # Adjust the text angle for X-axis labels +
  labs(title = "", x = "", y = "") +
  coord_fixed() +
  theme(
    text = element_text(family = "Georgia", size = 16),  # Setting font to Georgia and increasing size
    axis.title = element_text(size = 18),                # Adjusting axis titles separately if needed
    axis.text = element_text(size = 16),                 # Adjusting axis text separately if needed
    legend.title = element_text(size = 18),              # Adjusting legend title separately if needed
    legend.text = element_text(size = 16),               # Adjusting legend text separately if needed
    axis.title.x = element_text(margin = margin(t = 10)) # Increasing distance between x-axis title and labels
  )

melted_cor_matrix

# df_final <- read.csv("simLex_questionnaires.csv", stringsAsFactors = FALSE)


# Calculate the 33rd and 66th percentiles
percentiles <- quantile(df_final$vviq_z, probs = c(0.33, 0.66))

# Bin 'z_osivq_verbal_mean' into three groups: lowest, middle, highest
df_final$z_osivq_verbal_mean_bin <- cut(df_final$z_osivq_verbal_mean,
                           breaks = c(-Inf, percentiles[1], percentiles[2], Inf),
                           labels = c("Lowest Third", "Middle Third", "Highest Third"),
                           include.lowest = TRUE)

# Check the resulting binning
table(df_final$z_osivq_verbal_mean_bin) 

# Step 1: Compute correlations for each bin
correlation_data <- df_final %>%
  group_by(z_osivq_verbal_mean_bin) %>%
  summarize(
    Corr_LancSensory_Value = abs(cor(lancsensorymotorsim, value, use = "complete.obs")),
    Corr_GloveSim_Value = abs(cor(glovesim, value, use = "complete.obs"))
  ) %>%
  pivot_longer(cols = starts_with("Corr"), names_to = "Predictor", values_to = "Correlation")

# Step 2: Prepare data for plotting
# This involves no additional steps as `pivot_longer` has already reshaped the data appropriately.

# Step 3: Create the bar plot
ggplot(correlation_data, aes(x = z_osivq_verbal_mean_bin, y = Correlation, fill = Predictor)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
  labs(title = "",
       x = "Binned OSIVQ Verbal Scores",
       y = "Mean Absolute Correlation",
       fill = "Model") +
  theme_minimal() +
  scale_fill_brewer(
    palette = "Pastel1",  # Using a pleasant color palette
    labels = c("Corr_GloveSim_Value" = "Glove-Based Similarity", "Corr_LancSensory_Value" = "LS-Based Similarity")
  ) +
  scale_x_discrete(
    labels = c("Lowest Third" = "Lowest", "Middle Third" = "Middle", "Highest Third" = "Highest")
  ) +
  theme(
    text = element_text(family = "Georgia", size = 16),  # Setting font to Georgia and increasing size
    axis.title = element_text(size = 18),                # Adjusting axis titles separately if needed
    axis.text = element_text(size = 16),                 # Adjusting axis text separately if needed
    legend.title = element_text(size = 18),              # Adjusting legend title separately if needed
    legend.text = element_text(size = 16),               # Adjusting legend text separately if needed
    axis.title.x = element_text(margin = margin(t = 10)) # Increasing distance between x-axis title and labels
  )


# Bin 'vviq_z' into three groups: lowest, middle, highest
df_final$osivq_visual_z_bins <- cut(df_final$z_osivq_visual_mean,
                           breaks = c(-Inf, percentiles[1], percentiles[2], Inf),
                           labels = c("Lowest Third", "Middle Third", "Highest Third"),
                           include.lowest = TRUE)

# Check the resulting binning
table(df_final$osivq_visual_z_bins)  # To see how many entries fall into each category

# Step 2: Compute correlations for each bin
correlation_data <- df_final %>%
  group_by(osivq_visual_z_bins) %>%
  summarize(
    Corr_LancSensory_Value = abs(cor(lancsensorymotorsim, value, use = "complete.obs")),
    Corr_GloveSim_Value = abs(cor(glovesim, value, use = "complete.obs"))
  ) %>%
  pivot_longer(cols = starts_with("Corr"), names_to = "Predictor", values_to = "Correlation")


# Step 3: Create the bar plot
library(ggplot2)

# Assuming 'Predictor' in your data has the original values 'Corr_GloveSim_Value' and 'Corr_LancSensory_Value'
# and you want to rename them in the legend.

# Step 3: Create the bar plot
ggplot(correlation_data, aes(x = osivq_visual_z_bins, y = Correlation, fill = Predictor)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
  labs(title = "",
       x = "Binned OSIVQ Visual Scores",
       y = "Mean Absolute Correlation",
       fill = "Predictor") +
  theme_minimal() +
  scale_fill_brewer(
    palette = "Pastel1",  # Using a pleasant color palette
    labels = c("Corr_GloveSim_Value" = "Glove-Based Similarity", "Corr_LancSensory_Value" = "LS-Based Similarity")
  ) +
  scale_x_discrete(
    labels = c("Lowest Third" = "Lowest", "Middle Third" = "Middle", "Highest Third" = "Highest")
  ) +
  theme(
    text = element_text(family = "Georgia", size = 16),  # Setting font to Georgia and increasing size
    axis.title = element_text(size = 18),                # Adjusting axis titles separately if needed
    axis.text = element_text(size = 16),                 # Adjusting axis text separately if needed
    legend.title = element_text(size = 18),              # Adjusting legend title separately if needed
    legend.text = element_text(size = 16),               # Adjusting legend text separately if needed
    axis.title.x = element_text(margin = margin(t = 10)) # Increasing distance between x-axis title and labels
  )


# Calculate the number of unique subjects per bin
unique_subjects_per_bin <- df_final %>%
  group_by(z_irq_visual_mean_bin) %>%
  summarize(unique_subjects = n_distinct(subject),
            .groups = 'drop')  # Dropping groups for cleaner output

# Calculate the number of unique subjects per bin
unique_subjects_per_bin_verbal <- df_final %>%
  group_by(z_osivq_verbal_mean_bin) %>%
  summarize(unique_subjects = n_distinct(subject),
            .groups = 'drop')  # Dropping groups for cleaner output

# Print the results
print(unique_subjects_per_bin)
print(unique_subjects_per_bin_verbal)



# Calculate correlations grouped by subject
df_correlations <- df_final %>%
  group_by(subject) %>%
  summarize(
    glove_correlation = abs(cor(glovesim, value, use = "complete.obs")),
    ls_correlation = abs(cor(lancsensorymotorsim, value, use = "complete.obs")),
    .groups = 'drop'
  )

# Join correlations back to df_final
df_summary <- df_final %>%
  select(subject, vviq_sum, osivq_verbal_mean, osivq_visual_mean, osivq_spatial_mean, irq_verbal_mean, irq_visual_mean) %>%
  distinct() %>%
  left_join(df_correlations, by = "subject")

# Reshape data for plotting
df_plot <- df_summary %>%
  pivot_longer(cols = c("glove_correlation", "ls_correlation"), names_to = "correlation_type", values_to = "correlation")

# Setting custom colors
custom_colors <- c("glove_correlation" = "#02b5a3", "ls_correlation" = "#e60079")  # Coral and Turquoise Blue
custom_labels <- c("Glove", "LS")  # Custom labels for the legend

# Plot using ggplot2
ggplot(df_plot, aes(x = vviq_sum, y = correlation, color = correlation_type)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", formula = y ~ x, aes(fill = correlation_type), se = TRUE, fullrange = TRUE, alpha = 0.2) +
  scale_color_manual(values = custom_colors, labels = custom_labels) +
  scale_fill_manual(values = custom_colors, labels = custom_labels) +
  labs(
    x = "VVIQ Scores",
    y = expression(R^2)) +  # Setting y-axis label to R^2
  theme_minimal() +
  theme(legend.position = "bottom",
        axis.title.x = element_text(margin = margin(t = 10, unit = "pt")),  # Increase bottom margin for x-axis title
        axis.title.y = element_text(margin = margin(r = 10, unit = "pt"))) +  # Increase right margin for y-axis title
  guides(color = guide_legend(title = NULL), fill = guide_legend(title = NULL)) +
  labs(title = "",
       x = "VVIQ Scores",
       y = "Mean Absolute Correlation",
       fill = "Predictor") +
  theme_minimal() +
  theme(
    text = element_text(family = "Georgia", size = 16),  # Setting font to Georgia and increasing size
    axis.title = element_text(size = 18),                # Adjusting axis titles separately if needed
    axis.text = element_text(size = 16),                 # Adjusting axis text separately if needed
    legend.title = element_text(size = 18),              # Adjusting legend title separately if needed
    legend.text = element_text(size = 16),               # Adjusting legend text separately if needed
    axis.title.x = element_text(margin = margin(t = 10)) # Increasing distance between x-axis title and labels
  )


# Plot using ggplot2
ggplot(df_plot, aes(x = irq_verbal_mean, y = correlation, color = correlation_type)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", formula = y ~ x, aes(fill = correlation_type), se = TRUE, fullrange = TRUE, alpha = 0.2) +
  scale_color_manual(values = custom_colors, labels = custom_labels) +
  scale_fill_manual(values = custom_colors, labels = custom_labels) +
  labs(
    x = "VVIQ Scores",
    y = expression(R^2)) +  # Setting y-axis label to R^2
  theme_minimal() +
  theme(legend.position = "bottom",
        axis.title.x = element_text(margin = margin(t = 10, unit = "pt")),  # Increase bottom margin for x-axis title
        axis.title.y = element_text(margin = margin(r = 10, unit = "pt"))) +  # Increase right margin for y-axis title
  guides(color = guide_legend(title = NULL), fill = guide_legend(title = NULL)) +
  labs(title = "",
       x = "IRQ Verbal Scores",
       y = "Mean Absolute Correlation",
       fill = "Predictor") +
  theme_minimal() +
  theme(
    text = element_text(family = "Georgia", size = 16),  # Setting font to Georgia and increasing size
    axis.title = element_text(size = 18),                # Adjusting axis titles separately if needed
    axis.text = element_text(size = 16),                 # Adjusting axis text separately if needed
    legend.title = element_text(size = 18),              # Adjusting legend title separately if needed
    legend.text = element_text(size = 16),               # Adjusting legend text separately if needed
    axis.title.x = element_text(margin = margin(t = 10)) # Increasing distance between x-axis title and labels
  )
