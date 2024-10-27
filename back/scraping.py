import requests
from bs4 import BeautifulSoup

def scrape_data():
    # Kaldiの商品一覧ページのURL
    BaseURL = "https://www.kaldi.co.jp/ec/Facet?category_0=11010100000"
    Pages = ["", "&page=2"]
    
    results = []
    
    for Page in Pages:
        # ページのHTMLを取得
        response = requests.get(BaseURL + Page)
        response.raise_for_status()
    
        # BeautifulSoupでHTMLをパース
        soup = BeautifulSoup(response.content, "lxml")
    
        # 商品情報をすべて取得（<div class="item">を取得）
        items = soup.find_all("div", class_="item")
    
        # 各商品の情報を抽出
        for item in items:
            # 商品名を取得
            name = item.find("p", class_="list_item_name_style").get_text(strip=True)
    
            # 価格を取得
            price = item.find("p", class_="list_item_price_style").get_text(strip=True)
    
            # 画像のURLを取得
            image_tag = item.find("img", id="productImg")
            image_url = (
                "https://www.kaldi.co.jp" + image_tag["src"] if image_tag else "画像なし"
            )
    
            # 詳細ページへのURLを取得
            link_tag = item.find("a", href=True)
            detail_url = (
                "https://www.kaldi.co.jp" + link_tag["href"] if link_tag else "リンクなし"
            )
    
            # 結果を保存
            results.append(
                {"name": name, "price": price, "img": image_url, "detail": detail_url}
            )
    
    print(results)
