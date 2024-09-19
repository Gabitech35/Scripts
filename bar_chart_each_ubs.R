## Installing required packages

# Define a vector with the names of the packages to be installed
packages <- c("plotly", "tidyverse", "kableExtra", "ggplot2", "tidyr", "dplyr",
               "lubridate", "stringr", "gridExtra", "grid")

# Check if any of the packages are not installed
if (sum(as.numeric(!packages %in% installed.packages())) != 0) {
  # Identify packages that need to be installed
  to_install <- packages[!packages %in% installed.packages()]
  
  # Install each package that is not already installed
  for (i in 1:length(to_install)) {
    install.packages(to_install, dependencies = TRUE)
    break() # Ensure that only one package is installed per iteration
  }
  
  # Load all packages
  sapply(packages, require, character.only = TRUE)
} else {
  # If all packages are already installed, just load them
  sapply(packages, require, character.only = TRUE)
}

### Set the working directory where the files will be saved
setwd("/home/gabriela/Documentos/REDE_influenza/SOLICITACOES/IGOR/Figuras_PSP/")

# Display the current working directory
getwd()

# Load the CSV file into a data frame
d1 <- read.csv(file = "BASE_UPAS_Taina_31012024.csv", header = TRUE, sep = ';')

# Select the relevant columns from the data frame
d1_sel_B <- select(d1, UBS, RESULT_INF_B)

# Split the data frame into a list of data frames based on the 'UBS' column
list_FLUB_UBS <- split(d1_sel_B, d1_sel_B$UBS)

# Define names for the new data frames
list_names <- c("FA_UPA1", "FA_UPA2", "FA_UPA3", "FA_UPA4", "FA_UPA5", "FA_UPA6")

# Function to save data frames into the global environment with specified names
save_data_frames <- function(list, names) {
  for (i in seq_along(list)) {
    # Assign each data frame to a name in the global environment
    assign(names[i], list[[i]], envir = .GlobalEnv)
    print(paste("Data frame for FA_UPA =", names[i]))
    print(list[[i]])
    cat("\n")
  }
}

# Execute the function to save the data frames
save_data_frames(list_FLUB_UBS, list_names)

# Mapping of UBS names
ubs_names <- c("Butantan", "Jacana", "Maria Antonieta", "Tatuape", "Tito Lopes", "Vergueiro")

# Words to be counted in the RESULT_INF_B column
search_words <- c("NOT-DETECTABLE", "DETECTABLE", "INCONCLUSIVE")

# Initialize a list to store results for each UBS
results_per_ubs <- list()

# Loop through each UBS to calculate and store results
for (i in 1:6) {
  column_name <- paste("FA_UPA", i, sep="")
  
  # Check if the data frame exists in the global environment
  if (exists(column_name, envir = .GlobalEnv)) {
    
    # Get the current UBS name
    current_ubs_name <- ubs_names[i]
    
    # Calculate the count of each search word and create a new data frame
    temp_result <- get(column_name, envir = .GlobalEnv) %>%
      group_by(RESULT_INF_B) %>%
      summarise(count = sum(grepl(str_c(search_words, collapse = "|"), 
                                  RESULT_INF_B), na.rm = TRUE)) %>%
      mutate(UBS = current_ubs_name)
    
    # Add the data frame to the results list
    results_per_ubs[[current_ubs_name]] <- temp_result
    
    # Save the result data frame to the global environment
    assign(paste("result_", current_ubs_name, sep = ""), temp_result, 
           envir = .GlobalEnv)
  } else {
    cat(paste("Column", column_name, "not found in the global environment.\n\n"))
  }
}

# Display the results data frames
for (ubs_name in ubs_names) {
  cat(paste("Results for", ubs_name, ":\n"))
  print(results_per_ubs[[ubs_name]])
  cat("\n")
}

# Remove the first row from each result data frame
result_Jacana <- result_Jacana %>%
  slice(-1)

`result_Maria Antonieta` <- `result_Maria Antonieta` %>%
  slice(-1)

result_Tatuape <- result_Tatuape %>%
  slice(-1)

`result_Tito Lopes` <- `result_Tito Lopes` %>%
  slice(-1)

result_Vergueiro <- result_Vergueiro %>%
  slice(-1)

# Plot the bar chart for UBS Jacana
bar_ja <- ggplot(data = result_Jacana, aes(x = RESULT_INF_B, y = count, 
                                           fill = RESULT_INF_B)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = scales::percent(count/sum(count))), 
            position = position_stack(vjust = 0.5), 
            size = 4, 
            color = "black") +
  scale_y_continuous(position = "left", name = "Number of cases") +
  labs(title = "UBS Jaçanã", x = "Result of Influenza B") +
  theme(
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 13)
  ) +
  scale_fill_manual(
    values = c(
      "DETECTABLE" = "#b2df8a",
      "INCONCLUSIVE" = "#a6cee3",
      "NOT-DETECTABLE" = "#1f78b4"
    ),
    name = ""
  )

# Customize the plot appearance for UBS Jacana
jacana <- bar_ja + theme(rect = element_rect(fill = "transparent"))
jacana <- jacana +
  theme(
    panel.background = element_rect(fill = "#f0f0f0", color = NA), # Light color for panel background
    plot.background = element_rect(fill = "transparent", color = NA), # Transparent background for the plot
    legend.background = element_rect(fill = "transparent") # Transparent legend background
  )
jacana

# Plot the bar chart for UBS Butantan
bar_bu <- ggplot(data = result_Butantan, aes(x = RESULT_INF_B, y = count, fill = RESULT_INF_B)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = scales::percent(count/sum(count))), 
            position = position_stack(vjust = 0.5), 
            size = 4, 
            color = "black") +
  scale_y_continuous(position = "left", name = "Number of cases") +
  labs(title = "UBS Butantã", x = "Result of Influenza B") +
  theme(
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 13)
  ) +
  scale_fill_manual(
    values = c(
      "DETECTABLE" = "#b2df8a",
      "INCONCLUSIVE" = "#a6cee3",
      "NOT-DETECTABLE" = "#1f78b4"
    ),
    name = ""
  )

# Customize the plot appearance for UBS Butantan
butantan <- bar_bu + theme(rect = element_rect(fill = "transparent"))
butantan <- butantan +
  theme(
    panel.background = element_rect(fill = "#f0f0f0", color = NA), # Light color for panel background
    plot.background = element_rect(fill = "transparent", color = NA), # Transparent background for the plot
    legend.background = element_rect(fill = "transparent") # Transparent legend background
  )
butantan

# Plot the bar chart for UBS Maria Antonieta
bar_ma <- ggplot(data = `result_Maria Antonieta`, aes(x = RESULT_INF_B, y = count, fill = RESULT_INF_B)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = scales::percent(count/sum(count))), 
            position = position_stack(vjust = 0.5), 
            size = 4, 
            color = "black") +
  scale_y_continuous(position = "left", name = "Number of cases") +
  labs(title = "UBS Maria Antonieta", x = "Result of Influenza B") +
  theme(
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 13)
  ) +
  scale_fill_manual(
    values = c(
      "DETECTABLE" = "#b2df8a",
      "INCONCLUSIVE" = "#a6cee3",
      "NOT-DETECTABLE" = "#1f78b4"
    ),
    name = ""
  )

# Customize the plot appearance for UBS Maria Antonieta
M_antonieta <- bar_ma + theme(rect = element_rect(fill = "transparent"))
M_antonieta <- M_antonieta +
  theme(
    panel.background = element_rect(fill = "#f0f0f0", color = NA), # Light color for panel background
    plot.background = element_rect(fill = "transparent", color = NA), # Transparent background for the plot
    legend.background = element_rect(fill = "transparent") # Transparent legend background
  )
M_antonieta

# Plot the bar chart for UBS Tatuapé
bar_ta <- ggplot(data = result_Tatuape, aes(x = RESULT_INF_B, y = count, fill = RESULT_INF_B)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = scales::percent(count/(570))), 
            position = position_stack(vjust = 0.5), 
            size = 4, 
            color = "black") +
  scale_y_continuous(position = "left", name = "Number of cases") +
  labs(title = "UBS Tatuapé", x = "Result of Influenza B") +
  theme(
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 13)
  ) +
  scale_fill_manual(
    values = c(
      "DETECTABLE" = "#b2df8a",
      "INCONCLUSIVE" = "#a6cee3",
      "NOT-DETECTABLE" = "#1f78b4"
    ),
    name = ""
  )

# Customize the plot appearance for UBS Tatuapé
tatuape <- bar_ta + theme(rect = element_rect(fill = "transparent"))
tatuape <- tatuape +
  theme(
    panel.background = element_rect(fill = "#f0f0f0", color = NA), # Light color for panel background
    plot.background = element_rect(fill = "transparent", color = NA), # Transparent background for the plot
    legend.background = element_rect(fill = "transparent") # Transparent legend background
  )
tatuape

# Plot the bar chart for UBS Tito Lopes
bar_tl <- ggplot(data = `result_Tito Lopes`, aes(x = RESULT_INF_B, y = count, fill = RESULT_INF_B)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = scales::percent(count/sum(count))), 
            position = position_stack(vjust = 0.5), 
            size = 4, 
            color = "black") +
  scale_y_continuous(position = "left", name = "Number of cases") +
  labs(title = "UBS Tito Lopes", x = "Result of Influenza B") +
  theme(
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 13)
  ) +
  scale_fill_manual(
    values = c(
      "DETECTABLE" = "#b2df8a",
      "INCONCLUSIVE" = "#a6cee3",
      "NOT-DETECTABLE" = "#1f78b4"
    ),
    name = ""
  )

# Customize the plot appearance for UBS Tito Lopes
tl <- bar_tl + theme(rect = element_rect(fill = "transparent"))
tl <- tl +
  theme(
    panel.background = element_rect(fill = "#f0f0f0", color = NA), # Light color for panel background
    plot.background = element_rect(fill = "transparent", color = NA), # Transparent background for the plot
    legend.background = element_rect(fill = "transparent") # Transparent legend background
  )
tl

# Plot the bar chart for UBS Vergueiro
bar_ve <- ggplot(data = result_Vergueiro, aes(x = RESULT_INF_B, y = count, fill = RESULT_INF_B)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = scales::percent(count/sum(count))), 
            position = position_stack(vjust = 0.5), 
            size = 4, 
            color = "black") +
  scale_y_continuous(position = "left", name = "Number of cases") +
  labs(title = "UBS Vergueiro", x = "Result of Influenza B") +
  theme(
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 13)
  ) +
  scale_fill_manual(
    values = c(
      "DETECTABLE" = "#b2df8a",
      "INCONCLUSIVE" = "#a6cee3",
      "NOT-DETECTABLE" = "#1f78b4"
    ),
    name = ""
  )

# Customize the plot appearance for UBS Vergueiro
vergueiro <- bar_ve + theme(rect = element_rect(fill = "transparent"))
vergueiro <- vergueiro +
  theme(
    panel.background = element_rect(fill = "#f0f0f0", color = NA), # Light color for panel background
    plot.background = element_rect(fill = "transparent", color = NA), # Transparent background for the plot
    legend.background = element_rect(fill = "transparent") # Transparent legend background
  )
vergueiro

# Combine all plots into a single plot
combined_plot_fluA <- grid.arrange(
  jacana, butantan, M_antonieta,
  tatuape, tl, vergueiro,
  ncol = 2
)

# Save the combined plot as a PDF file
ggsave("Figura2.pdf", combined_plot_fluA, width = 16, height = 9, units = "in", dpi = 400)
