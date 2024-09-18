# Loading required libraries for data manipulation and visualization
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import matplotlib.dates as mdates

# Define a helper function to remove duplicates while preserving order in a sequence
def _sort(seq):
    seen = set()  # Set to store seen elements
    seen_add = seen.add  # Local function to add elements to the set
    return [x for x in seq if not (x in seen or seen_add(x))]  # Return elements not already in the set

# Set plotting parameters to define the appearance of plots (font sizes, figure size, etc.)
params = {'legend.fontsize': 14,
          'figure.figsize': (20,8),
          'axes.labelsize': 16,
          'axes.titlesize': 16,
          'xtick.labelsize': 14,
          'ytick.labelsize': 14,
         }
plt.rcParams.update(params)  # Apply the plot settings

# Load the data from a CSV file; the file contains virus information with dates and lineages
df = pd.read_csv("freq_brasil2.csv", sep=";", index_col=False)

# Select only the relevant columns from the dataset: 'Virus', 'collection_date', and 'lineage'
df = df[['Virus', 'collection_date', 'lineage']]

# Add a new column for 'country', setting it to 'Brazil' for all rows
df["country"] = ["Brazil"]*len(df)

# Reset the index of the DataFrame to avoid any gaps in the row numbering
df.reset_index(drop=True, inplace=True)

# Convert the 'collection_date' column to datetime format for easier manipulation
df['collection_date'] = pd.to_datetime(df['collection_date'])

# Define the country of interest for filtering the data; in this case, it's Brazil
COUNTRY = ["Brazil"]

# Extract unique lineages (or clades) from the dataset for further analysis
unique_clades = set(df['lineage'])

# Example of a color dictionary for assigning unique colors to different lineages (commented out)
"""clade_color_dict = {"3C.2a1b.2a.1": "#E31A1C", "3C.2a1b.2a.1a.1": "#E6AB02", 
                      "3C.2a1b.2a.2": "#bebada", "3C.2a1b.2a.2c": "#e78ac3"}"""

# Initialize the maximum frequency value, which will be used to scale the y-axis
max_freq_value = 0

# Define the number of plots and rows required based on the number of countries (Brazil in this case)
num_plots = len(COUNTRY)
num_rows = (num_plots + 1) // 2  # Ensures we have enough rows for all plots

# Set the title of the plot (currently empty)
plt.title('', fontsize=20)

# Lists and dictionaries to store labels and handles for the legend
all_labels = []
handles = []
labels = []
handle_dict = {}

# Filter the DataFrame for the specific country (Brazil)
df2 = df.loc[np.where(df['country'] == COUNTRY[0])]  # Select rows where 'country' is 'Brazil'
df2 = df2[['collection_date', 'lineage']]  # Keep only 'collection_date' and 'lineage' columns

# Add a 'month' column by extracting the year-month part from the 'collection_date'
df2['month'] = df2['collection_date'].dt.to_period('M')

# Group the data by month and lineage, counting the number of occurrences for each group
# Then, reshape the DataFrame to have lineages as columns, and fill missing values with 0
freq_por_mes = df2.groupby(['month', 'lineage']).size().unstack(fill_value=0)

# Convert raw counts to percentages for each month by dividing by the total sum for that month
freq_por_mes = freq_por_mes.T / freq_por_mes.sum(axis=1) * 100
freq_por_mes = freq_por_mes.T  # Transpose back to have months as rows and lineages as columns

# Update the maximum frequency value if the current data exceeds the previous max
max_freq_value = max(max_freq_value, freq_por_mes.values.max())

# Extract the list of months (in string format) for use on the x-axis of the plot
days = [str(month) for month in freq_por_mes.index]

# Assign unique colors to each clade (lineage) for plotting (colors need to be defined in clade_color_dict)
clade_colors = [clade_color_dict[c] for c in freq_por_mes.columns]

# Create the stacked area plot (stackplot) showing the relative frequency of each lineage over time
lines = plt.stackplot(days, freq_por_mes.T.values, labels=freq_por_mes.columns, colors=clade_colors)

# Set the x-axis label, rotate the ticks for better readability, and set the y-axis label
plt.xlabel('Date')
plt.xticks(rotation=45, ha='right')
plt.ylabel('Frequency (%)')

# Display the legend showing the different lineages
plt.legend()

# Set the y-axis limit to 0-100% as we're plotting relative frequencies
plt.ylim(0, 100)

# Save the plot as a high-resolution PDF
plt.savefig("all_virus_Brazil_2023_v3.pdf", dpi=300, bbox_inches='tight')

# Display the plot
plt.show()
