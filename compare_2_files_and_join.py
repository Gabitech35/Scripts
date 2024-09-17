# Import the Pandas library for data manipulation
import pandas as pd

# Load the Excel and CSV files into dataframes
df1 = pd.read_excel('file.xls', sheet_name='sheet1')  # Load the 'sheet1' sheet from the Excel file
df2 = pd.read_csv('file.csv', sep=',')  # Load the CSV file using a comma as the delimiter

# Perform a left merge on 'ID' from df1 and 'ID2' from df2
result = pd.merge(df1, df2, how="left", left_on='ID', right_on='ID2')

# Save the resulting merged dataframe as a TSV file
result.to_csv('result.tsv', index=False, sep='\t')
