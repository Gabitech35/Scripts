# Import necessary libraries
import pandas as pd  # For data manipulation and analysis
import matplotlib.pyplot as plt  # For plotting graphs
import numpy as np  # For numerical operations

# Function to ensure that the second DataFrame (df2) includes all columns and indexes from the first (df1)
def complete_dataframe(df1=None, df2=None, with_nonzero=False):
    # Get columns from df1 and df2
    COLUMNS1 = df1.columns
    COLUMNS2 = df2.columns

    # Add missing columns from df1 to df2
    for C1 in COLUMNS1:
        if C1 not in COLUMNS2:
            df2[C1] = None
    
    # Get indexes from df1 and df2
    INDEX1 = df1.index
    INDEX2 = df2.index

    # Add missing indexes from df1 to df2, with optional interpolation
    for I1 in INDEX1:
        if I1 not in INDEX2:
            if with_nonzero:
                df2.loc[I1] = None  # Add missing index to df2
                df2 = df2.sort_index()  # Sort the DataFrame by index
                # Get index location of the new row
                Idx = np.where(df2.index == I1)[0][0]
                # If the index is not the first row, copy values from the previous row
                if Idx != 0:
                    df2.loc[I1] = df2.iloc[Idx - 1, :]
                else:
                    df2.loc[I1] = df2.iloc[Idx + 1, :]
            else:
                df2.loc[I1] = None  # Otherwise, set the missing row as None
    df2 = df2.sort_index()  # Sort the DataFrame again
    df2 = df2.fillna(0)  # Replace NaN values with 0
    return df2

# Configuration of parameters for the plots
params = {
    'legend.fontsize': 14,  # Font size for the legend
    'figure.figsize': (20, 10),  # Size of the figure
    'axes.labelsize': 12,  # Font size for axis labels
    'axes.titlesize': 12,  # Font size for the title
    'xtick.labelsize': 10,  # Font size for x-axis tick labels
    'ytick.labelsize': 10  # Font size for y-axis tick labels
}
plt.rcParams.update(params)  # Update plot parameters

# Load the DataFrame from a CSV file
df = pd.read_csv("result_metadata_final_graficos_estado_com_UPAS.csv", sep=",", index_col=False)
df

# Select only relevant columns: 'estado', 'date', and 'short-clade'
df = df[['estado', 'date', 'short-clade']]
df.reset_index(drop=True, inplace=True)  # Reset the DataFrame index
df['date'] = pd.to_datetime(df['date'])  # Convert 'date' column to datetime format

# Define the desired date range
start_date = pd.Period('2023-04', freq='M')  # Start in April 2023
end_date = pd.Period('2024-05', freq='M')  # End in May 2024
all_months = pd.period_range(start=start_date, end=end_date, freq='M')  # Generate a range of months

# Group the data by month and clade (variant) and count occurrences
df['month'] = df['date'].dt.to_period('M')  # Extract the month from the 'date' column
df1 = df.groupby(['month', 'short-clade']).size().unstack(fill_value=0)  # Count occurrences by clade per month

# Reindex the DataFrame to ensure all months in the range are included, even if no data exists for some
df1 = df1.reindex(all_months, fill_value=0)

# Ensure all clades (variants) are included as columns
df1 = df1.reindex(columns=df1.columns.union(df['short-clade'].unique()))

# Define colors for each clade (variant) for the plot
unique_clades = set(df['short-clade'])  # Get the unique clades (variants)
clade_color_dict = {
    "5a.2a.1": "#8dd3c7",  # Light teal for clade 5a.2a.1
    "5a.2a": "#fccde5",  # Pink for clade 5a.2a
    "6B": "#bebada",  # Lavender for clade 6B
    "6B.1A": "#fb8072",  # Coral for clade 6B.1A
    "5a.1": "#80b1d3"  # Light blue for clade 5a.1
}

# Create the figure and axes with specified size
fig, ax = plt.subplots(figsize=(16, 8))  # Set figure size to 16 inches wide, 8 inches tall

# Calculate the frequency of each clade by month in percentage
freq_por_mes = df1.T / df1.sum(axis=1) * 100  # Calculate percentages
freq_por_mes = freq_por_mes.T  # Transpose back

# Get the month labels and corresponding colors for the clades
days = [str(month) for month in freq_por_mes.index]  # Convert month objects to string for plotting
clade_colors = [clade_color_dict.get(c, "#333333") for c in freq_por_mes.columns]  # Assign colors to each clade

# Create a stacked area plot of clade frequencies over time
lines = ax.stackplot(days, freq_por_mes.T.values, labels=freq_por_mes.columns, colors=clade_colors)

# Get handles and labels for the legend (to show the clade names)
h, l = ax.get_legend_handles_labels()
handle_dict = {label: handle for handle, label in zip(h, l)}

# Set the title and axis labels with appropriate font sizes
ax.set_title("São Paulo State", fontsize=20)  # Set plot title
ax.set_xlabel('Date', fontsize=16)  # Label for x-axis
ax.tick_params(axis='x', rotation=45)  # Rotate x-axis labels for better readability
ax.set_ylabel('Frequency (%)', fontsize=16)  # Label for y-axis

# Ensure y-axis limits are from 0% to 100%
ax.set_ylim(0, 100)

# Add a legend to the plot with the clades (variants) listed
fig.legend(handles=list(handle_dict.values()), labels=list(handle_dict.keys()), loc='lower center', bbox_to_anchor=(0.5, -0.09), ncol=len(unique_clades), fontsize='14')

# Save the figure as a high-resolution PDF
fig.savefig("flu_sp_state_2024.pdf", dpi=400, bbox_inches='tight')

# Display the plot
plt.show()
