# Install required packages
pip install tabula-py pandas

# Import necessary packages
import tabula  # For extracting tables from PDF files
import pandas as pd  # For handling data in DataFrames

# Path to the PDF file
pdf_path = "ECDC_2023_february.pdf"  # Specify the path to your PDF file

# Page number that contains the table
page_number = 21  # Replace with the desired page number

# Extracting tables from the specified page
tables = tabula.read_pdf(pdf_path, pages=page_number, multiple_tables=True)
# 'read_pdf' function reads tables from the specified page of the PDF; 'multiple_tables=True' allows for extraction of multiple tables

# Checking if any tables were found
if tables:
    # Assuming the desired table is the first one found on the page
    df = tables[0]  # Get the first table from the list of extracted tables
    
    # Saving the extracted table to a CSV file
    df.to_csv("planilha_extraida_21.csv", index=False)  # Save the DataFrame as a CSV file without row indices
    print("Table extracted successfully and saved as 'planilha_extraida_21.csv'.")
else:
    print("No table found on the specified page.")
