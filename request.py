import requests
url = 'http://127.0.0.1:8000/heathrow'
r = requests.post(url,json={'data':1,})
print(r.json())