"""
Car Inventory Management System  -  Front End (Flask + PostgreSQL)
Student : Aditya Wandhare
"""
import os
import psycopg2
import psycopg2.extras
from flask import Flask, render_template, request, redirect, url_for, flash

app = Flask(__name__)
app.secret_key = "adityawandhare-car-inventory"

# ---------- Database connection ----------
DATABASE_URL = os.environ.get("DATABASE_URL")

def get_conn():
    if DATABASE_URL:
        # Some cloud providers (e.g. Render/Heroku) use postgres:// which psycopg2 prefers as postgresql://
        url = DATABASE_URL.replace("postgres://", "postgresql://", 1)
        return psycopg2.connect(url, cursor_factory=psycopg2.extras.RealDictCursor)
    return psycopg2.connect(
        host=os.environ.get("PGHOST", "localhost"),
        port=os.environ.get("PGPORT", "5432"),
        dbname=os.environ.get("PGDATABASE", "adityawandhare"),
        user=os.environ.get("PGUSER", "postgres"),
        password=os.environ.get("PGPASSWORD", "postgres"),
        cursor_factory=psycopg2.extras.RealDictCursor,
    )

def query(sql, params=None, one=False):
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute(sql, params or ())
        return cur.fetchone() if one else cur.fetchall()

def execute(sql, params=None):
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute(sql, params or ())

@app.template_filter("inr")
def inr(value):
    """Format a number in the Indian numbering system, e.g. 1,250,000 -> Rs 12,50,000"""
    n = int(round(float(value or 0)))
    s = str(abs(n))
    if len(s) > 3:
        head, tail = s[:-3], s[-3:]
        parts = []
        while len(head) > 2:
            parts.insert(0, head[-2:]); head = head[:-2]
        if head: parts.insert(0, head)
        s = ",".join(parts) + "," + tail
    return ("-" if n < 0 else "") + "\u20b9" + s

# ---------- Routes ----------
@app.route("/")
def dashboard():
    stats = query("""
        SELECT COUNT(*) AS total,
               COUNT(*) FILTER (WHERE status='Available')  AS available,
               COUNT(*) FILTER (WHERE status='Sold')       AS sold,
               COUNT(*) FILTER (WHERE status='Reserved')   AS reserved,
               COUNT(*) FILTER (WHERE status='In Service') AS in_service,
               COALESCE(SUM(selling_price) FILTER (WHERE status<>'Sold'),0) AS stock_value
        FROM cars""", one=True)
    revenue = query("SELECT COALESCE(SUM(sale_price),0) AS r FROM sales", one=True)["r"]
    recent = query("""
        SELECT s.sale_id, s.sale_date, cu.full_name AS customer,
               m.name || ' ' || cm.model_name AS car, s.sale_price, s.payment_mode
        FROM sales s JOIN customers cu ON cu.customer_id=s.customer_id
        JOIN cars c ON c.car_id=s.car_id JOIN car_models cm ON cm.model_id=c.model_id
        JOIN manufacturers m ON m.manufacturer_id=cm.manufacturer_id
        ORDER BY s.sale_date DESC, s.sale_id DESC LIMIT 6""")
    by_fuel = query("""SELECT cm.fuel_type, COUNT(*) AS n FROM cars c
        JOIN car_models cm ON cm.model_id=c.model_id WHERE c.status<>'Sold'
        GROUP BY cm.fuel_type ORDER BY n DESC""")
    return render_template("dashboard.html", stats=stats, revenue=revenue,
                           recent=recent, by_fuel=by_fuel, page="dashboard")

@app.route("/inventory")
def inventory():
    status = request.args.get("status", "")
    fuel = request.args.get("fuel", "")
    q = request.args.get("q", "").strip()
    sql = """SELECT c.car_id, m.name AS manufacturer, cm.model_name, cm.fuel_type,
                    cm.transmission, c.color, c.manufacture_year, c.mileage_km,
                    c.car_condition, c.selling_price, c.status
             FROM cars c JOIN car_models cm ON cm.model_id=c.model_id
             JOIN manufacturers m ON m.manufacturer_id=cm.manufacturer_id WHERE 1=1"""
    params = []
    if status: sql += " AND c.status = %s"; params.append(status)
    if fuel:   sql += " AND cm.fuel_type = %s"; params.append(fuel)
    if q:
        sql += " AND (m.name ILIKE %s OR cm.model_name ILIKE %s OR c.color ILIKE %s)"
        params += [f"%{q}%"] * 3
    sql += " ORDER BY c.car_id"
    return render_template("inventory.html", cars=query(sql, params),
                           status=status, fuel=fuel, q=q, page="inventory")

@app.route("/cars/add", methods=["GET", "POST"])
def add_car():
    if request.method == "POST":
        f = request.form
        try:
            execute("""INSERT INTO cars (vin, model_id, supplier_id, color, manufacture_year,
                         mileage_km, car_condition, purchase_price, selling_price, status, arrival_date)
                       VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,'Available',%s)""",
                    (f["vin"].upper(), f["model_id"], f["supplier_id"], f["color"],
                     f["year"], f["mileage"], f["condition"], f["purchase_price"],
                     f["selling_price"], f["arrival_date"]))
            flash("Car added to inventory successfully.", "ok")
            return redirect(url_for("inventory"))
        except Exception as e:
            flash("Could not add car: " + str(e).split("\n")[0], "err")
    models = query("""SELECT cm.model_id, m.name || ' ' || cm.model_name || ' (' || cm.fuel_type || ', ' ||
                      cm.transmission || ')' AS label FROM car_models cm
                      JOIN manufacturers m ON m.manufacturer_id=cm.manufacturer_id ORDER BY label""")
    suppliers = query("SELECT supplier_id, supplier_name || ' - ' || city AS label FROM suppliers ORDER BY supplier_name")
    return render_template("add_car.html", models=models, suppliers=suppliers, page="add")

@app.route("/cars/<int:car_id>/delete", methods=["POST"])
def delete_car(car_id):
    try:
        execute("DELETE FROM cars WHERE car_id=%s AND status='Available'", (car_id,))
        flash("Car removed from inventory.", "ok")
    except Exception as e:
        flash("Cannot delete: car has sale records.", "err")
    return redirect(url_for("inventory"))

@app.route("/sales", methods=["GET", "POST"])
def sales():
    if request.method == "POST":
        f = request.form
        try:
            execute("""INSERT INTO sales (car_id, customer_id, employee_id, sale_date, sale_price, payment_mode)
                       VALUES (%s,%s,%s,%s,%s,%s)""",
                    (f["car_id"], f["customer_id"], f["employee_id"], f["sale_date"], f["sale_price"], f["payment_mode"]))
            flash("Sale recorded. Car status updated to Sold by the database trigger.", "ok")
        except Exception as e:
            flash("Sale failed: " + str(e).split("\n")[0], "err")
        return redirect(url_for("sales"))
    rows = query("""SELECT s.sale_id, s.sale_date, cu.full_name AS customer, cu.city,
                    m.name || ' ' || cm.model_name AS car, e.full_name AS salesperson,
                    s.sale_price, s.payment_mode
                    FROM sales s JOIN customers cu ON cu.customer_id=s.customer_id
                    JOIN cars c ON c.car_id=s.car_id JOIN car_models cm ON cm.model_id=c.model_id
                    JOIN manufacturers m ON m.manufacturer_id=cm.manufacturer_id
                    JOIN employees e ON e.employee_id=s.employee_id
                    ORDER BY s.sale_date DESC, s.sale_id DESC""")
    cars = query("""SELECT c.car_id, m.name || ' ' || cm.model_name || ' - ' || c.color AS label, c.selling_price
                    FROM cars c JOIN car_models cm ON cm.model_id=c.model_id
                    JOIN manufacturers m ON m.manufacturer_id=cm.manufacturer_id
                    WHERE c.status IN ('Available','Reserved') ORDER BY c.car_id""")
    customers = query("SELECT customer_id, full_name FROM customers ORDER BY full_name")
    emps = query("SELECT employee_id, full_name FROM employees WHERE role IN ('Sales Executive','Sales Manager') ORDER BY full_name")
    return render_template("sales.html", rows=rows, cars=cars, customers=customers, emps=emps, page="sales")

@app.route("/customers")
def customers():
    rows = query("""SELECT cu.customer_id, cu.full_name, cu.phone, cu.email, cu.city, cu.registered_on,
                    COUNT(s.sale_id) AS purchases
                    FROM customers cu LEFT JOIN sales s ON s.customer_id=cu.customer_id
                    GROUP BY cu.customer_id ORDER BY cu.customer_id""")
    return render_template("customers.html", rows=rows, page="customers")

@app.route("/service")
def service():
    rows = query("""SELECT sr.service_id, sr.service_date, m.name || ' ' || cm.model_name AS car,
                    sr.service_type, e.full_name AS advisor, sr.cost, sr.service_status
                    FROM service_records sr JOIN cars c ON c.car_id=sr.car_id
                    JOIN car_models cm ON cm.model_id=c.model_id
                    JOIN manufacturers m ON m.manufacturer_id=cm.manufacturer_id
                    JOIN employees e ON e.employee_id=sr.employee_id
                    ORDER BY sr.service_date DESC, sr.service_id DESC""")
    return render_template("service.html", rows=rows, page="service")

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=os.environ.get("FLASK_DEBUG", "True").lower() in ("true", "1"))
