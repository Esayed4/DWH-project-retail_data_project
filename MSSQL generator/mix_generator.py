import pyodbc
import pandas as pd
import os

# -------------------
# Database connection
# -------------------
def connect_to_database(server='enter Your own one', database='online_store'):
    connection_string = (
        "DRIVER={ODBC Driver 17 for SQL Server};"
        f"SERVER={server};"
        f"DATABASE={database};"
        "Trusted_Connection=yes;"
    )
    return pyodbc.connect(connection_string)


def clear_tables(cursor):
    """ Delete all data from OLTP tables in correct FK order """
    tables = ["Feedbacks", "Order_Items", "Payments", "Orders", "Sellers", "Users", "Products"]
    for t in tables:
        cursor.execute(f"DELETE FROM {t}")
        print(f"🗑️ Cleared table: {t}")


# -------------------
# Insert Functions
# -------------------
def insert_products(cursor, base_path):
    df = pd.read_csv(os.path.join(base_path, "product_dataset.csv")).where(pd.notnull(pd.read_csv(os.path.join(base_path, "product_dataset.csv"))), None)
    sql = """
    INSERT INTO Products (product_id, product_category, product_name_length,
                          product_description_length, product_photos_qty,
                          product_weight_g, product_length_cm,
                          product_height_cm, product_width_cm)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    """
    for _, row in df.iterrows():
        cursor.execute(sql, (
            row['product_id'],
            row['product_category'],
            int(row['product_name_length']) if pd.notna(row['product_name_length']) else None,
            int(row['product_description_length']) if pd.notna(row['product_description_length']) else None,
            int(row['product_photos_qty']) if pd.notna(row['product_photos_qty']) else None,
            float(row['product_weight_g']) if pd.notna(row['product_weight_g']) else None,
            float(row['product_length_cm']) if pd.notna(row['product_length_cm']) else None,
            float(row['product_height_cm']) if pd.notna(row['product_height_cm']) else None,
            float(row['product_width_cm']) if pd.notna(row['product_width_cm']) else None
        ))


def insert_users(cursor, base_path):
    df = pd.read_csv(os.path.join(base_path, "user_dataset.csv")).where(pd.notnull(pd.read_csv(os.path.join(base_path, "user_dataset.csv"))), None)
    df = df.drop_duplicates(subset=["user_name"])

    sql = "INSERT INTO Users (user_name, customer_zip_code, customer_city, customer_state) VALUES (?, ?, ?, ?)"
    for _, row in df.iterrows():
        cursor.execute(sql, (
            row['user_name'],
            int(row['customer_zip_code']) if pd.notna(row['customer_zip_code']) else None,
            row['customer_city'],
            row['customer_state']))


def insert_sellers(cursor, base_path):
    df = pd.read_csv(os.path.join(base_path, "seller_dataset.csv")).where(pd.notnull(pd.read_csv(os.path.join(base_path, "seller_dataset.csv"))), None)
    sql = "INSERT INTO Sellers (seller_id, seller_zip_code, seller_city, seller_state) VALUES (?, ?, ?, ?)"
    for _, row in df.iterrows():
        cursor.execute(sql, (
            row['seller_id'],
            int(row['seller_zip_code']) if pd.notna(row['seller_zip_code']) else None,
            row['seller_city'],
            row['seller_state']
        ))


def insert_orders(cursor, base_path):
    df = pd.read_csv(os.path.join(base_path, "order_dataset.csv")).where(pd.notnull(pd.read_csv(os.path.join(base_path, "order_dataset.csv"))), None)
    sql = """INSERT INTO Orders (order_id, user_name, order_status, order_date,
                                order_approved_date, pickup_date, delivered_date,
                                estimated_time_delivery)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)"""
    for _, row in df.iterrows():
        cursor.execute(sql, (
            row['order_id'], row['user_name'], row['order_status'],
            row['order_date'], row['order_approved_date'],
            row['pickup_date'], row['delivered_date'],
            row['estimated_time_delivery']
        ))


def insert_payments(cursor, base_path):
    df = pd.read_csv(os.path.join(base_path, "payment_dataset.csv")).where(pd.notnull(pd.read_csv(os.path.join(base_path, "payment_dataset.csv"))), None)
    sql = "INSERT INTO Payments (order_id, payment_sequential, payment_type, payment_installments, payment_value) VALUES (?, ?, ?, ?, ?)"
    for _, row in df.iterrows():
        cursor.execute(sql, (
            row['order_id'], row['payment_sequential'], row['payment_type'],
            row['payment_installments'],
            float(row['payment_value']) if pd.notna(row['payment_value']) else None
        ))


def insert_order_items(cursor, base_path):
    df = pd.read_csv(os.path.join(base_path, "order_item_dataset.csv")).where(pd.notnull(pd.read_csv(os.path.join(base_path, "order_item_dataset.csv"))), None)
    sql = """INSERT INTO Order_Items (order_id, order_item_id, product_id,
                                      seller_id, pickup_limit_date,
                                      price, shipping_cost)
             VALUES (?, ?, ?, ?, ?, ?, ?)"""
    for _, row in df.iterrows():
        cursor.execute(sql, (
            row['order_id'], row['order_item_id'], row['product_id'],
            row['seller_id'], row['pickup_limit_date'],
            float(row['price']) if pd.notna(row['price']) else None,
            float(row['shipping_cost']) if pd.notna(row['shipping_cost']) else None
        ))


def insert_feedbacks(cursor, base_path):
    df = pd.read_csv(os.path.join(base_path, "feedback_dataset.csv")).where(pd.notnull(pd.read_csv(os.path.join(base_path, "feedback_dataset.csv"))), None)
    df=df.drop_duplicates(subset=["feedback_id"])
    sql = """INSERT INTO Feedbacks (feedback_id, order_id, feedback_score,
                                    feedback_form_sent_date, feedback_answer_date)
             VALUES (?, ?, ?, ?, ?)"""
    for _, row in df.iterrows():
        cursor.execute(sql, (
            row['feedback_id'], row['order_id'], row['feedback_score'],
            row['feedback_form_sent_date'], row['feedback_answer_date']
        ))


# -------------------
# Main
# -------------------
def main():
    base_path = os.path.join(os.path.dirname(__file__), "..", "data")
    con = connect_to_database()
    cursor = con.cursor()

    clear_tables(cursor)

    print("📥 Inserting Products...")
    insert_products(cursor, base_path)

    print("📥 Inserting Users...")
    insert_users(cursor, base_path)

    print("📥 Inserting Sellers...")
    insert_sellers(cursor, base_path)

    print("📥 Inserting Orders...")
    insert_orders(cursor, base_path)

    print("📥 Inserting Payments...")
    insert_payments(cursor, base_path)

    

    print("📥 Inserting Feedbacks...")
    insert_feedbacks(cursor, base_path)
    
    print("📥 Inserting Order_Items...")
    insert_order_items(cursor, base_path)

    con.commit()
    print("✅ All data inserted successfully into OLTP database!")

    cursor.close()
    con.close()


if __name__ == "__main__":
    main()
