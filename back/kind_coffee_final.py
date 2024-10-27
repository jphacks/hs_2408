import pandas as pd
from bs4 import BeautifulSoup
import requests
import time

def get_kind_and_roast(url):
    """Retrieve 'コーヒーの種類' and 'ロースト' from the product detail page."""
    headers = {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                      "AppleWebKit/537.36 (KHTML, like Gecko) "
                      "Chrome/91.0.4472.114 Safari/537.36"
    }

    try:
        response = requests.get(url, headers=headers)
        
        response.raise_for_status()
        soup = BeautifulSoup(response.content, "html.parser")
        time.sleep(0.1)
        # Navigate to the correct table structure
        table = soup.find("main").findAll("table")[-1]
        if not table:
            print(f"Table not found on page: {url}")
            return 0, 0  # Default values

        kind, roast = 0, 0  # Default values
        rows = table.find_all("tr")

        # Extract values based on <th> text
        for row in rows:
            th = row.find("th").get_text(strip=True)
            td = row.find("td").get_text(strip=True)
            if th == "コーヒーの種類":
                kind = 1 if td == "ブレンド" else 0
            elif th == "ロースト":
                roast = 1 if td == "深煎り" else 0

        print(f"URL: {url} -> Kind: {kind}, Roast: {roast}")
        return kind, roast

    except Exception as e:
        print(f"Error fetching data from {url}: {e}")
        return 0, 0  # Default values in case of an error

# Load the existing CSV
df = pd.read_csv("score.csv", header=None)

# Update columns 8 and 9 with the extracted values
for index, row in df.iterrows():
    url = row[1]
    kind, roast = get_kind_and_roast(url)
    df.at[index, 7] = kind  # Column 8 (0-indexed is 7)
    df.at[index, 8] = roast  # Column 9 (0-indexed is 8)
# Save the updated CSV
df.to_csv("score.csv", index=False, header=False)

print("Updated CSV saved as 'score.csv'")