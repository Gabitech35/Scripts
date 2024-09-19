######### Power Analysis Plot #########

## Install required packages if not already installed

# Define a vector of required packages
pacotes <- c("plotly", "kableExtra", "ggplot2", "tidyr", "dplyr",
             "lubridate", "stringr", "gridExtra", "grid")

# Check if any of the required packages are not installed
if(sum(as.numeric(!pacotes %in% installed.packages())) != 0){
  # Identify which packages are missing
  instalador <- pacotes[!pacotes %in% installed.packages()]
  # Install missing packages
  for(i in 1:length(instalador)) {
    install.packages(instalador, dependencies = T)
    break()}  # Only install one package at a time
  # Load the required packages
  sapply(pacotes, require, character = T) 
} else {
  # If all packages are already installed, simply load them
  sapply(pacotes, require, character = T) 
}

### Set the working directory where files will be saved
setwd("/home/gabriela/Documentos/REDE_influenza/SOLICITACOES/IGOR/Figuras_PSP/")

# Verify the current working directory
getwd()

# Load the CSV file containing the data for the power analysis plot
d1 <- read.csv(file = "dataset_poder_amostral_2_abr_dez.csv", header = T, sep = ';')

# Create a bar plot showing the quantity of positives by UPA
bar <- ggplot(data = d1, aes(x = UPA, y = Positivos, fill = UPA)) +
  geom_bar(stat = "identity") +  # Use bars to represent quantities
  geom_text(aes(label = paste0(round(Positivos / sum(Positivos) * 100, 1), "%")), # Add percentage labels on bars
            position = position_stack(vjust = 0.5), size = 6, color = "black") +
  scale_y_continuous(position = "left", name = "Quantities of positives", breaks = seq(0, max(d1$Positivos), by = 50)) + # Customize y-axis
  labs(title = "Results of sequenced samples from UPAs from Apr to Dec (2023)", x = "UPAs") + # Add title and x-axis label
  theme(
    axis.title = element_text(size = 16), # Increase axis title font size
    axis.text = element_text(size = 16)   # Increase axis label font size
  ) +
  scale_fill_manual(
    values = c(
      "Butantan" = "#8dd3c7",
      "Jacana" = "#ffffb3",
      "Maria Antonieta" = "#bebada",
      "Tatuape" = "#fb8072",
      "Tito Lopes" = "#80b1d3",
      "Vergueiro" = "#fdb462"
    ),
    name = ""
  )

# Modify the appearance of the plot
bar2 <- bar + theme(rect = element_rect(fill = "transparent")) # Set background to transparent
bar2 <- bar2 +
  theme(
    panel.background = element_rect(fill = "#f0f0f0", color = NA), # Set panel background color
    plot.background = element_rect(fill = "transparent", color = NA), # Set plot background color
    #panel.grid.major = element_blank(), # Uncomment to remove major grid lines
    #panel.grid.minor = element_blank(), # Uncomment to remove minor grid lines
    legend.background = element_rect(fill = "transparent") # Set legend background to transparent
  )
bar2

# Save the bar plot as a PDF file
ggsave("Figura3_casos_posivos_poder_amostral_abr_to_dez.pdf", bar2, width = 16, height = 9, units = "in", dpi = 400)

###################### Power Analysis Plot 2 ##########################

# Load the CSV file containing the data for the second power analysis plot
d2 <- read.csv(file = "dataset_poder_amostral.csv", header = T, sep = '\t')

# Transform the data into a long format for plotting
d2_long <- d2 %>%
  pivot_longer(cols = c(Realizado, Esperado),
               names_to = "Tipo",
               values_to = "Valor")

# Create a bar plot comparing expected vs. actual sample quantities
bar2 <- ggplot(d2_long, aes(x = UPA, y = Valor, fill = Tipo)) +
  geom_col(position = "dodge") + # Create grouped bars for expected and actual values
  labs(title = "Expected vs. Actual Sample Quantities in UPA",
       y = "Quantities",
       fill = "") + # Add labels and legend title
  theme_minimal() + # Use a minimal theme for the plot
  theme(legend.position = "top", # Place legend at the top
        plot.title = element_text(hjust = 0.5, size = 16)) + # Center title and set font size
  scale_fill_manual(values = c("#e78ac3", "#8da0cb")) # Define colors for expected and actual values

bar2

# Create a bar plot showing the difference between expected and actual values
dif <- ggplot(d2, aes(x = UPA, y = Diferença, fill = Diferença > 0)) +
  geom_bar(stat = "identity", position = "dodge") + # Create bars to show difference
  geom_text(aes(label = Diferença), vjust = -0.5, position = position_dodge(width = 0.9)) + # Add labels on bars
  labs(title = "Discrepancy Between Expected and Actual Values in UPA",
       x = "UPA",
       y = "Difference in Values") + # Add labels and title
  scale_fill_manual(values = c("#fb9a99", "#b2df8a")) + # Define colors for positive and negative differences
  theme_minimal() + # Use a minimal theme for the plot
  theme(legend.position = "top", # Place legend at the top
        plot.title = element_text(hjust = 0.5, size = 16)) # Center title and set font size

dif

# Combine all plots into one
combined_plot <- grid.arrange(bar2, dif, ncol = 2) # Arrange plots side by side

# Save the combined plot as a PDF file
ggsave("Figura3_poder_amostral.pdf", combined_plot, width = 16, height = 9, units = "in", dpi = 400)
