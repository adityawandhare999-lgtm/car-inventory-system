"""
Database Initialization Script for Car Inventory System
Runs sql/full_setup.sql on PostgreSQL using DATABASE_URL or individual PG env variables.
"""
import os
import sys

# Add app directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "app"))
from app import get_conn

def init_db():
    sql_path = os.path.join(os.path.dirname(__file__), "sql", "full_setup.sql")
    if not os.path.exists(sql_path):
        print(f"Error: Could not find {sql_path}")
        return

    print(f"Reading setup script from: {sql_path}")
    with open(sql_path, "r", encoding="utf-8") as f:
        sql = f.read()

    print("Connecting to database...")
    try:
        with get_conn() as conn:
            conn.autocommit = True
            with conn.cursor() as cur:
                print("Executing schema and data setup...")
                cur.execute(sql)
        print("Database successfully initialized!")
    except Exception as e:
        print(f"Error initializing database: {e}")
        sys.exit(1)

if __name__ == "__main__":
    init_db()
