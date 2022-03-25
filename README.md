# ESP8266-somfy-situo-5 (wip)

Die Idee ist einen ESP8266 mit LUA an eine Somfy Situo 5 io Pure II Fernbedienung anzuschließen.
Auf dem RSP8266 läuft dann eine RestAPI zur Steuerung der Fernbedienung.
Die RestAPI wird am Ende via Node Red angesprochen zur Automation.

Ich habe hier 2 Markisen oben unter dem Terrassendach, 2 Sonnenschutz Rollos. Und die LED's können noch mit der Fernbedienung gesteuert werden.

ToDo Liste:
1. Eine zweite Situo 5 io Pure II Fernbedienung besorgen und diese anlernen (eine bestehende kann wie in der Anleitung beschrieben einfach kopiert werden)
   Die 5 Kanäle habe ich wie folgt belegt
   1. Markise rechts
   2. Markise links
   3. Sonnenschutz Rollo rechts
   4. Sonnenschutz Rollo links
   5. LED
2. Eine passende Firmware auf den ESP8266 flashen mit folgenden Modulen: adc, crypto, encoder, file, gpio, http, net, node, sjson, sntp, struct, tmr, uart, websocket, wifi, wifi_monitor  (Infos dazu gibt es hier: https://nodemcu.readthedocs.io/en/release)
3. Dann die folgenden Dateien anpassen und übertragen (vielleicht hiermit: https://esp8266.ru/esplorer):
   1. credentials.lua : Hier die SSID und das WLAN Passwort anpassen damit der ESP8266 in euer WLAN kommt
   2. init.lua : Hier vielleicht den Teil wifi.sta.sethostname("SomfyRestAPI") anpassen, um einen eigenen Hostname für den ESP8266 zu setzen
   3. application.lua : Hier sind die Pins der Kabel anzupassen und die Dauer, die die Markisen und Sonnenschutz Rollos zum Ausfahren benötigen.
                        Vielleicht auch den Teil mit der Basis Auth: 
                        auth = {
                            user = 'somfyuser',
                            pwd  = 'somsec'
                        }
4. Aus dem Project https://github.com/abobija/api32 nutze ich die api32.lua Datei
5. Nun die Fernbedienung öffnen und die Kabel anlöten, dazu sind ein paar Bilder im docs-Verzeichnis

![Fernbedienung 1](/docs/Remote-1.jpg)
![Fernbedienung 2](/docs/Remote-2.jpg)
![Fernbedienung 3](/docs/Remote-3.jpg)
![Fernbedienung 4](/docs/Remote-4.jpg)

Gehäuse für den ESP8266: https://www.thingiverse.com/thing:2786523
![Fernbedienung 4](/docs/Remote-5.jpg)

Bei der Anbindung mit Node Red ist mir aufgefallen, dass die Basis Auth direkt als Header verschlüsselt übergeben werden muss.
Mein Node Red-Flow Export ist im docs-Verzeichnis zu finden. Zusätzlich nutze ich noch das suncron Plugin bei Node Red um bei Sonnenuntergang alle Markisen und Rollos einzufahren.

Fertig.

![Fernbedienung 6](/docs/Remote-6.jpg)

![Node Red Flow](/docs/NodeRed-Somfy.jpg)
