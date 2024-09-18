# Import necessary packages and set parameters

import pandas as pd  # Used for data manipulation and analysis
import numpy as np  # For numerical operations
import glob  # To handle file pattern matching
from Bio import SeqIO  # Biopython module for handling biological sequence data
import os  # For interacting with the operating system, such as file handling

# Create a list of Excel files from a specific directory using pattern matching
file_paths = glob.glob('/home/gabriela/Documentos/REDE_influenza/SOLICITACOES/ISABELA/lacen-ba/h3n2/metadados/*.xls')

# Read and concatenate all Excel files into a single DataFrame
dfs = [pd.read_excel(file) for file in file_paths]
combined_df = pd.concat(dfs, ignore_index=True)  # Concatenate DataFrames into one

# Save the combined DataFrame into a new Excel file
combined_df.to_excel('combined_data_gisaid.xls', index=False)

# Select necessary columns from the combined DataFrame
df = combined_df[['Isolate_Id', 'Collection_Date', 'Location']]

# Split the 'Location' column using '/' as the delimiter, creating multiple new columns
split_cols = df['Location'].str.split('/', expand=True)

# Dynamically rename the new columns based on the number of parts in the split
num_cols = split_cols.shape[1]  # Get the number of split parts
column_names = [f'Part_{i+1}' for i in range(num_cols)]  # Create dynamic column names
split_cols.columns = column_names  # Assign the new names to the columns

# Concatenate the new columns back to the original DataFrame
df = pd.concat([df, split_cols], axis=1)

# Rename specific columns for clarity (adjust these names based on the dataset)
df.rename(columns={
    'Part_1': 'Continent',
    'Part_2': 'Country', 
    'Part_3': 'State',  # Adjust if relevant to the data
    'Part_4': 'City',
    'Part_5': 'District'  # Adjust if relevant to the data
}, inplace=True)

# Convert the 'Collection_Date' column to datetime format for easier date manipulation
df['Collection_Date'] = pd.to_datetime(df['Collection_Date'])

# Standardize the naming of continents (removing extra spaces, capitalizing)
df['Continent'] = df['Continent'].str.strip().str.title()

# Check sample counts by continent and year after the standardization
print("Sample counts by continent and year after standardization:")
print(df.groupby([df['Collection_Date'].dt.year, 'Continent']).size())

# Define the years to sample data from
years = [2020, 2021, 2022, 2023, 2024]

# Function to sample at least a minimum number of samples from each continent
def sample_by_continent(df, continent, min_samples=100, fraction=0.05):
    df_continent = df[df['Continent'] == continent]  # Filter by continent
    num_samples = len(df_continent)  # Count samples

    # If the number of samples is less than or equal to the minimum, return all samples
    if num_samples <= min_samples:
        return df_continent
    else:
        # Otherwise, sample by a fraction of the data
        sampled = df_continent.sample(frac=fraction)
        # Ensure at least the minimum number of samples is selected
        if len(sampled) < min_samples:
            return df_continent.sample(n=min_samples)
        return sampled

# Function to sample at least 5 samples from each year
def sample_by_year(df, year, min_samples=5):
    df_year = df[df['Collection_Date'].dt.year == year]  # Filter by year
    num_samples = len(df_year)  # Count samples

    # If the number of samples is less than or equal to the minimum, return all samples
    if num_samples <= min_samples:
        return df_year
    else:
        # Otherwise, sample a fixed number of samples
        return df_year.sample(n=min_samples)

# Sample by continent, creating a list of continent samples
continents = df['Continent'].unique()  # Get unique continents
continent_samples = []

# Loop through each continent and sample data
for continent in continents:
    df_continent = df[df['Continent'] == continent]  # Filter for specific continent

    # Skip if no data is available for the continent
    if df_continent.empty:
        print(f'No data for continent {continent}')
        continue

    yearly_samples = []
    
    # Loop through the years and sample for each continent and year
    for year in years:
        df_year = df_continent[df_continent['Collection_Date'].dt.year == year]
        
        # If no data for the year, skip
        if df_year.empty:
            print(f'No data for continent {continent} in year {year}')
        else:
            yearly_samples.append(sample_by_year(df_continent, year))
    
    # Combine the samples for each year and add them to the continent samples
    if yearly_samples:
        yearly_samples = pd.concat(yearly_samples)

        # Ensure at least 100 samples per continent
        num_samples = len(yearly_samples)
        if num_samples < 100:
            continent_samples.append(df_continent.sample(n=100, replace=True))
        else:
            continent_samples.append(yearly_samples)

# Concatenate the samples from all continents
if continent_samples:
    final_df = pd.concat(continent_samples)
    # Save the final sample data to a CSV file
    final_df.to_csv('gisaid_select.csv', index=False)
else:
    print('No samples selected for any continent.')

# Define directory containing FASTA files
input_dir = '/home/gabriela/Documentos/REDE_influenza/SOLICITACOES/ISABELA/lacen-ba/h3n2/fasta/'
output_file = '/home/gabriela/Documentos/REDE_influenza/SOLICITACOES/ISABELA/lacen-ba/h3n2/arquivo_selecionado.fasta'
concatenated_file = '/home/gabriela/Documentos/REDE_influenza/SOLICITACOES/ISABELA/lacen-ba/h3n2/concatenated.fasta'
tratado_file = '/home/gabriela/Documentos/REDE_influenza/SOLICITACOES/ISABELA/lacen-ba/h3n2/arquivo_tratado.fasta'

# List all FASTA files in the directory
fasta_files = [f for f in os.listdir(input_dir) if f.endswith('.fasta') or f.endswith('.fa')]

# Concatenate all FASTA files into a single file
with open(concatenated_file, 'w') as outfile:
    for fasta_file in fasta_files:
        file_path = os.path.join(input_dir, fasta_file)
        for record in SeqIO.parse(file_path, 'fasta'):
            SeqIO.write(record, outfile, 'fasta')

print(f'FASTA files concatenated into {concatenated_file}')

# Process the concatenated file to adjust the sequence headers
with open(tratado_file, 'w') as outfile:
    for record in SeqIO.parse(concatenated_file, 'fasta'):
        # Adjust the ID in the header (extracts the 3rd part of the ID)
        new_id = record.id.rsplit('|')[-3]
        record.id = new_id
        record.description = ''  # Remove the description
        SeqIO.write(record, outfile, 'fasta')

print(f'Treated FASTA file saved to {tratado_file}')

# Extract IDs of isolates to be selected from the DataFrame
isolate_ids = final_df['Isolate_Id'].unique()
print(f'Isolate IDs to be extracted: {isolate_ids}')

# Dictionary to store selected sequences
selected_sequences = {}

# Read the processed FASTA file and filter the sequences by the isolate IDs
with open(tratado_file, 'r') as infile:
    for record in SeqIO.parse(infile, 'fasta'):
        record_id = record.id
        # If the ID matches one of the isolate IDs, add the sequence to the dictionary
        if record_id in isolate_ids:
            selected_sequences[record_id] = record
            print(f'Sequence {record_id} found and added.')

# Check if any sequences were found
if not selected_sequences:
    raise ValueError('No matching sequences found in the processed file.')

# Write the selected sequences to a new FASTA file
with open(output_file, 'w') as outfile:
    for record_id in isolate_ids:
        if record_id in selected_sequences:
            SeqIO.write(selected_sequences[record_id], outfile, 'fasta')

print(f'Selected sequences saved to {output_file}')

# Reprocess the concatenated file, adjusting headers based on the DataFrame columns
with open(tratado_file, 'w') as outfile:
    for record in SeqIO.parse(concatenated_file, 'fasta'):
        # Extract the isolate ID from the header
        isolate_id = record.id.rsplit('|')[-3]
        
        # Filter the DataFrame to find the matching record
        row = final_df[final_df['Isolate_Id'] == isolate_id]
        
        if not row.empty:
            # Extract relevant information from the DataFrame
            collection_date = row['Collection_Date'].iloc[0].strftime('%Y-%m-%d')
            continent = row['Continent'].iloc[0]
            country = row['Country'].iloc[0]
            state = row['State'].iloc[0]
            
            # Create a new ID for the sequence in the desired format
            new_id = f"{isolate_id}|flu|ha|{isolate_id}|{collection_date}|{continent}|{country}|{state}"
            record.id = new_id
            record.description = ''  # Remove the description
            SeqIO.write(record, outfile, 'fasta')

print(f'Treated and renamed FASTA file saved to {tratado_file}')
