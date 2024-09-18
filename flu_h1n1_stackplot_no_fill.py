import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

def complete_dataframe(df1=None, df2=None, with_nonzero=False):
    """
    Ensures that df2 has the same columns and rows as df1. 
    If a column or row is missing in df2, it is added. 
    Missing values are filled with 0, or with the nearest non-zero value if 'with_nonzero' is set to True.
    """
    # Get column names from both DataFrames
    COLUMNS1 = df1.columns
    COLUMNS2 = df2.columns

    # Add missing columns from df1 to df2
    for C1 in COLUMNS1:
        if C1 not in COLUMNS2:
            df2[C1] = None

    # Get index (rows) from both DataFrames
    INDEX1 = df1.index
    INDEX2 = df2.index

    # Add missing rows from df1 to df2, optionally filling missing values
    for I1 in INDEX1:
        if I1 not in INDEX2:
            if with_nonzero:
                df2.loc[I1] = None
                df2 = df2.sort_index()
                Idx = np.where(df2.index == I1)[0][0]
                if Idx != 0:
                    df2.loc[I1] = df2.iloc[Idx-1, :]  # Fill with previous row if possible
                else:
                    df2.loc[I1] = df2.iloc[Idx+1, :]  # Fill with next row if first in list
            else:
                df2.loc[I1] = None  # Fill with None if with_nonzero is False
    
    df2 = df2.sort_index()
    df2 = df2.fillna(0)  # Replace NaN values with 0
    return df2

# Plot settings to control legend, figure size, and axis labels
params = {'legend.fontsize': 14,
          'figure.figsize': (20, 16),
          'axes.labelsize': 12,
          'axes.titlesize': 12,
          'xtick.labelsize': 10,
          'ytick.labelsize': 10}
plt.rcParams.update(params)

# Load data from CSV file
df = pd.read_csv("DF-clados_streamplot_oficial.csv", sep=",", index_col=False)

# Keep only relevant columns: location (UPA), date, and lineage
df = df[['UPA', 'collection_date', 'lineage']]

# Reset index to clean the DataFrame
df.reset_index(drop=True, inplace=True)

# Convert 'collection_date' to datetime format
df['collection_date'] = pd.to_datetime(df['collection_date'])

# Generate a sorted list of unique locations (UPA)
UPA = list(set(df['UPA'].values))
UPA = [i for i in UPA if i == i]
UPA.sort()

# Group data by month and lineage
df1 = df[['collection_date', 'lineage']]
df1['month'] = df1['collection_date'].dt.to_period('M')
df1 = df1.groupby(['month', 'lineage']).size().unstack(fill_value=0)

# Get unique clades (lineages) from the dataset
unique_clades = set(df['lineage'])

# Color dictionary for each clade
clade_color_dict = {"5a.1": "#8dd3c7", "5a.2a": "#e78ac3", "5a.2": "#bebada", "5a.2a.1": "#80b1d3"}

# Create a grid of subplots, two per row
num_plots = len(UPA) + 1
num_rows = (num_plots + 1) // 2
fig, axs = plt.subplots(num_rows, 2, figsize=(16, 12), constrained_layout=True, gridspec_kw={'hspace': 0.1, 'wspace': 0.075})

# Loop variables for legend handling and tracking max frequency
all_labels = []
handles = []
labels = []
handle_dict = {}
COUNT = -1

# Iterate over all locations, creating subplots
for ITER in range(num_plots):
    i, j = divmod(ITER, 2)  # Determine subplot position (i, j)
    
    if ITER == 0:
        # For the first plot (Brazil as a whole), calculate the frequency of clades per month
        freq_por_mes = df1.T / df1.sum(axis=1) * 100  # Convert counts to percentages
        freq_por_mes = freq_por_mes.T
    else:
        COUNT += 1
        # Filter data for the current UPA (location)
        df2 = df.loc[np.where(df['UPA'] == UPA[COUNT])]
        df2 = df2[['collection_date', 'lineage']]
        df2['month'] = df2['collection_date'].dt.to_period('M')
        
        # Calculate the frequency of clades for this specific location
        freq_por_mes = df2.groupby(['month', 'lineage']).size().unstack(fill_value=0)
        freq_por_mes = freq_por_mes.T / freq_por_mes.sum(axis=1) * 100  # Convert to percentage
        freq_por_mes = freq_por_mes.T

        # Ensure df2 has the same columns and rows as the main DataFrame df1
        freq_por_mes = complete_dataframe(df1=df1, df2=freq_por_mes, with_nonzero=False)
    
    # Track the maximum frequency value for consistent y-axis scaling
    max_freq_value = max(max_freq_value, freq_por_mes.values.max())

    # Create a list of time periods (months) for the x-axis
    days = [str(month) for month in freq_por_mes.index]

    # Assign a color to each clade based on the dictionary
    clade_colors = [clade_color_dict[c] for c in freq_por_mes.columns]

    # Create a stacked area plot for each subplot
    lines = axs[i, j].stackplot(days, freq_por_mes.T.values, labels=freq_por_mes.columns, colors=clade_colors)
    
    # Update legend handles and labels for the final plot
    h, l = axs[i, j].get_legend_handles_labels()
    for hi in range(len(h)):
        handle_dict[l[hi]] = h[hi] 
        
    handles.extend(h)
    labels.extend(l)
    
    # Set title for the subplot, either Brazil or UPA location
    if ITER == 0:
        axs[i, j].set_title("Brazil")
    else:
        axs[i, j].set_title(UPA[COUNT])
        
    axs[i, j].set_xlabel('Date')
    axs[i, j].tick_params(axis='x', rotation=45)
    axs[i, j].set_ylabel('Frequency (%)')

# Set consistent y-axis limits for all subplots
for i in range(num_rows):
    for j in range(2):
        axs[i, j].set_ylim(0, max_freq_value)

# Remove any empty subplots if the number of plots is odd
if num_plots % 2 != 0:
    fig.delaxes(axs[num_rows - 1, 1])

# Add a global legend at the bottom
fig.legend(handles=list(handle_dict.values()), labels=list(handle_dict.keys()), loc='lower center', bbox_to_anchor=(0.5, -0.05), ncol=len(set(df.lineage)), fontsize='14')

# Save the figure as a PDF file
fig.savefig("metadata_h3n2_Brazil_common_zero.pdf", dpi=300, bbox_inches='tight')

# Display the plot
plt.show()
