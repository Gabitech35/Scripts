# Load required libraries for data manipulation, plotting, and spatial operations
library(readr)      # For reading CSV files
library(ggplot2)    # For creating plots
library(geobr)      # For accessing Brazilian maps
library(sf)         # For handling spatial data
library(plotly)     # For interactive plots
library(dplyr)      # For data manipulation
library(lubridate)  # For date operations
library(tidyr)      # For data tidying
library(countrycode) # For country code conversion
library(ggbreak)    # For breaking plots
library(grid)       # For advanced graphical functions
library(cowplot)    # For combining plots
library(gridExtra)  # For arranging multiple plots
library(rnaturalearth) # For natural earth data
library(stringi)    # For string operations

#### Set the working directory for saving files
setwd("/home/gabriela/Documentos/CEVIVAS_COV/Solicitações/CAROL/cov_br2024-jan-26-jun/mapa/")

# Load the CSV file containing the data
df1 <- read.csv(file = "cov_br2024-jan-26-jun.csv", header = T, sep = ',')

# Load the map data for Brazil's states (UF) using spatial data
brazil_map <- st_read("BR_UF_2021")

# Remove observations where the state information is missing
df1 <- df1 %>% filter(!is.na(estado))

# Remove observations where the lineage information is missing
df1 <- df1 %>% filter(!is.na(linhagem))

# Count the number of distinct lineages by state
linhagens_por_local <- df1 %>%
  group_by(estado) %>%
  summarize(num_linhagens = n_distinct(linhagem))

# Vector mapping state names without accents to their abbreviations (in Portuguese)
correspondencia_uf <- c("Acre" = "AC", "Alagoas" = "AL", "Amapa" = "AP", "Amazonas" = "AM", 
                        "Bahia" = "BA", "Ceara" = "CE", "Distrito Federal" = "DF", "Espirito Santo" = "ES",
                        "Goias" = "GO", "Maranhao" = "MA", "Mato Grosso" = "MT", "Mato Grosso do Sul" = "MS",
                        "Minas Gerais" = "MG", "Para" = "PA", "Paraiba" = "PB", "Parana" = "PR",
                        "Pernambuco" = "PE", "Piaui" = "PI", "Rio de Janeiro" = "RJ", "Rio Grande do Norte" = "RN",
                        "Rio Grande do Sul" = "RS", "Rondonia" = "RO", "Roraima" = "RR", "Santa Catarina" = "SC",
                        "Sao Paulo" = "SP", "Sergipe" = "SE", "Tocantins" = "TO",
                        "Federal District" = "DF")

# Remove accents from state names for matching
linhagens_por_local$estado <- stri_trans_general(linhagens_por_local$estado, "latin-ascii")

# Replace state names without accents with their abbreviations
linhagens_por_local$estado <- correspondencia_uf[linhagens_por_local$estado]

# Merge the map data with the lineage data based on state abbreviation
dados_mapa <- merge(brazil_map, linhagens_por_local, by.x = 'SIGLA', by.y = 'estado', all.x = FALSE)

# Convert map data to an 'sf' object for plotting
brazil_map_sf <- st_as_sf(brazil_map)

# Convert merged map data with lineage information to an 'sf' object
dados_mapa_sf <- st_as_sf(dados_mapa)

# Plot the map of SARS-CoV-2 lineages
cov <- ggplot() +
  geom_sf(data = brazil_map_sf, fill = "#ffe0e0", color = "#fac8c8", size = 0.2) +  # Base map layer
  geom_sf(data = dados_mapa_sf, aes(fill = num_linhagens), color = "#ffe0e0", size = 0.2) +  # Add lineage data
  geom_sf_text(data = brazil_map_sf, aes(label = SIGLA), size = 3) + # Add state abbreviations to the map
  scale_fill_gradient(low = "#fac8c8", high = "#8a2f2f", name = "N",
                      breaks = seq(0, 22, by = 2), labels = seq(0, 22, by = 2),
                      guide = guide_colorbar(direction = "vertical", title.position = "right")) +  # Color gradient for lineages
  coord_sf() + # Use coordinate system for spatial data
  theme_void() +  # Remove axis labels and background
  theme(legend.key.height = unit(1, "cm"),
        legend.key.width = unit(0.3, "cm"), # Adjust legend key size
        plot.title = element_text(hjust = 0.5, size = 20)) + # Center and style the title
  labs(title = "SARS-CoV-2") # Add title to the plot

# Save the plot as a PDF file
ggsave("cov.pdf", cov, width = 12, height = 14, units = "in", dpi = 400)

#######################################
# Group by clade and lineage

# Count the number of distinct lineages by clade
agrupar <- df1 %>%
  group_by(clado) %>%
  summarize(num_linhagens = n_distinct(linhagem))

# Load another CSV file containing additional data
df2 <- read.csv(file = "/home/gabriela/Documentos/CEVIVAS_COV/Solicitações/CAROL/cov_br2024-jan-26-jun/stram_plot/cov_SP2024-jan-26-jun.csv", 
                header = T, sep = ',')

# Count the number of distinct lineages by clade in the new dataset
agruparSP <- df2 %>%
  group_by(clado) %>%
  summarize(num_linhagens = n_distinct(linhagem))
