# -*- coding: utf-8 -*-
"""Untitled41.ipynb"""

### 設定
import os
import requests
import cv2
import numpy as np
import pathlib
import math
import pandas as pd
from bs4 import BeautifulSoup
from scraping import scrape_data  # scraping.pyからデータ取得関数をインポート

### データ取得
results = scrape_data()

# データが正常に取得できたか確認
if results is None:
    print("データの取得に失敗しました。")
    exit(1)  # プログラムを終了

# detail_urls_with_idを生成
detail_urls_with_id = [
    [idx + 1, item["detail"], 0, 0, 0, 0, item["name"], 0, 0]
    for idx, item in enumerate(results) if "detail" in item and "name" in item
]

print(detail_urls_with_id)

### コーヒー豆の特徴画像をダウンロード

download_folder = "./images"
os.makedirs(download_folder, exist_ok=True)  # フォルダがなければ作成

for i, item in enumerate(detail_urls_with_id):
    url = item[1]

    try:
        response = requests.get(url)
        response.raise_for_status()
        soup = BeautifulSoup(response.content, "lxml")

        image_pager_div = soup.find("div", id="image_pager")
        if image_pager_div:
            img_tags = image_pager_div.find_all("img")
            if len(img_tags) >= 2:
                second_last_img_url = "https://www.kaldi.co.jp" + img_tags[-2]["src"]
                detail_urls_with_id[i][2] = second_last_img_url
                print("後ろから2番目の画像URL:", second_last_img_url)
            else:
                print("画像が2つ未満のため、後ろから2番目の画像はありません。")
        else:
            print("id='image_pager'の<div>が見つかりませんでした。")
    except Exception as e:
        print(f"画像取得中にエラーが発生しました: {e}")

### 画像のダウンロード

for idx, item in enumerate(detail_urls_with_id, start=1):
    url = item[2]
    if url:
        try:
            response = requests.get(url)
            response.raise_for_status()

            image_path = os.path.join(download_folder, f"image_{idx}.jpg")
            with open(image_path, "wb") as f:
                f.write(response.content)
            print(f"Downloaded: {image_path}")
            detail_urls_with_id[idx - 1][2] = image_path
        except Exception as e:
            print(f"画像のダウンロードに失敗しました: {e}")
    else:
        print(f"No URL found at index {idx}, skipping download.")

### 画像処理

for j, item in enumerate(detail_urls_with_id):
    imgCV = cv2.imread(item[2])

    if imgCV is None:
        print("画像の読み込みに失敗しました。")
        continue

    gray = cv2.cvtColor(imgCV, cv2.COLOR_BGR2GRAY)
    circles = cv2.HoughCircles(
        gray, cv2.HOUGH_GRADIENT, dp=1, minDist=10, param1=50, param2=20, minRadius=5, maxRadius=10
    )

    if circles is not None:
        circles = np.uint16(np.around(circles))
        for i in circles[0, :]:
            center = (i[0], i[1])
            radius = i[2]

            if 320 <= i[1] <= 340:
                s = i[0] - 140
                t = math.floor(s / 21 * 5)
                k = math.floor(t / 5) * 5
                item[3] = k

            if 415 <= i[1] <= 435:
                if i[0] <= 200:
                    item[4] = 0
                elif i[0] <= 300:
                    item[4] = 25
                elif i[0] <= 400:
                    item[4] = 50
                elif i[0] <= 500:
                    item[4] = 75
                else:
                    item[4] = 100

            if 505 <= i[1] <= 525:
                s = i[0] - 135
                t = math.floor(s / 30) * 7
                item[5] = t

            cv2.circle(imgCV, center, radius, (255, 0, 0), -1)
    else:
        print("円が検出されませんでした。")

### 例外処理

for j in range(len(detail_urls_with_id) - 1, -1, -1):
    if (
        (detail_urls_with_id[j][3] == 0 and detail_urls_with_id[j][4] == 0 and detail_urls_with_id[j][5] == 0) or
        (detail_urls_with_id[j][3] < 0 or detail_urls_with_id[j][3] > 100 or
         detail_urls_with_id[j][4] < 0 or detail_urls_with_id[j][4] > 100 or
         detail_urls_with_id[j][5] < 0 or detail_urls_with_id[j][5] > 100)
    ):
        del detail_urls_with_id[j]

### DataFrameに変換し、CSVに保存

df = pd.DataFrame(detail_urls_with_id)
df.to_csv("score.csv", index=False, header=False)

# CSVファイルの再読み込みと表示（確認用）
df = pd.read_csv("score.csv", header=None)
print(df)