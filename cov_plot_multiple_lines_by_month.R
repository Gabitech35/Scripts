## Install necessary packages
pacotes <- c("plotly", "tidyverse", "knitr", "kableExtra", "cowplot", "ggplot2",  # List of required packages
             "dplyr", "lubridate", "tidyverse")

# Check if the required packages are installed; if not, install them
if(sum(as.numeric(!pacotes %in% installed.packages())) != 0){  # If any package is missing
  instalador <- pacotes[!pacotes %in% installed.packages()]  # Identify the missing packages
  for(i in 1:length(instalador)) {  # Loop through missing packages
    install.packages(instalador, dependencies = T)  # Install the missing packages with dependencies
    break()}  # Install first missing package and break (minor optimization)
  sapply(pacotes, require, character = T)  # Load all required packages
} else {
  sapply(pacotes, require, character = T)  # If all packages are installed, just load them
}

### Set working directory to save output files
setwd("/home/gabriela/Documentos/CEVIVAS_COV/Solicitações/ARTIGO_REDE/")  # Path where files will be saved

getwd()  # Verify the current working directory

# Load the datasets from CSV files
br <- read.csv(file = "All_brasil_2021_2022_MENOS_IB.csv", header = T, sep = ',')  # Load the data for other Brazilian labs
ib <- read.csv(file = "All_IB.csv", header = T, sep = ',')  # Load the data for Butantan Institute

# Select the relevant columns from both datasets (assumed columns of interest are 3, 5, 7-9, 21, 27)
br_sel = br[,c(3,5,7:9,21,27)]  # Select specific columns from the Brazil data
ib_sel = ib[,c(3,5,7:9,21,27)]  # Select specific columns from the Butantan data

# Convert the 'date' and 'date_submitted' columns to Date format using 'lubridate'
str(ib_sel$date)  # Check the structure of 'date' column

# Convert 'date' columns to Date format
ib_sel$date_coleta_new <- ymd(ib_sel$date)  # Convert Butantan 'date' to Date
br_sel$date_coleta_new <- ymd(br_sel$date)  # Convert Brazil 'date' to Date

# Convert 'date_submitted' columns to Date format
ib_sel$date_submitted_new <- ymd(ib_sel$date_submitted)  # Convert Butantan 'date_submitted' to Date
br_sel$date_submitted_new <- ymd(br_sel$date_submitted)  # Convert Brazil 'date_submitted' to Date

# Calculate the difference between 'date_submitted' and 'date_coleta' (in days)
ib_sel$diff_times = difftime(ib_sel$date_submitted_new, ib_sel$date_coleta_new, units = "days")  # Calculate time difference for Butantan
br_sel$diff_times = difftime(br_sel$date_submitted_new, br_sel$date_coleta_new, units = "days")  # Calculate time difference for Brazil labs

# Filter the data to only include sequences collected between 2021-04-01 and 2022-06-30
ib_sel2 = subset(ib_sel, date > "2021-04-01" & date < "2022-06-30")  # Filter Butantan data
br_sel2 = subset(br_sel, date > "2021-04-01" & date < "2022-06-30")  # Filter Brazil labs data

# Remove entries where the time difference is less than 8 days
ib_sel_removed <- ib_sel2[!(ib_sel2$diff_times < 8),]  # Remove Butantan data with time difference < 8 days
ib_sel_removed  # Display the cleaned Butantan dataset

# Group the cleaned Butantan data by month and calculate the average time difference for each month
ib_sel_month_group <- ib_sel_removed %>%
  group_by(month = cut(date_coleta_new, "month")) %>%  # Group by month
  summarise_at(vars(diff_times), list(mean_deposit_time = mean))  # Calculate the mean time difference

# Convert the 'month' column to Date format for easier plotting
ib_sel_month_group$month = as.Date(ib_sel_month_group$month)

# Repeat the same process for the Brazil dataset (group by month and calculate average time difference)
br_sel_month_group <- br_sel2 %>%
  group_by(month = cut(date_coleta_new, "month")) %>%
  summarise_at(vars(diff_times), list(mean_deposit_time = mean))

# Convert the 'month' column to Date format for the Brazil data
br_sel_month_group$month = as.Date(br_sel_month_group$month)

#################################################
# Test section to summarize and display Butantan data time differences
teste = as.numeric(ib_sel_removed$diff_times)  # Convert the time differences to numeric
summary(teste)  # Display summary statistics of time differences
#################################################

# Add a column to indicate the source (Butantan or other labs)
br_sel_month_group$Origem_deposito = "Other Laboratories in Brazil"  # Label Brazil labs data
ib_sel_month_group$Origem_deposito = "Butantan Institute"  # Label Butantan data

# Combine both datasets into a single dataframe
all_date_month_group = rbind(br_sel_month_group, ib_sel_month_group)  # Merge Butantan and Brazil labs data

# Convert the mean time difference to integer for better display in plots
all_date_month_group$mean_deposit_time = as.integer(all_date_month_group$mean_deposit_time)
str(all_date_month_group$mean_deposit_time)  # Check the structure of the mean time difference column

# Plot the time difference over time for both Butantan and Brazil labs
line <- ggplot(all_date_month_group, aes(x = month, y = mean_deposit_time, group = Origem_deposito, color = Origem_deposito)) + 
  geom_line() +  # Add a line plot
  scale_x_date(date_breaks = "1 month",  # Set x-axis to display months
               date_labels = "%B %Y") +  # Format x-axis labels as month-year
  labs(title = "",  # Title of the plot
       x = "Month/Year", y = "Time elapsed from sample collection\nto GISAID submission (days)",  # Axis labels
       color = "Deposit Origin") +  # Legend title
  theme_classic() +  # Use classic theme
  scale_y_continuous(limits = c(0,180), breaks = seq(0,180, by = 20)) +  # Set y-axis limits and breaks
  theme(
    axis.title.x = element_text(size = 16),  # Customize x-axis title size
    axis.title.y = element_text(size = 16),  # Customize y-axis title size
    axis.text = element_text(size = 13),  # Customize axis label text size
    plot.title = element_text(hjust = 0.5, size = 20),  # Center and size the plot title
    legend.title = element_text(size = 18),  # Customize legend title size
    legend.text = element_text(size = 14),  # Customize legend text size
    legend.position = c(0.8, 0.9),  # Position the legend inside the plot
    axis.text.x = element_text(angle = 90, vjust = 0.5)  # Rotate x-axis text for readability
  )

line  # Display the plot

# Modify the plot to have a transparent background
p <- line + theme(rect = element_rect(fill = "transparent"))  # Make background transparent for the rectangle
p <- p +
  theme(
    panel.background = element_rect(fill = "transparent"),  # Make panel background transparent
    plot.background = element_rect(fill = "transparent", color = NA),  # Make plot background transparent
    panel.grid.major = element_blank(),  # Remove major grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    legend.background = element_rect(fill = "transparent"),  # Make legend background transparent
    legend.box.background = element_rect(fill = "transparent")  # Make legend panel background transparent
  )

p  # Display the modified plot

# Save the final plot as a PNG image with a resolution of 600 DPI
ggsave("deposit_gisaid_time_Figure2C.png", plot = line, dpi = 600, height = 8, width = 12)
