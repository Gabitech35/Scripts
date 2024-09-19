## Install required packages

# List of required packages
pacotes <- c("plotly", "tidyverse", "knitr", "kableExtra", "cowplot", "ggplot2",
             "dplyr", "lubridate", "tidyverse")

# Check if any of the required packages are not installed
if(sum(as.numeric(!pacotes %in% installed.packages())) != 0){
  # Get the names of packages that are not yet installed
  instalador <- pacotes[!pacotes %in% installed.packages()]
  
  # Install each missing package
  for(i in 1:length(instalador)) {
    install.packages(instalador, dependencies = TRUE) # Install packages with dependencies
    break()  # Break after installing the first package (to avoid multiple installations in this loop)
  }
  
  # Load all required packages
  sapply(pacotes, require, character.only = TRUE) 
} else {
  # If all packages are already installed, just load them
  sapply(pacotes, require, character.only = TRUE) 
}

### Set working directory for saving and loading files
setwd("/home/gabriela/Documentos/CEVIVAS_COV/Solicitações/ARTIGO_REDE/")

# Verify and display the current working directory
getwd()

# Load data from CSV files
d1 <- read.csv(file = "dados_figura2A.csv", header = TRUE, sep = ';')
d2 <- read.csv(file = "dados_figura2A_qnd_amostra.csv", header = TRUE, sep = ';')

# Set locale to English for proper date formatting
Sys.setlocale("LC_TIME", "en_US.UTF-8")

# Convert 'Mes_ano' column to Date type by appending "-01" to the month-year string
str(d1$Mes_ano) 
d1$Mes_ano <- as.Date(paste(d1$Mes_ano, "-01", sep=""))

str(d2$Mes_ano) 
d2$Mes_ano <- as.Date(paste(d2$Mes_ano, "-01", sep=""))

# Convert columns to numeric type if needed (commented out as it might not be required)
str(d1$Media_poder_amostra_por_Mes) 
# d1$Media_poder_amostra_por_Mes <- as.numeric(d1$Media_poder_amostra_por_Mes)

str(d2$Quantidade_de_amostras_por_mes) 

# Create a line plot for the data in 'd1'
line <- ggplot(d1) +
  geom_line(aes(x = Mes_ano, y = Media_poder_amostra_por_Mes)) +  # Plot line graph
  scale_y_continuous(position = "right",  # Set position and formatting for y-axis
                     name = "Sample Power (%)", 
                     labels = function(x) paste0(x * 1, '%')) +
  scale_x_date(date_breaks = "1 month",   # Set x-axis breaks and labels for date
               date_minor_breaks = "1 week",
               date_labels = "%B %Y") + theme_classic() +  # Apply classic theme
  labs(title = "", x= "", y = "") +  # Set plot labels
  theme(
    # Customizing theme elements
    # axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 16),
    axis.text = element_text(size = 12),
    plot.title = element_text(hjust = 0.5, size = 16),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10),
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank()
  )
line  # Display the line plot

# Customize the appearance of the line plot
p <- line + theme(rect = element_rect(fill = "transparent"))  # Set background of plot elements to transparent
p <- p +
  theme(
    panel.background = element_rect(fill = "transparent"), # Background of the panel
    plot.background = element_rect(fill = "transparent", color = NA), # Background of the plot
    panel.grid.major = element_blank(), # Remove major grid lines
    panel.grid.minor = element_blank(), # Remove minor grid lines
    legend.background = element_rect(fill = "transparent"), # Background of the legend
    legend.box.background = element_rect(fill = "transparent") # Background of the legend box
  )
p  # Display the customized line plot

# Create a bar plot for the data in 'd2'
bar <- ggplot(data=d2, aes(x= Mes_ano, y= Quantidade_de_amostras_por_mes)) +
  geom_bar(stat="identity", fill= "#B5EAD6") +  # Plot bar graph with specific fill color
  scale_y_continuous(position = "left",  # Set position and formatting for y-axis
                     name = "Number of Samples") +
  scale_x_date(date_breaks = "1 month",  # Set x-axis breaks and labels for date
               date_minor_breaks = "1 week",
               date_labels = "%B %Y") + theme_classic() +  # Apply classic theme
  labs(title = "", x= "Month/Year") +  # Set plot labels
  theme(
    axis.title.x = element_text(size = 16),
    axis.title.y = element_text(size = 16),
    axis.text.x = element_text(angle = 90),  # Rotate x-axis labels for readability
    axis.text = element_text(size = 13)
  )
bar  # Display the bar plot

# Customize the appearance of the bar plot
q <- bar + theme(rect = element_rect(fill = "transparent"))  # Set background of plot elements to transparent
q <- q +
  theme(
    panel.background = element_rect(fill = "transparent"), # Background of the panel
    plot.background = element_rect(fill = "transparent", color = NA), # Background of the plot
    panel.grid.major = element_blank(), # Remove major grid lines
    panel.grid.minor = element_blank(), # Remove minor grid lines
    legend.background = element_rect(fill = "transparent"), # Background of the legend
    legend.box.background = element_rect(fill = "transparent") # Background of the legend box
  )
q  # Display the customized bar plot
