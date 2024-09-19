import os
import argparse

def main():
    
    # Set up the argument parser with a description and default formatting
    parser = argparse.ArgumentParser(description='rename', formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    # Define the command-line arguments required for the script
    parser.add_argument('--input', required=True, type=str, help='A .csv file with address column', default=None)
    parser.add_argument('--list', required=True, type=str, help='A .csv file with address column', default=None)
    parser.add_argument('--output', required=True, type=str, help='Output file name', default=None)
    
    # Parse the command-line arguments
    args = parser.parse_args()
    
    # Print the parsed arguments (for debugging purposes)
    print(args)
    
    # Initialize an empty dictionary to store the mapping
    pattern = {}

    # Open the file specified by '--list' argument and read its contents
    with open(args.list, "r") as list_file:
        
        # Iterate over each line in the file
        for line in list_file:
            line = line.rstrip()  # Remove trailing whitespace characters
            aux = line.split("\t")  # Split the line by tab character
            pattern[aux[0]] = aux[1]  # Populate the dictionary with key-value pairs
    # Print the dictionary to check its contents
    print(pattern)
    
    # Open the input file specified by '--input' argument for reading
    with open(args.input) as input_file:
        # Open the output file specified by '--output' argument for writing
        output_file = open(args.output, "w")
        
        # Iterate over each line in the input file
        for line in input_file:
            line = line.rstrip()  # Remove trailing whitespace characters

            # Check if the line contains a '>' character
            if line.find(">") != -1:
                # Extract the part after '>'
                aux = line.split(">")[1]
                # Write the corresponding value from the dictionary to the output file
                output_file.write(">" + pattern[aux])
            else:
                # Write the line as is to the output file
                output_file.write(line)
            # Write a newline character to the output file
            output_file.write("\n")

        # Close the output file
        output_file.close()

# Ensure that the main function runs if the script is executed directly
if __name__ == "__main__":
    main()
    exit()
