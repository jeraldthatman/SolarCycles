def web_scraper(url):
    """ Scrape the url and return the text of the page """
    import requests
    from bs4 import BeautifulSoup
    r = requests.get(url)
    soup = BeautifulSoup(r.text, 'html.parser')
    return soup.get_text()

API_KEY = 'http://api.eia.gov/category/?api_key=YOUR_API_KEY_HERE&category_id=371'