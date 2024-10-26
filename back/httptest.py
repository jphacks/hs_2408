import json
from flask import Flask, request

app = Flask(__name__)


@app.route("/", methods=["POST"])
def index():
    req = request.get_json()
    print(req)
    return json.dumps(
        {"url": "https://www.kaldi.co.jp/ec/img/699/4515996010699_M_1s.jpg"}
    )


if __name__ == "__main__":
    app.run(debug=True)