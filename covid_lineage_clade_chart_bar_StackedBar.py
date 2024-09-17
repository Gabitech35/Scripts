# Import necessary libraries
import pandas as pd  # For data manipulation and analysis
import seaborn as sns  # For advanced data visualization and plotting
import matplotlib.pyplot as plt  # For creating plots and visualizations

# Load the dataset from a CSV file
df = pd.read_csv('para_count.csv', sep = ",")  # Read the CSV file into a DataFrame

# Display the first few rows of the DataFrame to ensure data is loaded correctly
print(df.head())

# Group by 'Pangolin_lineage' and 'Clade' and count occurrences
result = df.groupby(['Pangolin_lineage', 'Clade']).size().reset_index(name='Count')
# Create a DataFrame with counts of each combination of Pangolin_lineage and Clade

# Create a pivot table with 'Pangolin_lineage' as columns and 'Clade' as rows, filling missing values with 0
result2 = df.groupby(['Pangolin_lineage', 'Clade']).size().unstack(fill_value=0)

# Create a pivot table with 'Clade' as columns and 'Pangolin_lineage' as rows, filling missing values with 0
result3 = df.groupby(['Clade', 'Pangolin_lineage']).size().unstack(fill_value=0)

# Display the result DataFrames
print(result)
print(result2)

# Create a bar plot to show the count of lineages by clade
plt.figure(figsize=(10, 6))  # Set the size of the figure (width: 10, height: 6)
sns.barplot(x='Clade', y='Count', data=result, ci=None)  
# Plot a bar chart with 'Clade' on the x-axis and 'Count' on the y-axis

# Adjust the labels and title of the bar plot
plt.title('Count of Lineages by Clade')  # Title of the plot
plt.xlabel('Clade')  # Label for the x-axis
plt.ylabel('Number of Samples')  # Label for the y-axis

# Display the bar plot
plt.xticks(rotation=45)  # Rotate x-axis labels 45 degrees for better readability
plt.tight_layout()  # Adjust layout to fit all elements
plt.show()  # Show the plot

# Create a heatmap to show the correspondence between Pangolin lineage and Clade
plt.figure(figsize=(12, 8))  # Set the size of the figure (width: 12, height: 8)
sns.heatmap(result2, annot=True, cmap='Blues', fmt='d')  
# Plot a heatmap with annotations and a blue color map

# Adjust the labels and title of the heatmap
plt.title('Correspondence between Pangolin Lineage and Clade')  # Title of the plot
plt.xlabel('Clade')  # Label for the x-axis
plt.ylabel('Pangolin Lineage')  # Label for the y-axis

# Display the heatmap
plt.tight_layout()  # Adjust layout to fit all elements
plt.show()  # Show the plot

# Create a stacked bar plot to show the count of lineages by clade
result3.plot(kind='bar', stacked=True, figsize=(12, 8))  
# Plot a stacked bar chart with 'Clade' on the x-axis and counts of lineages stacked in bars

# Adjust the labels and title of the stacked bar plot
plt.title('Correspondence between Lineage and Clades')  # Title of the plot
plt.xlabel('Clades')  # Label for the x-axis
plt.ylabel('Number of Samples')  # Label for the y-axis

# Adjust the y-axis ticks and limits
plt.yticks(range(0, 131, 10))  # Set y-axis ticks from 0 to 130 with a step of 10

# Adjust the legend to be horizontal and positioned below the plot
plt.legend(title='', bbox_to_anchor=(0.5, -0.35), loc='upper center', ncol=8)
plt.tight_layout()  # Adjust layout to fit all elements

# Save the stacked bar plot as a PNG file with high resolution
plt.savefig('Correspondence_pangolin_clado.png', dpi=400, bbox_inches='tight')

# Display the stacked bar plot
plt.show()
