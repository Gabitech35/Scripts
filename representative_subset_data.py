from IPython.core.display import display, HTML
display(HTML("<style>.container { width:100% !important; }</style>"))
# Adjusts the display width of Jupyter notebooks to 100% of the container width for better visualization

import pandas as pd
import numpy as np

# Load the spreadsheet
global_G = pd.read_csv('lineage_AY_43.tsv', sep='\t')
# Reads a tab-separated values (TSV) file into a DataFrame named 'global_G'

# View the header of the DataFrame
global_G.columns
# Displays the column names of the DataFrame

# Apply filters to select rows with high coverage
global_High = (global_G['Is high coverage?'] == True)
# Creates a boolean Series where True indicates high coverage
global_High = global_G.iloc[np.where(global_High == True)[0]]
# Selects rows from 'global_G' where the coverage is high

# Split the 'Location' column into two separate columns
global_High["Location"] = global_High["Location"].str.split("/", n=1, expand=True)
# Splits the 'Location' column at the first occurrence of '/' into two columns

# Group by 'Location' and sample a fraction of rows
frac = global_High.groupby('Location', group_keys=False).apply(pd.DataFrame.sample, frac=.02, random_state=1)
# Groups the DataFrame by 'Location', samples 2% of rows from each group, and ensures reproducibility with a fixed random seed

# View the quantity of locations
frac.groupby('Location').size()
# Displays the size of each group in the sampled DataFrame

# Save the result to a TSV file
frac.to_csv('result_AY43.tsv', sep='\t', index=False)
# Saves the sampled DataFrame to a TSV file without including row indices
