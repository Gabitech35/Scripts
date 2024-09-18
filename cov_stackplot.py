import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

def complete_dataframe(df1=None, df2=None, with_nonzero=False):
    """
    This function ensures that both DataFrames have the same columns and indexes.
    If a column or index in df1 is missing in df2, it will be added to df2.
    If with_nonzero is True, missing rows are filled with the previous row's data, otherwise, they are filled with None.

    Parameters:
    df1: The first DataFrame, serving as the reference.
    df2: The second DataFrame, which will be completed.
    with_nonzero: If True, rows missing from df2 will be filled with the previous row's values.
    
    Returns:
    df2: The modified DataFrame, with missing columns and indexes from df1 added and NaNs filled with 0.
    """
    
    # Include columns from df1 in df2 if they don't exist in df2
    COLUMNS1 = df1.columns
    COLUMNS2 = df2.columns

    for C1 in COLUMNS1:
        if C1 not in COLUMNS2:
            df2[C1] = None  # Add missing columns to df2
    
    # Include indexes from df1 in df2 if they don't exist in df2
    INDEX1 = df1.index
    INDEX2 = df2.index

    for I1 in INDEX1:
        if I1 not in INDEX2:
            if with_nonzero:
                # If the index is missing, add it and fill it with previous row's data
                df2.loc[I1] = None
                df2 = df2.sort_index()
                Idx = np.where(df2.index == I1)[0][0]
                if Idx != 0:
                    df2.loc[I1] = df2.iloc[Idx-1, :]  # Fill missing row with previous row
                else:
                    df2.loc[I1] = df2.iloc[Idx+1, :]  # If it's the first row, use the next row
            else:
                df2.loc[I1] = None  # If with_nonzero is False, fill with None

    # Sort the index of df2 and fill NaN values with 0
    df2 = df2.sort_index()
    df2 = df2.fillna(0)
    return df2

# Update the plot settings with custom parameters for better readability
params = {'legend.fontsize': 14,
          'figure.figsize': (20, 16),
          'axes.labelsize': 12,
          'axes.titlesize': 12,
          'xtick.labelsize': 10,
          'ytick.labelsize': 10}
plt.rcParams.update(params)

# Load the CSV file containing COVID-19 data from São Paulo
df = pd.read_csv("cov_SP2024-jan-26-jun.csv", sep=",", index_col=False)

# Filter only the relevant columns (country, date of collection, and clade)
df = df[['pais', 'collection_date', 'clado']]

# Reset the DataFrame index
df.reset_index(drop=True, inplace=True)

# Convert the 'collection_date' column to datetime format
df['collection_date'] = pd.to_datetime(df['collection_date'])

# Create a list of unique values from the 'pais' column (locations)
UPA = list(set(df['pais'].values))
UPA = [i for i in UPA if i == i]  # Filter out NaN values
UPA.sort()  # Sort the list alphabetically

# Group the data by month and clade and count occurrences
df1 = df[['collection_date', 'clado']]
df1['month'] = df1['collection_date'].dt.to_period('M')  # Convert dates to periods by month
df1 = df1.groupby(['month', 'clado']).size().unstack(fill_value=0)  # Group by month and clade, fill missing values with 0

# Count occurrences of each clade in the dataset
contagem_clado = df['clado'].value_counts()
print(contagem_clado)

# Re-group data by month and clade (duplicate of above code, may not be necessary)
df['collection_date'] = pd.to_datetime(df['collection_date'])
df1 = df[['collection_date', 'clado']]
df1['month'] = df1['collection_date'].dt.to_period('M')
df1 = df1.groupby(['month', 'clado']).size().unstack(fill_value=0)

# Define the colors for each clade in the plot
unique_clades = set(df['clado'])
clade_color_dict = {"23I": "#8dd3c7", "recombinant": "#ffffb3", "23A": "#bebada", "23G": "#fb8072", 
                    "23F": "#80b1d3", "23E": "#fdb462", "23H": "#b3de69", "22E": "#fccde5", "21K": "#d9d9d9"}

# Create a figure for the plot
fig, ax = plt.subplots(figsize=(16, 12))

# Calculate the frequency of each clade per month as a percentage
freq_por_mes = df1.T / df1.sum(axis=1) * 100  # Calculate percentages
freq_por_mes = freq_por_mes.T

# Prepare the labels for the x-axis (dates) and colors for the plot
days = [str(month) for month in freq_por_mes.index]  # Convert month periods to strings for plotting
clade_colors = [clade_color_dict.get(c, "#333333") for c in freq_por_mes.columns]  # Use clade colors, default to grey if not found

# Plot a stacked area plot showing the frequency of clades over time
lines = ax.stackplot(days, freq_por_mes.T.values, labels=freq_por_mes.columns, colors=clade_colors)

# Get handles and labels for the legend
h, l = ax.get_legend_handles_labels()
handle_dict = {label: handle for handle, label in zip(h, l)}

# Set plot titles and labels
ax.set_title("São Paulo")
ax.set_xlabel('Date')
ax.tick_params(axis='x', rotation=45)  # Rotate x-axis labels for better readability
ax.set_ylabel('Frequency (%)')

# Set y-axis limits to ensure the percentage scale goes from 0 to 100
ax.set_ylim(0, 100)

# Add a legend below the plot
fig.legend(handles=list(handle_dict.values()), labels=list(handle_dict.keys()), 
           loc='lower center', bbox_to_anchor=(0.5, -0.05), ncol=len(unique_clades), fontsize='14')

# Save the figure as a PDF
fig.savefig("cov_SP_2024.pdf", dpi=300, bbox_inches='tight')

# Display the plot
plt.show()
