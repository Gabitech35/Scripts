## Installing required packages
# Create a vector of packages needed for the analysis
pacotes <- c("plotly","tidyverse","knitr","kableExtra","cowplot", "ggplot2",
             "dplyr", "lubridate", "tidyverse")

# Check if the required packages are installed
# If not, install the missing ones and then load all packages
if(sum(as.numeric(!pacotes %in% installed.packages())) != 0){
  # Identify the missing packages
  instalador <- pacotes[!pacotes %in% installed.packages()]
  # Install missing packages one by one
  for(i in 1:length(instalador)) {
    install.packages(instalador, dependencies = T)
    break()} 
  # Load all required packages
  sapply(pacotes, require, character = T) 
} else {
  # If all packages are already installed, load them
  sapply(pacotes, require, character = T) 
}

### Set the working directory where files will be saved
# Specify the directory for saving output files
setwd("/home/gabriela/Documentos/CEVIVAS_COV/Solicitações/carol/Grafico_paper_covid_rede/Graficos/")

# Check the current working directory
getwd()

# Load the CSV data for Brazil and Instituto Butantan (IB)
br <-read.csv(file = "All_brasil_2021_2022_MENOS_IB.csv", header = T, sep = ',')
ib <-read.csv(file = "All_IB.csv", header = T, sep = ',')

# Select only relevant columns for further analysis from both datasets
br_sel = br[,c(3,5,7:9,21,27)]
ib_sel = ib[,c(3,5,7:9,21,27)]

# Ensure that the 'date' column is treated as a date type
str(ib_sel$date) 

# Convert the collection and submission dates to a standard date format (yyyy-mm-dd)
ib_sel$date_coleta_new <- ymd(ib_sel$date)
br_sel$date_coleta_new <- ymd(br_sel$date)

ib_sel$date_submitted_new <- ymd(ib_sel$date_submitted)
br_sel$date_submitted_new <- ymd(br_sel$date_submitted)

# Calculate the difference (in days) between submission and collection dates
ib_sel$diff_times = difftime(ib_sel$date_submitted_new,ib_sel$date_coleta_new, units = "days")
br_sel$diff_times = difftime(br_sel$date_submitted_new,br_sel$date_coleta_new, units = "days")

# Identify and save records where the submission time difference is less than 8 days
test = ib_sel[ib_sel$diff_times < 8, ] 
write.csv(test, file = "depositos-estranhos.csv", sep = ";", row.names = F)

# Filter sequences collected after March 1, 2021
ib_sel2 = ib_sel %>% filter(date > '2021-03-01')
br_sel2 = br_sel %>% filter(date > '2021-03-01')

# Remove sequences with a submission time difference less than 8 days
ib_sel_removed <-ib_sel2[!(ib_sel2$diff_times<8),]
ib_sel_removed

# Group by month and calculate the mean submission time (diff_times) for each month
ib_sel_month_group <- ib_sel_removed %>% group_by(month = cut(date_coleta_new, "month")) %>% 
  summarise_at(vars(diff_times), list(mean_deposit_time = mean))

ib_sel_month_group$month = as.Date(ib_sel_month_group$month)

br_sel_month_group <- br_sel2 %>% group_by(month = cut(date_coleta_new, "month")) %>% 
  summarise_at(vars(diff_times), list(mean_deposit_time = mean))

br_sel_month_group$month = as.Date(br_sel_month_group$month)

# Create a new column to distinguish between IB and other Brazilian laboratories
br_sel_month_group$Origem_deposito = "Outros Laboratórios do Brasil"
ib_sel_month_group$Origem_deposito = "Instituto Butantan"

# Combine data from both IB and other Brazilian laboratories
all_date_month_group = rbind(br_sel_month_group, ib_sel_month_group)

# Convert mean deposit time to integer format
all_date_month_group$mean_deposit_time = as.integer(all_date_month_group$mean_deposit_time)
str(all_date_month_group$mean_deposit_time)

# Plot the mean submission time per month
p <- ggplot(all_date_month_group, aes(x=month, y=mean_deposit_time, group = Origem_deposito, color = Origem_deposito))+ 
  geom_line() + 
  scale_x_date(date_breaks = "1 month",
               date_labels = "%B %Y") +
    labs(title="Average time between sample collection and submission to GISAID",
         x="", y = "Monthly average submission time (days)",
         color = "Source of deposit")+
  theme_classic()+
  scale_y_continuous(limits = c(0,220), breaks = seq(0,220, by = 20))+
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.text=element_text(size=12),
    plot.title = element_text(hjust = 0.5, size = 20),
    legend.title = element_text(size=18),
    legend.text = element_text(size=14),
    legend.position = c(0.8, 0.7),
    axis.text.x=element_text(angle = 90, vjust = 0.5)
  ) 

# Save the plot to a PNG file
ggsave("gisaid_submit_time.png",plot = p, dpi = 300, height = 9,width = 14)

# Calculate the number of sequences submitted per month
ib_sel_sum_month_group <- ib_sel_removed %>% group_by(month = cut(date_submitted_new, "month")) %>% 
  tally()

br_sel_sum_month_group <- br_sel2 %>% group_by(month = cut(date_submitted_new, "month")) %>% 
  tally()

# Add the source of deposit information for each group
ib_sel_sum_month_group$Origem_deposito = "Instituto Butantan"
br_sel_sum_month_group$Origem_deposito = "Outros Laboratórios do Brasil"

# Convert the month column to date format
ib_sel_sum_month_group$month = as.Date(ib_sel_sum_month_group$month)
br_sel_sum_month_group$month = as.Date(br_sel_sum_month_group$month)

# Combine data from both IB and other Brazilian labs
all_date_gruped = rbind(ib_sel_sum_month_group,br_sel_sum_month_group)

# Calculate the percentage of submissions per month
all_date_percentage = all_date_gruped %>% group_by(month) %>% 
  mutate(percentage = n/sum(n))

# Plot the percentage of sequences submitted each month
q <- ggplot(all_date_percentage, aes(x=month, y=percentage, group = Origem_deposito, color = Origem_deposito))+ 
  geom_line() + 
  scale_x_date(date_breaks = "1 month",
               date_labels = "%B %Y") +
  labs(title="Percentage of sequences submitted to GISAID by month",x="", 
       y = "Monthly percentage of sequences",
       color = "Source of deposit")+
  theme_classic()+
  scale_y_continuous(labels = scales::percent)+
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.text=element_text(size=12),
    plot.title = element_text(hjust = 0.5, size = 20),
    legend.title = element_text(size=18),
    legend.text = element_text(size=14),
    axis.text.x=element_text(angle = 90, vjust = 0.5)
  ) 

# Save the plot to a PNG file
ggsave("gisaid_percentage_submit.png",plot = q, dpi = 300, height = 9,width = 14)

# Calculate cumulative sum of submissions for both IB and other Brazilian labs
all_date_gruped$cum_sum <- ave(all_date_gruped$n, all_date_gruped$Origem_deposito, FUN=cumsum)

# Calculate the cumulative percentage of submissions over time
all_date_cumulative = all_date_gruped %>%
  group_by(month) %>%
  mutate(cumulative_percentage = (cum_sum/sum(cum_sum)))

# Plot the cumulative percentage of sequences submitted
z <- ggplot(all_date_cumulative, aes(x=month, y=cumulative_percentage, group = Origem_deposito, color = Origem_deposito))+ 
  geom_line() + 
  scale_x_date(date_breaks = "1 month",
               date_labels = "%B %Y") +
  labs(title="Cumulative percentage of sequences submitted to GISAID",x="", 
       y = "Cumulative percentage of sequences",
       color = "Source of deposit")+
  theme_classic()+
  scale_y_continuous(labels = scales::percent)+
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.text=element_text(size=12),
    plot.title = element_text(hjust = 0.5, size = 20),
    legend.title = element_text(size=18),
    legend.text = element_text(size=14),
    axis.text.x=element_text(angle = 90, vjust = 0.5)
  ) 

# Save the cumulative percentage plot to a PNG file
ggsave("gisaid_cumulative_percentage.png",plot = z, dpi = 300, height = 9,width = 14)
