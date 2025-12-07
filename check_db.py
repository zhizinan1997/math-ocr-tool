import psycopg2
from psycopg2 import sql
import config

DB_URI = config.DB_URI

def check_db():
    try:
        conn = psycopg2.connect(DB_URI)
        cur = conn.cursor()
        
        # Check if table exists
        cur.execute("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'auth');")
        exists = cur.fetchone()[0]
        
        if exists:
            print("Table 'auth' exists.")
            # Check columns
            cur.execute("SELECT column_name FROM information_schema.columns WHERE table_name = 'auth';")
            columns = [row[0] for row in cur.fetchall()]
            print(f"Columns: {columns}")
        else:
            print("Table 'auth' does not exist. Creating it...")
            cur.execute("""
                CREATE TABLE auth (
                    id SERIAL PRIMARY KEY,
                    email VARCHAR(255) UNIQUE NOT NULL,
                    password VARCHAR(255) NOT NULL,
                    active BOOLEAN DEFAULT FALSE
                );
            """)
            conn.commit()
            print("Table 'auth' created.")
            
            # Insert a test user if empty
            cur.execute("SELECT COUNT(*) FROM auth;")
            count = cur.fetchone()[0]
            if count == 0:
                cur.execute("INSERT INTO auth (email, password, active) VALUES ('test@example.com', 'password', true);")
                conn.commit()
                print("Inserted test user: test@example.com / password")
                
        cur.close()
        conn.close()
        print("Database check complete.")
        
    except Exception as e:
        print(f"Database error: {e}")

if __name__ == "__main__":
    check_db()
