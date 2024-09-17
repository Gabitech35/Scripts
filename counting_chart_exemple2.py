# Import necessary libraries
import pandas as pd  # For data manipulation and analysis
import matplotlib.pyplot as plt  # For creating plots and visualizations
import numpy as np  # For numerical operations (though not used in this code)

# Example DataFrame with fictitious data
data = {
    'UPA BUTANTA': [35],  # Number of samples from UPA Butanta
    'UPA VERGUEIRO': [7],  # Number of samples from UPA Vergueiro
    'UPA TITO LOPES': [15],  # Number of samples from UPA Tito Lopes
    'UPA TATUAPE': [15],  # Number of samples from UPA Tatuape
    'UPA MARIA ANTONIETA': [24],  # Number of samples from UPA Maria Antonieta
    'UPA JACANA': [54],  # Number of samples from UPA Jacana
    'SP State': [82],  # Number of samples from SP State
    'Brazil': [908],  # Number of samples from Brazil
}

# Create a DataFrame using the above data dictionary
df = pd.DataFrame(data)

# Calculate the total count of samples for each category (UPAs, SP State, and Brazil)
contagem = df.sum()  # Sum the values for each column

# Calculate the percentage of each UPA and other categories in relation to the total sample count
total_samples = contagem.sum()  # Sum of all samples across all categories
porcentagem = (contagem / total_samples) * 100  # Calculate the percentage for each category

# Create a bar plot to visualize the sample counts
plt.figure(figsize=(10, 6))  # Set the size of the figure (width: 10, height: 6)
bars = contagem.plot(kind='bar', color=['#66c2a5', '#fc8d62', '#8da0cb', '#e78ac3', '#a6d854', '#ffd92f', '#e5c494', '#b3b3b3'])  
# Plot the bar chart with different colors for each bar

# Set the title of the chart
plt.title('Samples Count per UPA, São Paulo State and Brazil')

# Set the label for the y-axis
plt.ylabel('Total Samples')

# Rotate the x-axis labels for better readability
plt.xticks(rotation=45)

# Add the percentage value on top of each bar
for bar, percent in zip(bars.patches, porcentagem):  # Iterate through each bar and its corresponding percentage
    height = bar.get_height()  # Get the height of each bar
    plt.text(bar.get_x() + bar.get_width() / 2, height, f'{percent:.1f}%', ha='center', va='bottom')
    # Add text with the percentage above each bar, centered horizontally and positioned at the bottom of the bar

# Save the figure as a PDF with high resolution (400 dpi) and ensure that all elements fit tightly
plt.savefig('contagem_amostras_upa_estado_brazil.pdf', format='pdf', dpi=400, bbox_inches='tight')

# Display the plot
plt.show()
