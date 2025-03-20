import pyodbc
import pandas as pd
from openpyxl import Workbook

# Azure SQL Server Connection Details
server = "your-server-name.database.windows.net"
database = "your-database-name"
driver = "ODBC Driver 18 for SQL Server"
authentication = "ActiveDirectoryInteractive"  # Microsoft Entra MFA

# Provide Username
username = input("Enter your Azure SQL username: ")

# Define customer numbers
customer_numbers = [f"CUST{i:02d}" for i in range(1, 53)]  # Example CUST01, CUST02, ..., CUST52

# Define SQL Queries
query1 = """SELECT * FROM RevisedData WHERE CustomerNo = ?"""
query2 = """SELECT * FROM BeforeData WHERE CustomerNo = ?"""

# Establish Connection
conn_str = f'DRIVER={{{driver}}};SERVER={server};DATABASE={database};UID={username};AUTHENTICATION={authentication}'
conn = pyodbc.connect(conn_str)
cursor = conn.cursor()

for customer_no in customer_numbers:
    print(f"Processing CustomerNo: {customer_no}")
    excel_file = f"customer_data_{customer_no}.xlsx"
    
    with pd.ExcelWriter(excel_file, engine='openpyxl') as writer:
        # Execute First Query
        cursor.execute(query1, customer_no)
        columns = [desc[0] for desc in cursor.description]
        data1 = cursor.fetchall()
        df1 = pd.DataFrame.from_records(data1, columns=columns)
        df1.to_excel(writer, sheet_name="Revised", index=False)
        
        # Execute Second Query
        cursor.execute(query2, customer_no)
        columns = [desc[0] for desc in cursor.description]
        data2 = cursor.fetchall()
        df2 = pd.DataFrame.from_records(data2, columns=columns)
        df2.to_excel(writer, sheet_name="Before", index=False)
        
    print(f"Excel file generated: {excel_file}")

cursor.close()
conn.close()
