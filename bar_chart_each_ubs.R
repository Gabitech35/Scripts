## Install required packages

# List of required packages
pacotes <- c("plotly", "tidyverse", "kableExtra", "ggplot2", "tidyr", "dplyr",
             "lubridate", "stringr", "gridExtra", "grid")

# Check if any of the required packages are not installed
if(sum(as.numeric(!pacotes %in% installed.packages())) != 0){
  # If not installed, get the names of the packages to install
  instalador <- pacotes[!pacotes %in% installed.packages()]
  # Install the missing packages
  for(i in 1:length(instalador)) {
    install.packages(instalador, dependencies = TRUE)
    break()  # Break the loop after installing the first package
  }
  # Load all required packages
  sapply(pacotes, require, character.only = TRUE) 
} else {
  # If all packages are already installed, just load them
  sapply(pacotes, require, character.only = TRUE) 
}

### Set working directory where files will be saved and loaded
setwd("/home/gabriela/Documentos/REDE_influenza/SOLICITACOES/IGOR/Figuras_PSP/")

# Verify and display the current working directory
getwd()

# Load the data from a CSV file
d1 <- read.csv(file = "BASE_UPAS_Taina_31012024_APENAS_2023.csv", header = TRUE, sep = ';')

# Select relevant columns from the data
d_sel <- select(d1, UBS, RESULT_INF_A, RESULT_INF_B, RESULT_COV)

# Create a list of specific UBS names
ubs_list <- c("JACANA", "BUTANTAN", "MARIA ANTONIETA", "TATUAPE", "TITO LOPES", "VERGUEIRO")

##################FLUA Analysis#########################################
# Function to process data for a specific UBS
processar_ubs <- function(df, ubs_nome, col_resultado) {
  df %>%
    filter(UBS == ubs_nome) %>%
    group_by({{col_resultado}}) %>%
    summarise(COUNT = n()) 
}

# Loop through each UBS in the list to get FLUA results
resultados_UBS <- lapply(ubs_list, function(ubs_nome) {
  processar_ubs(d_sel, ubs_nome, RESULT_INF_A)
})

# Assign results to named objects
names(resultados_UBS) <- paste0("contagem_A_", ubs_list)

# Assign individual results to named objects in the global environment (optional)
list2env(resultados_UBS, envir = .GlobalEnv)

# Remove rows with no information from the FLUA results
contagem_A_JACANA <- contagem_A_JACANA %>% slice(-1)
`contagem_A_MARIA ANTONIETA` <- `contagem_A_MARIA ANTONIETA` %>% slice(-1)
contagem_A_TATUAPE <- contagem_A_TATUAPE %>% slice(-1)
`contagem_A_TITO LOPES` <- `contagem_A_TITO LOPES` %>% slice(-1)
contagem_A_VERGUEIRO <- contagem_A_VERGUEIRO %>% slice(-1)

# Modify the data frames for FLUA results
contagem_A_JACANA <- contagem_A_JACANA %>%
  mutate(VIRUS = case_when(
    RESULT_INF_A == "DETECTABLE" ~ "FLUA",
    RESULT_INF_A == "INCONCLUSIVE" ~ "FLUA",
    RESULT_INF_A == "NOT-DETECTABLE" ~ "FLUA"
  )) %>%
  select(RESULT = RESULT_INF_A, COUNT, VIRUS)

# Repeat the modification for other UBS data frames
contagem_A_BUTANTAN <- contagem_A_BUTANTAN %>%
  mutate(VIRUS = case_when(
    RESULT_INF_A == "DETECTABLE" ~ "FLUA",
    RESULT_INF_A == "INCONCLUSIVE" ~ "FLUA",
    RESULT_INF_A == "NOT-DETECTABLE" ~ "FLUA"
  )) %>%
  select(RESULT = RESULT_INF_A, COUNT, VIRUS)

`contagem_A_MARIA ANTONIETA` <- `contagem_A_MARIA ANTONIETA` %>%
  mutate(VIRUS = case_when(
    RESULT_INF_A == "DETECTABLE" ~ "FLUA",
    RESULT_INF_A == "INCONCLUSIVE" ~ "FLUA",
    RESULT_INF_A == "NOT-DETECTABLE" ~ "FLUA"
  )) %>%
  select(RESULT = RESULT_INF_A, COUNT, VIRUS)

contagem_A_TATUAPE <- contagem_A_TATUAPE %>%
  mutate(VIRUS = case_when(
    RESULT_INF_A == "DETECTABLE" ~ "FLUA",
    RESULT_INF_A == "INCONCLUSIVE" ~ "FLUA",
    RESULT_INF_A == "NOT-DETECTABLE" ~ "FLUA"
  )) %>%
  select(RESULT = RESULT_INF_A, COUNT, VIRUS)

`contagem_A_TITO LOPES` <- `contagem_A_TITO LOPES` %>%
  mutate(VIRUS = case_when(
    RESULT_INF_A == "DETECTABLE" ~ "FLUA",
    RESULT_INF_A == "INCONCLUSIVE" ~ "FLUA",
    RESULT_INF_A == "NOT-DETECTABLE" ~ "FLUA"
  )) %>%
  select(RESULT = RESULT_INF_A, COUNT, VIRUS)

contagem_A_VERGUEIRO <- contagem_A_VERGUEIRO %>%
  mutate(VIRUS = case_when(
    RESULT_INF_A == "DETECTABLE" ~ "FLUA",
    RESULT_INF_A == "INCONCLUSIVE" ~ "FLUA",
    RESULT_INF_A == "NOT-DETECTABLE" ~ "FLUA"
  )) %>%
  select(RESULT = RESULT_INF_A, COUNT, VIRUS)

##################FLUB Analysis#########################################
# Loop through each UBS in the list to get FLUB results
resultados_UBS_B <- lapply(ubs_list, function(ubs_nome) {
  processar_ubs(d_sel, ubs_nome, RESULT_INF_B)
})

# Assign results to named objects
names(resultados_UBS_B) <- paste0("contagem_B_", ubs_list)

# Assign individual results to named objects in the global environment (optional)
list2env(resultados_UBS_B, envir = .GlobalEnv)

# Remove rows with no information from the FLUB results
contagem_B_JACANA <- contagem_B_JACANA %>% slice(-1)
`contagem_B_MARIA ANTONIETA` <- `contagem_B_MARIA ANTONIETA` %>% slice(-1)
contagem_B_TATUAPE <- contagem_B_TATUAPE %>% slice(-1)
`contagem_B_TITO LOPES` <- `contagem_B_TITO LOPES` %>% slice(-1)
contagem_B_VERGUEIRO <- contagem_B_VERGUEIRO %>% slice(-1)

# Modify the data frames for FLUB results
contagem_B_JACANA <- contagem_B_JACANA %>%
  mutate(VIRUS = case_when(
    RESULT_INF_B == "DETECTABLE" ~ "FLUB",
    RESULT_INF_B == "INCONCLUSIVE" ~ "FLUB",
    RESULT_INF_B == "NOT-DETECTABLE" ~ "FLUB"
  )) %>%
  select(RESULT = RESULT_INF_B, COUNT, VIRUS)

# Repeat the modification for other UBS data frames
contagem_B_BUTANTAN <- contagem_B_BUTANTAN %>%
  mutate(VIRUS = case_when(
    RESULT_INF_B == "DETECTABLE" ~ "FLUB",
    RESULT_INF_B == "INCONCLUSIVE" ~ "FLUB",
    RESULT_INF_B == "NOT-DETECTABLE" ~ "FLUB"
  )) %>%
  select(RESULT = RESULT_INF_B, COUNT, VIRUS)

`contagem_B_MARIA ANTONIETA` <- `contagem_B_MARIA ANTONIETA` %>%
  mutate(VIRUS = case_when(
    RESULT_INF_B == "DETECTABLE" ~ "FLUB",
    RESULT_INF_B == "INCONCLUSIVE" ~ "FLUB",
    RESULT_INF_B == "NOT-DETECTABLE" ~ "FLUB"
  )) %>%
  select(RESULT = RESULT_INF_B, COUNT, VIRUS)

contagem_B_TATUAPE <- contagem_B_TATUAPE %>%
  mutate(VIRUS = case_when(
    RESULT_INF_B == "DETECTABLE" ~ "FLUB",
    RESULT_INF_B == "INCONCLUSIVE" ~ "FLUB",
    RESULT_INF_B == "NOT-DETECTABLE" ~ "FLUB"
  )) %>%
  select(RESULT = RESULT_INF_B, COUNT, VIRUS)

`contagem_B_TITO LOPES` <- `contagem_B_TITO LOPES` %>%
  mutate(VIRUS = case_when(
    RESULT_INF_B == "DETECTABLE" ~ "FLUB",
    RESULT_INF_B == "INCONCLUSIVE" ~ "FLUB",
    RESULT_INF_B == "NOT-DETECTABLE" ~ "FLUB"
  )) %>%
  select(RESULT = RESULT_INF_B, COUNT, VIRUS)

contagem_B_VERGUEIRO <- contagem_B_VERGUEIRO %>%
  mutate(VIRUS = case_when(
    RESULT_INF_B == "DETECTABLE" ~ "FLUB",
    RESULT_INF_B == "INCONCLUSIVE" ~ "FLUB",
    RESULT_INF_B == "NOT-DETECTABLE" ~ "FLUB"
  )) %>%
  select(RESULT = RESULT_INF_B, COUNT, VIRUS)

##################COVID Analysis#########################################
# Loop through each UBS in the list to get COVID results
resultados_UBS_C <- lapply(ubs_list, function(ubs_nome) {
  processar_ubs(d_sel, ubs_nome, RESULT_COV)
})

# Assign results to named objects
names(resultados_UBS_C) <- paste0("contagem_C_", ubs_list)

# Assign individual results to named objects in the global environment (optional)
list2env(resultados_UBS_C, envir = .GlobalEnv)

# Remove rows with no information from the COVID results
contagem_C_JACANA <- contagem_C_JACANA %>% slice(-1)
`contagem_C_MARIA ANTONIETA` <- `contagem_C_MARIA ANTONIETA` %>% slice(-1)
contagem_C_TATUAPE <- contagem_C_TATUAPE %>% slice(-1)
`contagem_C_TITO LOPES` <- `contagem_C_TITO LOPES` %>% slice(-1)
contagem_C_VERGUEIRO <- contagem_C_VERGUEIRO %>% slice(-1)

# Modify the data frames for COVID results
contagem_C_JACANA <- contagem_C_JACANA %>%
  mutate(VIRUS = case_when(
    RESULT_COV == "DETECTABLE" ~ "COVID",
    RESULT_COV == "INCONCLUSIVE" ~ "COVID",
    RESULT_COV == "NOT-DETECTABLE" ~ "COVID"
  )) %>%
  select(RESULT = RESULT_COV, COUNT, VIRUS)

# Repeat the modification for other UBS data frames
contagem_C_BUTANTAN <- contagem_C_BUTANTAN %>%
  mutate(VIRUS = case_when(
    RESULT_COV == "DETECTABLE" ~ "COVID",
    RESULT_COV == "INCONCLUSIVE" ~ "COVID",
    RESULT_COV == "NOT-DETECTABLE" ~ "COVID"
  )) %>%
  select(RESULT = RESULT_COV, COUNT, VIRUS)

`contagem_C_MARIA ANTONIETA` <- `contagem_C_MARIA ANTONIETA` %>%
  mutate(VIRUS = case_when(
    RESULT_COV == "DETECTABLE" ~ "COVID",
    RESULT_COV == "INCONCLUSIVE" ~ "COVID",
    RESULT_COV == "NOT-DETECTABLE" ~ "COVID"
  )) %>%
  select(RESULT = RESULT_COV, COUNT, VIRUS)

contagem_C_TATUAPE <- contagem_C_TATUAPE %>%
  mutate(VIRUS = case_when(
    RESULT_COV == "DETECTABLE" ~ "COVID",
    RESULT_COV == "INCONCLUSIVE" ~ "COVID",
    RESULT_COV == "NOT-DETECTABLE" ~ "COVID"
  )) %>%
  select(RESULT = RESULT_COV, COUNT, VIRUS)

`contagem_C_TITO LOPES` <- `contagem_C_TITO LOPES` %>%
  mutate(VIRUS = case_when(
    RESULT_COV == "DETECTABLE" ~ "COVID",
    RESULT_COV == "INCONCLUSIVE" ~ "COVID",
    RESULT_COV == "NOT-DETECTABLE" ~ "COVID"
  )) %>%
  select(RESULT = RESULT_COV, COUNT, VIRUS)

contagem_C_VERGUEIRO <- contagem_C_VERGUEIRO %>%
  mutate(VIRUS = case_when(
    RESULT_COV == "DETECTABLE" ~ "COVID",
    RESULT_COV == "INCONCLUSIVE" ~ "COVID",
    RESULT_COV == "NOT-DETECTABLE" ~ "COVID"
  )) %>%
  select(RESULT = RESULT_COV, COUNT, VIRUS)

##################Combine and Plot Data################################
# Combine all the individual results into one data frame for plotting
d_total <- bind_rows(
  contagem_A_JACANA, contagem_A_BUTANTAN, `contagem_A_MARIA ANTONIETA`, 
  contagem_A_TATUAPE, `contagem_A_TITO LOPES`, contagem_A_VERGUEIRO, 
  contagem_B_JACANA, contagem_B_BUTANTAN, `contagem_B_MARIA ANTONIETA`, 
  contagem_B_TATUAPE, `contagem_B_TITO LOPES`, contagem_B_VERGUEIRO, 
  contagem_C_JACANA, contagem_C_BUTANTAN, `contagem_C_MARIA ANTONIETA`, 
  contagem_C_TATUAPE, `contagem_C_TITO LOPES`, contagem_C_VERGUEIRO
)

# Ensure 'UBS' and 'RESULT' columns are of character type for plotting
d_total$UBS <- as.character(d_total$UBS)
d_total$RESULT <- as.character(d_total$RESULT)

# Set up the plotting theme
theme_set(theme_minimal())

# Plot the data using ggplot
ggplot(d_total, aes(x = VIRUS, y = COUNT, fill = VIRUS)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~ UBS) +
  labs(x = "Virus", y = "Count", fill = "Virus", 
       title = "Virus Detection Counts by UBS") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_manual(values = c("FLUA" = "blue", "FLUB" = "red", "COVID" = "green"))

# Save the plot to a file
ggsave("virus_detection_counts_by_ubs.png", width = 12, height = 8)
