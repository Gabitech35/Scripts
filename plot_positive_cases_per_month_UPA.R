##### Plotting the Percentage of Positive Cases by Month #####

## Install required packages if not already installed

# Define a vector of required packages
pacotes <- c("plotly", "kableExtra", "ggplot2", "tidyr", "dplyr",
             "lubridate", "stringr", "gridExtra", "grid", "reshape2")

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
setwd("/home/gabriela/Documentos/REDE_influenza/SOLICITACOES/IGOR/Figuras_PSP/CLADES_AGRUPADO_GRAFICO_LINHAS/")

# Verify the current working directory
getwd()

# Load the CSV file containing the data
d1 <- read.csv(file = "DF-agrupados_clados_oficial.csv", header = T, sep = ',')

# Calculate the total number of samples for each UPA
d1$total <- rowSums(d1[, -1])

# Convert the sample counts to percentages
df_porcentagem <- d1[, -c(1, ncol(d1))] / d1$total * 100

# Add the UPA column back to the data
df_porcentagem <- cbind(UPA = d1$UPA, df_porcentagem)

# Transform the dataframe to a long format for easier plotting
df_long <- melt(df_porcentagem, id.vars = "UPA", 
                variable.name = "Mes", value.name = "Porcentagem")

# Define custom colors for each UPA
cores <- c("BUTANTAN" = "#1b9e77",
           "JACANA" = "#d95f02",
           "MARIA ANTONIETA" = "#7570b3",
           "TATUAPE" = "#e7298a",
           "TITO LOPES" = "#66a61e",
           "VERGUEIRO" = "#1f78b4")

# Plot the line graph showing the percentage of sequenced samples by month
plot <- ggplot(df_long, aes(x = Mes, y = Porcentagem, color = UPA, group = UPA)) +
  geom_line(linewidth = 0.8) + # Increase line width for better visibility
  labs(x = "", y = "Sequenced Sample (%)", color = "UPA") + # Set axis labels and legend title
  scale_color_manual(values = cores) + # Use custom colors for the UPA lines
  theme_minimal() + # Use a minimal theme for the plot
  theme(
    axis.title = element_text(size = 12), # Set font size for axis titles
    axis.text = element_text(size = 12), # Set font size for axis labels
    axis.text.x = element_text(angle = 45, hjust = 1), # Rotate x-axis labels 45 degrees
    axis.title.y = element_text(size = 14) # Increase font size for y-axis title
  ) +
  scale_y_continuous(breaks = seq(0, 100, by = 10)) # Set y-axis breaks

# Display the plot
plot 

# Save the plot as a PDF file
ggsave("Positive_cases_per_month_SEQ.pdf", plot, width = 10, height = 6, units = "in", dpi = 400)
