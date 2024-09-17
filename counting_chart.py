# Import necessary libraries and parameters
import pandas as pd  # Used for data manipulation and analysis
import matplotlib.pyplot as plt  # Used for data visualization and plotting
import numpy as np  # Used for numerical operations

# Example DataFrame with fictitious data
data = {
    'SP Municipalities - UPAS': [52],  # Number of samples from SP Municipalities - UPAS
    'SP State': [51],  # Number of samples from SP State
    'Brazil': [439],  # Number of samples from Brazil as a whole
}

# Create a DataFrame using the above data dictionary
df = pd.DataFrame(data)

# Total count of samples per UPA (Urgent Care Unit)
contagem = df.sum()  # Sum all the values for each category (SP Municipalities, SP State, and Brazil)

# Calculate the percentage of each UPA in relation to the total sample count
total_samples = [526]  # Define the total number of samples
porcentagem = (contagem / total_samples) * 100  # Calculate the percentage for each category

# Create a bar plot to visualize the sample counts
plt.figure(figsize=(10, 6))  # Set the figure size (width: 10, height: 6)
bars = contagem.plot(kind='bar', color=['#1f78b4', '#e5c494', '#b3b3b3'])  # Create a bar chart with different colors

# Set the title of the chart
plt.title('5a.2a Samples Count per Municipalities, State and Brazil')

# Set the label for the y-axis (uncomment if needed for x-axis)
# plt.xlabel('Urgent Care Unit')  # Label for the x-axis
plt.ylabel('Total Samples')  # Label for the y-axis (total number of samples)

# Rotate the labels on the x-axis for better readability
plt.xticks(rotation=45)

# Add the percentage value on top of each bar
for bar, percent in zip(bars.patches, porcentagem):  # Iterate through bars and their corresponding percentages
    height = bar.get_height()  # Get the height of each bar
    plt.text(bar.get_x() + bar.get_width() / 2, height, f'{percent:.1f}%', ha='center', va='bottom')  
    # Add text with the percentage above each bar, centered horizontally (ha='center') and positioned at the bottom of the bar (va='bottom')

# Save the figure as a PDF with high resolution (400 dpi) and ensure that all elements fit tightly
plt.savefig('contagem_amostras_M_S_C.pdf', format='pdf', dpi=400, bbox_inches='tight')

# Display the plot
plt.show()
