## Install necessary packages
pacotes <- c("plotly", "tidyverse", "knitr", "kableExtra", "cowplot", "ggplot2",
             "dplyr", "lubridate", "tidyverse")  # List of required packages

# Check if the required packages are installed; if not, install them
if(sum(as.numeric(!pacotes %in% installed.packages())) != 0){  # If any package is missing
  instalador <- pacotes[!pacotes %in% installed.packages()]  # Identify the missing packages
  for(i in 1:length(instalador)) {  # Loop through missing packages
    install.packages(instalador, dependencies = T)  # Install the missing packages with dependencies
    break()}  # Break after installing the first missing package (potential optimization)
  sapply(pacotes, require, character = T)  # Load all packages
} else {
  sapply(pacotes, require, character = T)  # If all packages are already installed, load them
}

### Set working directory to save the output files
setwd("/home/gabriela/Documentos/CEVIVAS_COV/Solicitações/ARTIGO_REDE/")  # Set the path where files will be saved

getwd()  # Verify the current working directory

# Load the CSV file with data
ib <- read.csv(file = "dados_figura2B.csv", header = T, sep = ';')  # Read the CSV file with ';' as the delimiter

# Check the structure of the 'data_coleta' and 'data_sequenciamento' columns to confirm they are in the correct format
str(ib$data_coleta)  # Check structure of 'data_coleta' (likely not yet in date format)
str(ib$data_sequenciamento)  # Check structure of 'data_sequenciamento' (likely not yet in date format)

# Convert 'data_coleta' and 'data_sequenciamento' columns to Date format using 'lubridate'
ib$data_coleta_new <- ymd(ib$data_coleta)  # Convert 'data_coleta' to Date
ib$data_sequenciamento_new <- ymd(ib$data_sequenciamento)  # Convert 'data_sequenciamento' to Date

# Verify that the columns are now in Date format
str(ib$data_coleta_new)  # Check new 'data_coleta' structure
str(ib$data_sequenciamento_new)  # Check new 'data_sequenciamento' structure

# Subset the data to only include sequences collected between 2021-04-01 and 2022-06-30
ib_sel = subset(ib, data_coleta_new > "2021-04-01" & data_coleta_new < "2022-06-30")

# Keep only the relevant columns (assuming columns 3 to 5 are of interest)
ib_sel1 = ib_sel[,c(3:5)]  # Select columns 3 to 5

# Check the structure of the 'Intervalo_coleta_sequenciamento' column (this is likely the time between collection and sequencing)
str(ib_sel1$Intervalo_coleta_sequenciamento)

# Group data by month and calculate the mean time between sample collection and sequencing
ib_sel_month_group <- ib_sel1 %>%
  group_by(month = cut(data_coleta_new, "month")) %>%
  summarise_at(vars(Intervalo_coleta_sequenciamento), list(mean_deposit_time = mean))  # Calculate the monthly average

# Convert the 'month' column to Date format for easier plotting
ib_sel_month_group$month = as.Date(ib_sel_month_group$month)

# Check the structure of the 'mean_deposit_time' column to confirm the values
str(ib_sel_month_group$mean_deposit_time)

# Round the mean time (in days) to integers for clarity
ib_sel_month_group$mean_deposit_time_new <- as.integer(ib_sel_month_group$mean_deposit_time)

# Check the structure of the new rounded column
str(ib_sel_month_group$mean_deposit_time_new)

# Set the locale to English for proper date formatting (e.g., month names in plots)
Sys.setlocale("LC_TIME", "en_US.UTF-8")

# Plot the data showing the time between sample collection and sequencing by month
l <- ggplot(ib_sel_month_group, aes(x = month, y = mean_deposit_time_new)) +  # Plot the month on the x-axis and mean time on the y-axis
  geom_line(size = 0.8) +  # Add a line to the plot
  scale_y_continuous(position = "left",  # Y-axis on the left side
                     name = "Time elapsed from sample collection to \nButantan Institute results (days)",  # Label for y-axis
                     limits = c(0, 20), breaks = seq(0, 20, by = 4)) +  # Y-axis scale and breaks
  scale_x_date(date_breaks = "1 month",  # X-axis breaks by month
               date_minor_breaks = "1 week",  # Minor breaks by week
               date_labels = "%B %Y") +  # Format x-axis labels as month-year
  theme_classic() +  # Use classic ggplot theme
  labs(title = "", x = "Month/Year") +  # Label for the x-axis
  theme(axis.title.x = element_text(size = 16),  # Set font size for x-axis title
        axis.title.y = element_text(size = 16),  # Set font size for y-axis title
        axis.text.x = element_text(angle = 90),  # Rotate x-axis text labels for better readability
        axis.text = element_text(size = 13))  # Set font size for axis labels

l  # Display the plot

# Modify the plot to have a transparent background
q <- l + theme(rect = element_rect(fill = "transparent"))  # Make the rectangle background transparent
q <- q + theme(
    panel.background = element_rect(fill = "transparent"),  # Make panel background transparent
    plot.background = element_rect(fill = "transparent", color = NA),  # Make plot background transparent
    panel.grid.major = element_blank(),  # Remove major grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    legend.background = element_rect(fill = "transparent"),  # Make legend background transparent
    legend.box.background = element_rect(fill = "transparent")  # Make legend panel background transparent
  )

q  # Display the modified plot

# Save the plot to a PNG file with a resolution of 600 DPI
ggsave("result_time_cevivas_Figure2B.png", plot = l, dpi = 600, height = 8, width = 12)
