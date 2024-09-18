# Importing necessary libraries
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from datetime import datetime

# Define a helper function to ensure that df2 includes all columns and indexes from df1
def complete_dataframe(df1=None, df2=None, with_nonzero=False):
    # Include columns from df1 that are not in df2
    COLUMNS1 = df1.columns
    COLUMNS2 = df2.columns

    for C1 in COLUMNS1:
        if C1 not in COLUMNS2:
            df2[C1] = None
    
    # Include indexes from df1 that are not in df2
    INDEX1 = df1.index
    INDEX2 = df2.index

    for I1 in INDEX1:
        if I1 not in INDEX2:
            if with_nonzero:
                df2.loc[I1] = None
                df2 = df2.sort_index()
                Idx = np.where(df2.index == I1)[0][0]
                if Idx != 0:
                    df2.loc[I1] = df2.iloc[Idx - 1, :]
                else:
                    df2.loc[I1] = df2.iloc[Idx + 1, :]
            else:
                df2.loc[I1] = None
    df2 = df2.sort_index()
    df2 = df2.fillna(0)
    return df2

# Set parameters for plot appearance
params = {
    'legend.fontsize': 14,
    'figure.figsize': (20, 10),
    'axes.labelsize': 12,
    'axes.titlesize': 12,
    'xtick.labelsize': 10,
    'ytick.labelsize': 10
}
plt.rcParams.update(params)

# Load the DataFrame from a CSV file
df = pd.read_csv("ALL_flu_2023.csv", sep=",", index_col=False)
df

# Select relevant columns from the DataFrame
df = df[['Country', 'Collection_Date', 'Lineage']]
# Reset index and convert 'Collection_Date' to datetime format
df.reset_index(drop=True, inplace=True)
df['Collection_Date'] = pd.to_datetime(df['Collection_Date'])

# Define the date range for the plot
start_date = pd.Period('2023-01', freq='M')
end_date = pd.Period('2023-12', freq='M')
all_months = pd.period_range(start=start_date, end=end_date, freq='M')

# Group data by month and lineage, and count occurrences
df['month'] = df['Collection_Date'].dt.to_period('M')
df1 = df.groupby(['month', 'Lineage']).size().unstack(fill_value=0)

# Reindex the DataFrame to include all months in the specified range
df1 = df1.reindex(all_months, fill_value=0)

# Ensure all lineage columns are included
df1 = df1.reindex(columns=df1.columns.union(df['Lineage'].unique()))

# Define colors for each lineage
unique_clades = set(df['Lineage'])
clade_color_dict = {
    "H1N1": "#b2df8a", "H3N2": "#1f78b4", "Victoria": "#fb9a99"
}

# Create the figure and axes for the plot with specified size
fig, ax = plt.subplots(figsize=(16, 7))  # Decreased the height of the plot

# Calculate frequency percentages for each lineage per month
freq_por_mes = df1.T / df1.sum(axis=1) * 100
freq_por_mes = freq_por_mes.T

# Get dates and colors for the plot
days = [str(month) for month in freq_por_mes.index]
clade_colors = [clade_color_dict.get(c, "#333333") for c in freq_por_mes.columns]

# Create a stacked area plot
lines = ax.stackplot(days, freq_por_mes.T.values, labels=freq_por_mes.columns, colors=clade_colors)

# Get handles and labels for the legend
h, l = ax.get_legend_handles_labels()
handle_dict = {label: handle for handle, label in zip(h, l)}

# Set the title and labels for the plot
ax.set_title("Influenza Brazil 2023", fontsize=20)  # Set title with font size 20
ax.set_xlabel('Date', fontsize=16)   # Set x-axis label with font size 16
ax.tick_params(axis='x', rotation=45)  # Rotate x-axis labels for better readability
ax.set_ylabel('Frequency (%)', fontsize=16)  # Set y-axis label with font size 16

# Set y-axis limits from 0 to 100%
ax.set_ylim(0, 100)

# Add a legend to the plot
fig.legend(handles=list(handle_dict.values()), labels=list(handle_dict.keys()), loc='lower center', bbox_to_anchor=(0.5, -0.09), ncol=len(unique_clades), fontsize='14')

# Save the plot as a PDF file with high resolution
fig.savefig("flu_all_Brazil_2023_sem-preenchimento.pdf", dpi=400, bbox_inches='tight')
plt.show()
