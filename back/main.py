import json
import pandas as pd
from enum import Enum
from flask import Flask, request
import numpy as np


app = Flask(__name__)


def calcDist(coffee, slider):
    slider = list(map(int, slider))
    return (
        (slider[0] - coffee.loc["taste"]) ** 2
        + (slider[1] - coffee.loc["body"]) ** 2
        + (slider[2] - coffee.loc["roast"]) ** 2
    )


def calcCoffee(isBeginner, pro, isIce, slider):
    coffees = pd.read_csv("truedata.csv")
    coffees.columns = ["id", "title", "taste", "body", "roast"]
    coffees["brend"] = pd.Series([np.random.random() < 0.5] * (len(coffees["id"])))
    coffees["darkRoast"] = pd.Series([np.random.random() < 0.5] * (len(coffees["id"])))
    coffees.astype({"taste": int, "body": int, "roast": int})
    coffees["score"] = coffees.apply(calcDist, slider=slider, axis=1)
    if isBeginner:
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
    isBegineer = req["isBeginner"]
    pro = req["pro"]
    isIce = req["isIce"]
    slider = [req["taste"], req["body"], req["roast"]]
    return json.dumps(calcCoffee(isBegineer, pro, isIce, slider))


if __name__ == "__main__":
    app.run(debug=True)
