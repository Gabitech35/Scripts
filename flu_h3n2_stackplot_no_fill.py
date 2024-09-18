import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Function to ensure both dataframes have the same structure by including missing columns and indexes
def complete_dataframe(df1=None, df2=None, with_nonzero=False):
    # Get columns from both dataframes
    COLUMNS1 = df1.columns
    COLUMNS2 = df2.columns

    # Add missing columns from df1 into df2
    for C1 in COLUMNS1:
        if C1 not in COLUMNS2:
            df2[C1] = None  # Set missing columns to None
    
    # Get indexes from both dataframes
    INDEX1 = df1.index
    INDEX2 = df2.index

    # Add missing indexes from df1 into df2
    for I1 in INDEX1:
        if I1 not in INDEX2:
            if with_nonzero:  # If requested, fill missing indexes with adjacent data
                df2.loc[I1] = None
                df2 = df2.sort_index()  # Sort index to maintain order
                Idx = np.where(df2.index == I1)[0][0]
                if Idx != 0:
                    df2.loc[I1] = df2.iloc[Idx - 1, :]
                else:
                    df2.loc[I1] = df2.iloc[Idx + 1, :]
            else:
                df2.loc[I1] = None  # Just set missing index to None

    # Sort index again after modification and fill remaining NaN values with 0
    df2 = df2.sort_index()
    df2 = df2.fillna(0)
    return df2

# Set general plot parameters such as font sizes and figure size
params = {
    'legend.fontsize': 14,
    'figure.figsize': (20, 16),
    'axes.labelsize': 12,
    'axes.titlesize': 12,
    'xtick.labelsize': 10,
    'ytick.labelsize': 10
}
plt.rcParams.update(params)

# Load data from a CSV file, assuming tab-delimited, and filter relevant columns
df = pd.read_csv("", sep="\t", index_col=False)
df = df[['macroregion', 'collection_date', 'lineage']]  # Only keep necessary columns

# Reset index after filtering to avoid issues
df.reset_index(drop=True, inplace=True)

# Convert collection_date to datetime format for time-based operations
df['collection_date'] = pd.to_datetime(df['collection_date'])

# Get the unique values from the 'macroregion' column, ensuring non-null values
MACRORIGIONS = list(set(df['macroregion'].values))
MACRORIGIONS = [i for i in MACRORIGIONS if i == i]
MACRORIGIONS.sort()  # Sort the macroregions alphabetically or logically

# Create a new dataframe grouped by 'month' and 'lineage' and count occurrences for df1
df1 = df[['collection_date', 'lineage']]
df1['month'] = df1['collection_date'].dt.to_period('M')  # Convert dates to monthly periods
df1 = df1.groupby(['month', 'lineage']).size().unstack(fill_value=0)  # Group by month and lineage

# Create a dictionary mapping unique clades (lineages) to specific colors for the plot
clade_color_dict = {
    "3C.2a1b.2a.1": "#E31A1C", "3C.2a1b.2a.1a.1": "#E6AB02", 
    "3C.2a1b.2a.2": "#bebada", "3C.2a1b.2a.2c": "#e78ac3", 
    "3C.2a1b.2a.2b": "#FF7F00", "3C.2a1b.2a.2a": "#33A02C", 
    # More clades with corresponding colors...
}

# Prepare figure and axes for subplots, with grid spacing for layout
max_freq_value = 0  # Track the maximum frequency value for setting uniform y-limits
num_plots = len(MACRORIGIONS) + 1  # Number of plots including a general one for "Brazil"
num_rows = (num_plots + 1) // 2  # Determine number of rows based on the number of regions
fig, axs = plt.subplots(num_rows, 2, figsize=(16, 12), constrained_layout=True, gridspec_kw={'hspace': 0.1, 'wspace': 0.075})

all_labels = []  # Collect all labels for the legend
handles = []  # Collect handles for the plot legend
labels = []
handle_dict = {}
COUNT = -1

# Loop through the number of subplots (for each region)
for ITER in range(num_plots):
    i, j = divmod(ITER, 2)  # Split into grid positions

    if ITER == 0:
        # First plot is for the whole dataset (Brazil)
        freq_por_mes = df1
        freq_por_mes = freq_por_mes.T / freq_por_mes.sum(axis=1) * 100  # Normalize to percentages
        freq_por_mes = freq_por_mes.T
    else:
        COUNT += 1
        # Filter data for each specific macroregion
        df2 = df.loc[np.where(df['macroregion'] == MACRORIGIONS[COUNT])]
        df2 = df2[['collection_date', 'lineage']]
        df2['month'] = df2['collection_date'].dt.to_period('M')
        freq_por_mes = df2.groupby(['month', 'lineage']).size().unstack(fill_value=0)
        freq_por_mes = freq_por_mes.T / freq_por_mes.sum(axis=1) * 100
        freq_por_mes = freq_por_mes.T

        # Complete the dataframe with missing data
        freq_por_mes = complete_dataframe(df1=df1, df2=freq_por_mes, with_nonzero=False)

    # Update max frequency for setting uniform y-axis limits
    max_freq_value = max(max_freq_value, freq_por_mes.values.max())

    # Prepare x-axis labels (dates)
    days = [str(month) for month in freq_por_mes.index]

    # Plot stackplot with lineage-specific colors
    clade_colors = [clade_color_dict[c] for c in freq_por_mes.columns]
    lines = axs[i, j].stackplot(days, freq_por_mes.T.values, labels=freq_por_mes.columns, colors=clade_colors)
    
    # Collect labels and handles for each subplot for the legend
    h, l = axs[i, j].get_legend_handles_labels()
    for hi in range(len(h)):
        handle_dict[l[hi]] = h[hi]
        
    handles.extend(h)
    labels.extend(l)
    
    # Set subplot titles
    if ITER == 0:
        axs[i, j].set_title("Brazil")
    else:
        axs[i, j].set_title(MACRORIGIONS[COUNT])
        
    axs[i, j].set_xlabel('Date')
    axs[i, j].tick_params(axis='x', rotation=45)
    axs[i, j].set_ylabel('Frequency (%)')

# Set the same y-axis range for all subplots to make comparisons easier
for i in range(num_rows):
    for j in range(2):
        axs[i, j].set_ylim(0, max_freq_value)

# Remove extra empty subplot if there's an odd number of plots
if num_plots % 2 != 0:
    fig.delaxes(axs[num_rows - 1, 1])

# Add a global legend below the plots
fig.legend(handles=list(handle_dict.values()), labels=list(handle_dict.keys()), loc='lower center', bbox_to_anchor=(0.5, -0.05), ncol=len(set(df.lineage)), fontsize='14')

# Save the figure as a PDF
fig.savefig("metadata_h3n2_Brazil_common_zero.pdf", dpi=300, bbox_inches='tight')
plt.show()
