Car Inventory Management System - DBMS Case Study (Aditya Wandhare)
1. pip install flask psycopg2-binary
2. psql -U postgres -f sql/01_schema.sql
   psql -U postgres -d adityawandhare -f sql/02_data.sql
   psql -U postgres -d adityawandhare -f sql/03_advanced.sql
3. Set your password:  set PGPASSWORD=your_password   (Windows)   |   export PGPASSWORD=your_password (Linux/Mac)
4. cd app && python app.py   -> open http://127.0.0.1:5000
