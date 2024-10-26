import json
import pandas as pd
from flask import Flask, request

app = Flask(__name__)


def calcDist(coffee, slider):
    slider = list(map(int, slider))
    return (
        (slider[0] - coffee.iloc[2]) ** 2
        + (slider[1] - coffee.iloc[3]) ** 2
        + (slider[2] - coffee.iloc[4]) ** 2
    )


def calcCoffee(isIce, slider):
    coffees = pd.read_csv("../truedata.csv")
    coffees.columns = ["id", "title", "acid", "body", "roast"]
    coffees.astype({"acid": int, "body": int, "roast": int})
    coffees["score"] = coffees.apply(calcDist, slider=slider, axis=1)
    coffees.sort_values("score", ascending=False)
    return {
        "imgs": [
            {
                "title": coffees.iloc[0, 1],
                "url": "https://www.kaldi.co.jp/news/images/bnr_halloween2024_SP.jpg",
            },
            {
                "title": coffees.iloc[1, 1],
                "url": "https://www.kaldi.co.jp/news/images/bnr_imokurikabocya%202024A.jpg",
            },
            {
                "title": coffees.iloc[2, 1],
                "url": "https://www.kaldi.co.jp/news/images/bur_yoichi_nouveau_2024.jpg",
            },
        ]
    }


@app.route("/", methods=["POST"])
def index():
    req = request.get_json()
    isIce = req["isIce"]
    slider = [req["acid"], req["body"], req["roast"]]
    return json.dumps(calcCoffee(isIce, slider))


if __name__ == "__main__":
    app.run(debug=True)
