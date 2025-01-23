import json
import os
import pandas as pd
from datetime import datetime

######## Step 1: Choose file for analysis ########
base_path = os.path.join(os.getcwd(), "raw_data")

# List of files to process
files = ["receipts.json", "users.json", "brands.json"]

# User selects the file to process
print("Available files to process:")
for i, file_name in enumerate(files, start=1):
    print(f"{i}. {file_name}")

choice = int(input("\nEnter the number corresponding to the file you want to process: "))

if choice < 1 or choice > len(files):
    print("Invalid choice. Please try again.")

selected_file = files[choice - 1]

file_path = os.path.join(base_path, selected_file)
print(f"\nProcessing file: {file_name}")

######## Step 2: Load the JSON file line by line ########
data = []
with open(file_path, 'r') as f:
    for line in f:
        try:
            record = json.loads(line)

            # Extract $oid value from _id
            if isinstance(record.get('_id'), dict) and '$oid' in record['_id']:
                record['_id'] = record['_id']['$oid']
            
            # Convert all "$date" fields to human-readable format. Convert to date rather than timestamp for easier grouping analysis
            for key, value in record.items():
                if isinstance(value, dict) and "$date" in value:
                    record[key] = datetime.utcfromtimestamp(value["$date"] / 1000).strftime('%Y-%m-%d')
            
            data.append(record)
        except json.JSONDecodeError:
            print(f"Skipping invalid line: {line}")
            continue  # Skip lines with invalid JSON

######## Step 3: Convert the data into a DataFrame ########
df = pd.DataFrame(data)

######## Step 4: Perform basic data review ########
print("Data Overview:")
print(df.head())  # First few rows
print("\nData Info:")
print(df.info())  # Column types, non-null counts
print("\nMissing Values:")
print(df.isnull().sum())  # Null counts per column

######## Step 5: Describe numerical and categorical data ########
print("\nNumerical Data Summary:")
print(df.describe(include='all'))  # Summary for numerical columns
print("\nCategorical Data Value Counts:")
for col in df.select_dtypes(include=['object', 'category']).drop(columns=['rewardsReceiptItemList'], errors='ignore').columns:  # Exclude rewardsReceiptItemList for Receipts table and add error=ignore if we're processing another file that doesn't have that column
    print(f"\n{col} Value Counts:")
    print(df[col].value_counts())

######## Step 6: Primary Key Checks ########
# Add/Update columns as needed
columns = ['_id']
print(f"\nPrimary Key Check - Columns: {columns}")

# Find duplicate rows
duplicate_rows = df[df.duplicated(subset=columns, keep=False)]
# Group duplicates and count them
duplicates_with_counts = (
    duplicate_rows
    .groupby(columns)
    .size()
    .reset_index(name="duplicate_count")
    .sort_values(by="duplicate_count", ascending=False)
)
# Check if there are any duplicates
if duplicates_with_counts.empty:
    print("No duplicates found for specified columns.")
else:
    print(duplicates_with_counts)

######## Step 7: Finish! ########
print(f"\nDONE!!!!\nFinished analyzing file {selected_file}")
