# Import necessary libraries
import pandas as pd  # For data manipulation and analysis
import matplotlib.pyplot as plt  # For creating plots and visualizations
import numpy as np  # For numerical operations, specifically to create an array of positions for bars

# Create a DataFrame with sample data
data = {
    '5a.2a': [29],  # Number of samples for category '5a.2a'
    '5a.2a.1': [121],  # Number of samples for category '5a.2a.1'
}

df = pd.DataFrame(data)  # Convert the data dictionary into a DataFrame

# Calculate the total count of samples for each category
contagem = df.sum()  # Sum the values for each column in the DataFrame

# Calculate the percentage of each category relative to the total number of samples
total_samples = 150  # Define the total number of samples
porcentagem = (contagem / total_samples) * 100  # Compute the percentage for each category

# Create a bar chart to visualize the percentage of samples
plt.figure(figsize=(6, 6))  # Set the size of the figure (width: 6, height: 6)

# Define the positions of the bars on the X-axis
positions = np.arange(len(contagem))  # Create an array of positions for the bars

# Plot the bars with the calculated percentages
bars = plt.bar(positions, porcentagem, color=['#fccde5','#8dd3c7'], width=0.9)  
# Use different colors for the bars and set the width of the bars

# Set the title and labels for the chart
plt.title('Samples Count per Municipalities')  # Title of the chart
plt.ylabel('Percentage of Total Samples')  # Label for the y-axis
plt.ylim(0, 100)  # Set the limit of the y-axis to range from 0 to 100

# Set the X-axis ticks to the names of the columns and rotate them for better readability
plt.xticks(positions, contagem.index, rotation=45)

# Add the absolute number of samples above each bar
for bar, count in zip(bars, contagem):  # Iterate through each bar and its corresponding count
    height = bar.get_height()  # Get the height of each bar
    plt.text(bar.get_x() + bar.get_width() / 2, height + 1, f'{count:.0f}', ha='center', va='bottom')
    # Add text with the absolute count above each bar, centered horizontally and positioned just above the bar

# Save the plot as a high-resolution PDF file
plt.savefig('contagem_amostras_Municipalities.pdf', format='pdf', dpi=400, bbox_inches='tight')

# Display the plot
plt.show()
