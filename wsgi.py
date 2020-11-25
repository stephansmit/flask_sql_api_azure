from flask import Flask
import os 
app = Flask(__name__)

@app.route("/")
def hello():
    connstring = os.getenv('SQLSRV_CONNSTR')
    return "<h1 style='color:blue'>Hello There! Let me see how this thing updates now"+connstring+"</h1>"

if __name__ == "__main__":
    app.run(host='0.0.0.0')
