######## Check vaccination data #####

# Clear all variables except the ones containing metadata for 2021 and 2022
rm(list=ls()[! ls() %in% c("metadata_2021","metadata_2022")])

# Extract the columns related to vaccination: vaccine status, 1st dose, 2nd dose, and booster dose
vac_2021 = metadata_2021[,c("VACINA_COV", "DOSE_1_COV", "DOSE_2_COV", "DOSE_REF")]
vac_2022 = metadata_2022[,c("VACINA_COV", "DOSE_1_COV", "DOSE_2_COV", "DOSE_REF")]

# Filter the data to include only those who received the COVID vaccine ("VACINA_COV" = 1)
vac_2021_S = vac_2021[vac_2021$VACINA_COV %in% c("1"), ]
vac_2022_S = vac_2022[vac_2022$VACINA_COV %in% c("1"), ]

# Select only the columns with the date of the 1st dose
vac_2021_S_cov = vac_2021_S[,c("VACINA_COV", "DOSE_1_COV")]
vac_2022_S_cov = vac_2022_S[,c("VACINA_COV", "DOSE_1_COV")] 

# Select only the columns with the date of the 2nd dose
vac_2021_S2_cov = vac_2021_S[,c("VACINA_COV", "DOSE_2_COV")]
vac_2022_S2_cov = vac_2022_S[,c("VACINA_COV", "DOSE_2_COV")] 

# Select only the columns with the date of the booster dose (3rd dose)
vac_2021_Sref_cov = vac_2021_S[,c("VACINA_COV", "DOSE_REF")]
vac_2022_Sref_cov = vac_2022_S[,c("VACINA_COV", "DOSE_REF")] 

# Combine 2021 and 2022 vaccination data for 1st dose, 2nd dose, and booster dose respectively
vac1_s_cov <- rbind(vac_2021_S_cov, vac_2022_S_cov) 
str(vac1_s_cov)

vac2_s_cov <- rbind(vac_2021_S2_cov, vac_2022_S2_cov) 
str(vac2_s_cov)

vacREF_s_cov <- rbind(vac_2021_Sref_cov, vac_2022_Sref_cov) 
str(vacREF_s_cov)

# Convert vaccination dates from string format to Date format for further processing
vac1_s_cov$DOSE_1_COV_new <- as.Date(vac1_s_cov$DOSE_1_COV, format = "%d/%m/%Y")
str(vac1_s_cov)

vac2_s_cov$DOSE_2_COV_new <- as.Date(vac2_s_cov$DOSE_2_COV, format = "%d/%m/%Y")
str(vac2_s_cov)

vacREF_s_cov$DOSE_REF_new <- as.Date(vacREF_s_cov$DOSE_REF, format = "%d/%m/%Y")
str(vacREF_s_cov)

# Filter out rows with missing vaccination dates and select the relevant columns
# Also, restrict the data to the specified date range (from 2021-11-25 to 2022-11-13)
vac1_s_cov = vac1_s_cov[,c("VACINA_COV", "DOSE_1_COV_new")] %>% drop_na() %>%
  filter(between(DOSE_1_COV_new, as.Date('2021-11-25'), as.Date('2022-11-13')))

vac2_s_cov = vac2_s_cov[,c("VACINA_COV", "DOSE_2_COV_new")] %>% drop_na() %>%
  filter(between(DOSE_2_COV_new, as.Date('2021-11-25'), as.Date('2022-11-13')))

vacREF_s_cov = vacREF_s_cov[,c("VACINA_COV", "DOSE_REF_new")] %>% drop_na() %>%
  filter(between(DOSE_REF_new, as.Date('2021-11-25'), as.Date('2022-11-13')))

# Group the data by week and count the number of records for 1st dose, 2nd dose, and booster dose
vac1_s_cov_group <- vac1_s_cov %>% group_by(week = cut(DOSE_1_COV_new, "week"), VACINA_COV) %>% tally()
vac1_s_cov_group$week = as.Date(vac1_s_cov_group$week)

vac2_s_cov_group <- vac2_s_cov %>% group_by(week = cut(DOSE_2_COV_new, "week"), VACINA_COV) %>% tally()
vac2_s_cov_group$week = as.Date(vac2_s_cov_group$week)

vacREF_s_cov_group <- vacREF_s_cov %>% group_by(week = cut(DOSE_REF_new, "week"), VACINA_COV) %>% tally()
vacREF_s_cov_group$week = as.Date(vacREF_s_cov_group$week)

# Plot the number of 1st dose vaccinations over time
line <- ggplot(vac1_s_cov_group) +
  geom_line(aes(x = week, y = n)) +
  scale_y_continuous(position = "right", labels = scales::comma, name = "1st dose of vaccination") +
  scale_x_date(date_breaks = "1 month", date_minor_breaks = "1 week",
               date_labels = "%B %Y") + theme_classic() +
  labs(title = "",x= "" , y = "Number of cases") + 
  theme(
    # Customize the plot's theme (remove axis labels and ticks for the x-axis)
    axis.title.y = element_text(size = 14),
    axis.text=element_text(size=10),
    plot.title = element_text(hjust = 0.5, size = 16),
    legend.title = element_text(size=12),
    legend.text = element_text(size=10),
    axis.title.x=element_blank(),
    axis.text.x=element_blank(),
    axis.ticks.x=element_blank()
  )
line

# Adjust the plot's theme to make the background transparent
p <- line + theme( rect = element_rect(fill = "transparent"))
p <- p +
  theme(
    panel.background = element_rect(fill = "transparent"), # Panel background
    plot.background = element_rect(fill = "transparent", color = NA), # Plot background
    panel.grid.major = element_blank(), # Remove major grid lines
    panel.grid.minor = element_blank(), # Remove minor grid lines
    legend.background = element_rect(fill = "transparent"), # Legend background
    legend.box.background = element_rect(fill = "transparent") # Legend box background
  )

# Save the plot as a PNG file with a transparent background
ggsave("vacina_1.png",plot = p, dpi = 300, height = 9, width = 14)
