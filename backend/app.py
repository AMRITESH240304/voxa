import requests

response = requests.get(
    "https://studio-api.cheqd.net/account",
    headers={
        "x-api-key": "caas_515ff32ed3ab0617e830ba229b52e3c1cd166ea4d31e7966c1f7025512a3512715cd4e17acfaf86287fac53d79564b0555bea6d963ee0c432b9f1df1c986a70c",
        "Accept": "*/*"
    },
)

print("Status Code:", response.status_code)
print("Content-Type:", response.headers.get("Content-Type"))
print("Raw Text:", response.text[:200])  # Print first 200 characters to avoid flooding

try:
    data = response.json()
    print("JSON Response:", data)
except requests.exceptions.JSONDecodeError:
    print("❌ Response is not valid JSON.")
