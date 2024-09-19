# Load necessary libraries
library(dplyr)  # For data manipulation
library(ggplot2)  # For plotting
library(RColorBrewer)  # For color palettes
library(ggstream)  # For stream plots

# Set the number of color categories
n <- 8

# Get a list of all qualitative color palettes from RColorBrewer
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]

# Create a vector of colors by applying the brewer palettes to their maximum color limits
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))

# Create a pie chart with randomly sampled colors from the palette (for visualization purposes)
pie(rep(1,n), col=sample(col_vector, n))

# Set the locale for date formatting to English (useful for plotting dates in English)
Sys.setlocale("LC_TIME", "en_US.UTF-8")

# Update the default ggplot theme to center titles
theme_update(plot.title = element_text(hjust = 0.5))

# Read in the COVID-19 case data from multiple CSV files
cases_2021_pt1 <- read.csv('Casos_COVIDBR_2021_Parte1.csv', sep = ';')
cases_2021_pt2 <- read.csv('Casos_COVIDBR_2021_Parte2.csv', sep = ';')
cases_2022_pt1 <- read.csv('Casos_COVIDBR_2022_Parte1.csv', sep = ';')
cases_2022_pt2 <- read.csv('Casos_COVIDBR_2022_Parte2.csv', sep = ';')

# Combine the parts of the 2021 and 2022 data
cases_2021 <- rbind(cases_2021_pt1, cases_2021_pt2)
cases_2022 <- rbind(cases_2022_pt1, cases_2022_pt2)

# Combine the data from both years into one data frame
all_cases <- rbind(cases_2021, cases_2022)

# Convert the 'data' (date) column to Date format
all_cases$data <- as.Date(all_cases$data)

# Read GISAID sequence data from a CSV file
gisaid_data <- read.csv("../GISAID_sequences/tar_files/GISAID_data.csv")

# Define the date of the first detected Omicron variant (used as a reference point)
first_omicron <- as.Date("2021-11-25")

# Subset the case data to only include cases after the first Omicron detection
cases_post_first_omicron <- subset(all_cases, data >= first_omicron)

# Further subset the data to only include state-level (without city-specific data)
cases_per_state <- subset(cases_post_first_omicron, municipio == '')

# Subset the data to only include cases for the entire country of Brazil
brasil_cases <- subset(cases_post_first_omicron, regiao == 'Brasil')

# Aggregate the Brazilian case data by week, calculating weekly cases and deaths
brasil_cases_weekly <- brasil_cases %>%
  group_by(week = cut(data, "week")) %>%
  mutate(weekly_cases = sum(casosNovos),
         weekly_deaths = sum(obitosNovos))

# Convert the 'week' column to Date format for easier plotting
brasil_cases_weekly$week <- as.Date(brasil_cases_weekly$week)

# Convert the 'date' column in the GISAID data to Date format
gisaid_data$date <- as.Date(gisaid_data$date)

# Aggregate the GISAID data by week and clade, counting the number of sequences per clade per week
gisaid_nextClade_weekly <- gisaid_data %>%
  group_by(week = cut(date, "week"), Nextstrain_clade) %>%
  tally()

# Convert the 'week' column to Date format for plotting
gisaid_nextClade_weekly$week <- as.Date(gisaid_nextClade_weekly$week)


# Plot weekly COVID-19 cases and deaths for Brazil
p_BR_weekly <- ggplot(brasil_cases_weekly) +
  geom_line(aes(x = week, y = weekly_cases, color = "Weekly cases")) +  # Plot weekly cases
  geom_line(aes(x = data, y = weekly_deaths * 215, color = 'Weekly deaths')) +  # Plot weekly deaths (scaled for comparison)
  scale_y_continuous(labels = scales::comma, name = "Weekly cases", breaks = seq(0, 1400000, 200000),
                     limits = c(0, 1400000),
                     sec.axis = sec_axis(~./215, name="Weekly deaths", labels = scales::comma, 
                                         breaks = seq(0, 8000, 1000))) +  # Secondary y-axis for deaths
  scale_x_date(date_breaks = "1 month", date_minor_breaks = "1 week",
               date_labels = "%B %Y") +  # Set x-axis to display months
  ggtitle("Weekly registered COVID-19 cases and deaths in Brazil since first VOC Omicron identification") +
  theme_classic() +
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 16),
        plot.title = element_text(size = 20),
        legend.text = element_text(size = 12),
        axis.title.x = element_blank(),  # Remove x-axis title
        legend.title = element_blank())  # Remove legend title

# Save the weekly cases and deaths plot as a PNG file
ggsave("Brazil_weekly_cases_deaths.png", plot = p_BR_weekly, dpi = 600, height = 9, width = 14)


# Create a stream plot of VOC (variants of concern) distribution over time
col = sample(col_vector, 11)  # Sample 11 colors from the color vector
stream_voc_weekly <- ggplot(gisaid_nextClade_weekly) +
  geom_stream(type = "proportional", aes(x = week, y = n, fill = Nextstrain_clade), bw = 1) +  # Proportional stream plot
  scale_fill_manual(values = col) +  # Manually assign colors to the clades
  theme_classic() +
  scale_x_date(date_breaks = "1 month", date_labels = "%B %Y") +  # Set x-axis date labels
  scale_y_continuous(labels = scales::percent) +  # Set y-axis to percentages
  labs(title = "Temporal distribution of SARS-CoV-2 VOCs", x = "", y = "Percentage", fill = "VOC") +
  theme(axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14),
        axis.text = element_text(size = 10),
        plot.title = element_text(hjust = 0.5, size = 16),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10))

# Save the VOC distribution stream plot as a PNG file
ggsave("Brazil_weekly_VOC_distribution.png", plot = stream_voc_weekly, dpi = 600, height = 9, width = 14)


# Plot weekly cases as a simple line plot
line <- ggplot(brasil_cases_weekly) +
  geom_line(aes(x = week, y = weekly_cases)) +  # Line plot of weekly cases
  scale_y_continuous(position = "right", labels = scales::comma, name = "Weekly cases", breaks = seq(0, 1400000, 200000),
                     limits = c(0, 1400000)) +  # Set y-axis limits and breaks
  scale_x_date(date_breaks = "1 month", date_minor_breaks = "1 week",
               date_labels = "%B %Y") +  # Set x-axis date labels
  theme_classic() +
  labs(title = "", x = "", y = "Number of cases") +
  theme(axis.title.y = element_text(size = 14),
        axis.text = element_text(size = 10),
        plot.title = element_text(hjust = 0.5, size = 16),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10),
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank())  # Remove x-axis labels and ticks for a clean look

# Make the background of the line plot transparent
p <- line + theme(rect = element_rect(fill = "transparent"))
p <- p + theme(
    panel.background = element_rect(fill = "transparent"),  # Make panel background transparent
    plot.background = element_rect(fill = "transparent", color = NA),  # Make plot background transparent
    panel.grid.major = element_blank(),  # Remove major grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    legend.background = element_rect(fill = "transparent"),  # Make legend background transparent
    legend.box.background = element_rect(fill = "transparent"))  # Make legend box background transparent

# Save the line plot with transparency as a PNG file
ggsave("Brazil_weekly_cases_overlay.png", plot = p, dpi = 600, height = 9, width = 14)

# Combine the stream plot and line plot into one figure
p2 <- stream_voc_weekly + line
