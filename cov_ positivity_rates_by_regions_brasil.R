## Installing necessary packages

# List of required packages
pacotes <- c("plotly","tidyverse","knitr","kableExtra","cowplot", "ggplot2","dplyr", "lubridate", "tidyverse")

# Check if the packages are already installed
if(sum(as.numeric(!pacotes %in% installed.packages())) != 0){
  # Install packages that are not yet installed
  instalador <- pacotes[!pacotes %in% installed.packages()]
  for(i in 1:length(instalador)) {
    # Install missing packages
    install.packages(instalador, dependencies = T)
    break()}
  # Load all packages after installation
  sapply(pacotes, require, character = T) 
} else {
  # Load all packages if already installed
  sapply(pacotes, require, character = T) 
}

# Function to load/install multiple packages
ipak <- function(pkg){
  # Identify packages that are not installed
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  # Install missing packages if necessary
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  # Load all packages
  sapply(pkg, require, character.only = TRUE)
}

# List of required packages
packages <- c("plotly","tidyverse","knitr","kableExtra","cowplot", "ggplot2","dplyr", "lubridate", "tidyverse")
# Use ipak function to ensure packages are loaded/installed
ipak(pacotes)

### Set working directory
setwd("/home/gabriela/Documentos/CEVIVAS_COV/Solicitações/Paper_covid/positividade/")

## Print the current working directory
getwd()

# Load CSV files for metadata from 2021 and 2022
metadata_2021 <-read.csv(file = "INFLUD21-21-11-2022.csv", header = T, sep = ';')
metadata_2022 <-read.csv(file = "INFLUD22-21-11-2022.csv", header = T, sep = ';')

# Preview the 'CLASSI_FIN' and 'DT_COLETA' columns of the metadata
head(metadata_2021$CLASSI_FIN)
head(metadata_2021$DT_COLETA)

head(metadata_2022$CLASSI_FIN)
head(metadata_2022$DT_COLETA)

# Check the data types of 'DT_COLETA' and 'CLASSI_FIN'
str(metadata_2021$DT_COLETA) # Needs to be converted to date format
str(metadata_2021$CLASSI_FIN) # This is already correct

str(metadata_2022$DT_COLETA) # Needs to be converted to date format
str(metadata_2022$CLASSI_FIN) # This is correct

# Select only the 'DT_COLETA' and 'CLASSI_FIN' columns from both datasets
meta_2021 = metadata_2021[,c("DT_COLETA", "CLASSI_FIN")]
meta_2022 = metadata_2022[,c("DT_COLETA", "CLASSI_FIN")]

# Filter the data to include only COVID-19 cases (classified as '5')
meta_2021_2 = meta_2021[meta_2021$CLASSI_FIN %in% c("5"), ]
meta_2022_2 = meta_2022[meta_2022$CLASSI_FIN %in% c("5"), ]

# Convert 'DT_COLETA' column to date format
meta_2021_2$DT_COLETA_NEW <- as.Date(meta_2021_2$DT_COLETA, format = "%d/%m/%Y")
str(meta_2021_2$DT_COLETA_NEW) 

meta_2022_2$DT_COLETA_NEW <- as.Date(meta_2022_2$DT_COLETA, format = "%d/%m/%Y")
str(meta_2022_2$DT_COLETA_NEW) 

# Select relevant columns and remove rows with missing data
meta_2021_col = meta_2021_2[,c(2,3)] %>% drop_na()
meta_2022_col = meta_2022_2[,c(2,3)] %>% drop_na()

# Combine 2021 and 2022 data
positividade_data <- rbind(meta_2021_col, meta_2022_col)

# Filter the data for a specific date range
positividade_data <- positividade_data %>% filter(between(DT_COLETA_NEW, as.Date('2021-11-25'), as.Date('2022-11-13')))

# Group data by week and calculate the count of cases
positividade_group <- positividade_data %>% group_by(week = cut(DT_COLETA_NEW, "week"), CLASSI_FIN) %>% tally()

# Separate SRA data for 2021 and 2022
p1_sra_2021 = metadata_2021[,c("DT_COLETA", "CLASSI_FIN")] 
p1_sra_2022 = metadata_2022[,c("DT_COLETA", "CLASSI_FIN")]

# Convert the collection date to date format
p1_sra_2021$DT_COLETA_NEW <- as.Date(p1_sra_2021$DT_COLETA, format = "%d/%m/%Y")
str(p1_sra_2021$DT_COLETA_NEW) 

p1_sra_2022$DT_COLETA_NEW <- as.Date(p1_sra_2022$DT_COLETA, format = "%d/%m/%Y")
str(p1_sra_2022$DT_COLETA_NEW) 

# Remove rows with missing values
p1_sra_2021 = na.omit(p1_sra_2021)
p1_sra_2022 = na.omit(p1_sra_2022)

# Select the relevant columns and filter by date range
p1_sra_2021 = p1_sra_2021[,c("DT_COLETA_NEW", "CLASSI_FIN")] %>% filter(between(DT_COLETA_NEW, as.Date('2021-11-25'), as.Date('2022-11-13')))
p1_sra_2022 = p1_sra_2022[,c("DT_COLETA_NEW", "CLASSI_FIN")] %>% filter(between(DT_COLETA_NEW, as.Date('2021-11-25'), as.Date('2022-11-13')))

# Combine the SRA data from 2021 and 2022
all_sra <- rbind(p1_sra_2021, p1_sra_2022) 
str(all_sra)

# Group the combined SRA data by week and count the cases
all_sra2 <- all_sra %>% group_by(week = cut(DT_COLETA_NEW, "week"), CLASSI_FIN) %>% tally()

# Calculate the total number of tests per week
all_sra3 <- all_sra2 %>% group_by(week) %>%
  mutate(testes_total= sum(n))

# Merge COVID positivity data with total tests by week
join_positividade_group_all_sra3 <- left_join(positividade_group, all_sra3, by = "week")

# Calculate positivity score (positive cases / total tests)
join_positividade_group_all_sra3$score_percen = (join_positividade_group_all_sra3$n.x/join_positividade_group_all_sra3$testes_total)

# Convert 'week' to Date format for plotting
join_positividade_group_all_sra3$week = as.Date(join_positividade_group_all_sra3$week)
str(join_positividade_group_all_sra3)

# Save the combined data to a CSV file
write.csv(join_positividade_group_all_sra3,"positividade_SRA.csv", row.names = FALSE)

# Plot the positivity rate over time
line <- ggplot(join_positividade_group_all_sra3) +
  geom_line(aes(x = week, y = score_percen)) +
  scale_y_continuous(position = "right", labels = scales::percent, name = "Percent rate") +
  scale_x_date(date_breaks = "1 month", date_minor_breaks = "1 week",
               date_labels = "%B %Y") + theme_classic() +
  labs(title = "",x= "" , y = "Number of cases") + 
  theme(
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

# Modify plot to make background transparent
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

# Save plot as PNG with transparent background
ggsave("test.png",  plot= p, bg = "transparent", dpi=300, width = 8, height = 4)
