import pymysql

DB_CONFIG = {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "",
    "database": "fashion_chatbot",
    "charset": "utf8mb4",
    "cursorclass": pymysql.cursors.DictCursor,
}

def get_connection():
    return pymysql.connect(**DB_CONFIG)
