"""
Database Initialization Script for Car Inventory System
Runs sql/full_setup.sql on PostgreSQL using DATABASE_URL or individual PG env variables.
Safe to run on every deploy: skips if tables already exist.
"""
import os
import sys

# Add app directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "app"))
from app import get_conn

def init_db():
    print("Connecting to database...")
    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                # Check if tables are already created
                cur.execute("""
                    SELECT EXISTS (
                        SELECT 1 FROM information_schema.tables 
                        WHERE table_schema = 'public' AND table_name = 'manufacturers'
                    ) AS tbl_exists;
                """)
                res = cur.fetchone()
                if res and (res.get("tbl_exists") if isinstance(res, dict) else res[0]):
                    print("Database tables already exist. Skipping initialization.")
                    return

            # If tables don't exist yet, run the full setup script
            sql_path = os.path.join(os.path.dirname(__file__), "sql", "full_setup.sql")
            if not os.path.exists(sql_path):
                print(f"Error: Could not find {sql_path}")
                return

            print(f"Reading setup script from: {sql_path}")
            with open(sql_path, "r", encoding="utf-8") as f:
                sql = f.read()

            conn.autocommit = True
            with conn.cursor() as cur:
                print("Executing schema and data setup...")
                cur.execute(sql)
        print("Database successfully initialized!")
    except Exception as e:
        err_msg = str(e).lower()
        if "already exists" in err_msg:
            print("Tables already exist. Skipping initialization.")
            return
        print(f"Error initializing database: {e}")
        sys.exit(1)

if __name__ == "__main__":
    init_db()
