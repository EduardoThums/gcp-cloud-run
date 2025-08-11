from flask import Flask, jsonify
from google.cloud import secretmanager
import psycopg2

app = Flask(__name__)


@app.route("/api/ping")
def ping():
    # # Connect to your postgres DB
    # conn = psycopg2.connect(
    #     host="postgres.internal.local",
    #     # host="10.120.104.3",
    #     database="app_database",
    #     user="app_user",
    #     password="jBooIEZ8zmzpNeLn",
    # )

    # # Open a cursor to perform database operations
    # cur = conn.cursor()

    # # Execute a query
    # cur.execute("SELECT CURRENT_DATE")

    # # Retrieve query results
    # records = cur.fetchall()

    # client = secretmanager.SecretManagerServiceClient()

    # # Build the resource name of the secret version
    # name = "projects/1072774486437/secrets/teste/versions/1"

    # # Access the secret version
    # response = client.access_secret_version(request={"name": name})

    # Decode and use the secret payload
    # secret_payload = response.payload.data.decode("UTF-8")
    # print(f"Secret payload: {secret_payload}")

    # return jsonify(records)
    return "success"


if __name__ == "__main__":
    app.run(debug=True, port=8080)
