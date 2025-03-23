
import pymssql
import pandas as pd
from openpyxl import Workbook

# Azure SQL Server Connection Details
server = "DESKTOP-4AJVP24"
database = "homeloan"

# Provide Username and Password

# Define customer numbers
customer_numbers = [f"{i:2d}" for i in range(1, 5)]  # Example CUST01, CUST02, ..., CUST52
print(customer_numbers)
# Define SQL Queries
query1 = """SELECT * FROM [AdventureWorks2022].[HumanResources].[Employee] WHERE [BusinessEntityID] = %s"""
query2 = """SELECT * FROM [AdventureWorks2022].[HumanResources].[Employee] WHERE BusinessEntityID = %s"""

# Establish Connection using Username and Password
conn = pymssql.connect(server=server, user=username, password=password, database=database)
cursor = conn.cursor()

for BusinessEntityID in customer_numbers:
    print(f"Processing CustomerNo: {BusinessEntityID}")
    excel_file = f"customer_data_{BusinessEntityID}.xlsx"
    
    with pd.ExcelWriter(excel_file, engine='openpyxl') as writer:
        # Execute First Query
        cursor.execute(query1, (BusinessEntityID,))
        columns = [desc[0] for desc in cursor.description]
        data1 = cursor.fetchall()
        df1 = pd.DataFrame.from_records(data1, columns=columns)
        df1.to_excel(writer, sheet_name="Revised", index=False)
        
        # Execute Second Query
        cursor.execute(query2, (BusinessEntityID,))
        columns = [desc[0] for desc in cursor.description]
        data2 = cursor.fetchall()
        df2 = pd.DataFrame.from_records(data2, columns=columns)
        df2.to_excel(writer, sheet_name="Before", index=False)
        
    print(f"Excel file generated: {excel_file}")

cursor.close()
conn.close()
