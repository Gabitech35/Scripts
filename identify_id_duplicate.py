# Import the pandas library for data manipulation
import pandas as pd

# Load data from an Excel file into a DataFrame
df = pd.read_excel('gisaid_epiflu_isolates.xls')

# Identify duplicate entries in the 'CEVIVAS_ID' column
duplicados = df[df.duplicated('CEVIVAS_ID', keep=False)]
# 'keep=False' marks all duplicates as True, including the first occurrence

# Extract unique duplicated 'CEVIVAS_ID' values
duplicados_cevivas_id = duplicados['CEVIVAS_ID'].unique()

# Print the duplicated 'CEVIVAS_ID' values
print("Duplicated strings in the 'CEVIVAS_ID' column:")
for item in duplicados_cevivas_id:
    print(item)

# Print the rows containing duplicate 'CEVIVAS_ID' values
print("Rows containing duplicates in the 'CEVIVAS_ID' column:")
display(duplicados)
