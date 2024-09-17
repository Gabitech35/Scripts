import pandas as pd

# Load data from CSV and Excel files
ids = pd.read_csv('All_SEQ_studo.csv', sep = ',')  # Load sequence data from a CSV file
banco = pd.read_excel('BANCO-BIOINFO_PILOTO_LABMOVEL_DELTA-OMICRON_SEM-VACINA_vs_COMPLETO_27-01-2023.xlsx')  # Load additional metadata from an Excel file

# Merge the two datasets based on common columns
result = pd.merge(ids, banco, how="inner", left_on='IDENTIFICADOR', right_on='hashcode')
# Perform an inner join to combine rows where 'IDENTIFICADOR' in 'ids' matches 'hashcode' in 'banco'

# Identify missing samples
# Merge with how="left" to keep all rows from 'ids'
result_left = pd.merge(ids, banco, how="left", left_on='IDENTIFICADOR', right_on='hashcode')

# Filter rows where there was no match (i.e., 'hashcode' is NaN)
amostras_sem_match = result_left[result_left['hashcode'].isna()]

# Display samples with no match
print(amostras_sem_match[['IDENTIFICADOR']])

# Save the merged result to a CSV file
result.to_csv('METADADOS_SEQ_SELECIONADOS_PARA_ESTUDO.csv', index = False, sep = ',')
