import json
import pandas as pd
from enum import Enum
from flask import Flask, request
import numpy as np
from dotenv import load_dotenv
import os

load_dotenv()
server = os.environ.get("SERVER_URL")

app = Flask(__name__)


def calcDist(coffee, slider):
    slider = list(map(int, slider))
    return (
        (slider[0] - coffee.loc["taste"]) ** 2
        + (slider[1] - coffee.loc["body"]) ** 2
        + (slider[2] - coffee.loc["roast"]) ** 2
    )


def calcCoffee(isPro, pro, isIce, slider):
    coffees = pd.read_csv("truedata.csv")
    coffees.columns = ["id","detail_url","img_path",  "taste", "body", "roast","title"]
    coffees.astype({"taste": int, "body": int, "roast": int})
    coffees["score"] = coffees.apply(calcDist, slider=slider, axis=1)
    if isPro:
        brend = pro["brend"]
        darkRoast = pro["darkRoast"]
        coffees = coffees[coffees["brend"] == brend]
        coffees = coffees[coffees["darkRoast"] == darkRoast]

    coffees.sort_values("score", ascending=False)
    return {
        "imgs": [
            {
                "title": coffees.iloc[0, 1],
                "url": "https://www.kaldi.co.jp/news/images/bnr_halloween2024_SP.jpg",
                "video": f"{server}/static/tmp.mp4",
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
    isPro = req["isPro"]
    pro = req["pro"]
    isIce = req["isIce"]
    slider = [req["taste"], req["body"], req["roast"]]
    return json.dumps(calcCoffee(isPro, pro, isIce, slider))

@app.route("/", methods=['GET'])
def index2():
    return 'hello'

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")
