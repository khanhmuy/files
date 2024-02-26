# Based on LillieH1000 (https://github.com/LillieH1000/)'s script
import os, sys, requests, json
val = input("Enter Server ID: ")
discord = "https://discordapp.com/api/v6/guilds/" + val
r = requests.get(discord, headers={"Authorization":"YOUR_TOKEN_HERE"})
d = json.loads(r.content)
try:
    n = d['name']
except:
    print('Invalid server ID!')
    exit()
t = ''.join(e for e in n if e.isalnum())
print('Selected server:', t)
if os.path.exists(t) == True:
    print('\nThe directory',t, 'already exists!')
    exit()
else:
    os.mkdir(t)
    print('Choose file format for still emojis: \n1. PNG \n2. webp')
    choice = input("Enter choice: ")
    total = len(d['emojis'])
    count = 0
    for x in d['emojis']:
        m = x['name']
        p = ''.join(e for e in m if e.isalnum())
        if (x['animated'] == False):
            if (choice == "1"):
                link = "https://cdn.discordapp.com/emojis/" + x['id'] + ".png?quality=lossless"
                name = t + "/" + p + ".png"
            elif (choice == "2"):
                link = "https://cdn.discordapp.com/emojis/" + x['id'] + ".webp?quality=lossless"
                name = t + "/" + p + ".webp"
            else:
                print("Invalid choice!")
                exit()
            with open(name, "wb") as file:
                response = requests.get(link)
                file.write(response.content)
                count = count + 1
                print('\rDownloaded', count, 'of', total, 'emojis', end='\r')
        if (x['animated'] == True):
            link = "https://cdn.discordapp.com/emojis/" + x['id'] + ".gif?quality=lossless"
            name = t + "/" + p + ".gif"
            with open(name, "wb") as file:
                response = requests.get(link)
                file.write(response.content)
                count = count + 1
                print('\rDownloaded', count, 'of', total, 'emojis', end='\r')
    print("\nDone!")