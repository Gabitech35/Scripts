# Import necessary libraries
import pandas as pd  # For data manipulation and analysis
import matplotlib.pyplot as plt  # For creating plots and visualizations
import seaborn as sns  # For advanced data visualization and plotting

# Set the style of the plots to "whitegrid" for a clean background with gridlines
sns.set(style="whitegrid")

# Define colors and line thickness for each laboratory
palette = {'IAL': '#1f78b4', 'IB': '#33a02c'}  # Colors for 'IAL' and 'IB'
linewidth = {'IAL': 2.5, 'IB': 2.5}  # Line thickness for 'IAL' and 'IB'

# Plot the line chart
plt.figure(figsize=(10, 6))  # Set the size of the figure (width: 10, height: 6)
sns.lineplot(data=d1, x="Collection Date", y="Samples", hue="LAB", marker="o", palette=palette, linewidth=2.5)
# Create a line plot using Seaborn with markers, custom colors, and line thickness

# Adjust the chart
plt.xticks(rotation=45, ha='right')  # Rotate x-axis labels 45 degrees and align to the right
plt.xlabel('Collection Date', labelpad=15)  # Set x-axis label with extra space from the axis
plt.ylabel('Number of Samples')  # Set y-axis label

# Adjust the y-axis ticks
plt.yticks(range(0, 55, 5))  # Set y-axis ticks to range from 0 to 50 with a step of 5

# Set the chart title, enable gridlines, and add a legend with title
plt.title('Samples by Collection Date for IAL and IB')
plt.grid(True)
plt.legend(title='Lab')

# Save the chart as a PNG file with high resolution and tight bounding box
plt.savefig('samples_by_collection_date_ail_ib.png', dpi=400, bbox_inches='tight')

# Display the chart
plt.show()
