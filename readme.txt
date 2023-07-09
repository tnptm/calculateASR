Reimplement more popular language the calc_inc.pl. 
It will be python module, and it should be used as a part of 
control python script, where data is loaded and settings defined for
every project. It will be better for auto documentation of projects


calcAsr.py on nyt pääohjelma, jota kehitetään ja ajoscriptissä tehdään tarvittavat asetukset. Moduuli olisi hyvä olla ajettavissa myös itsenäisesti
Siinä täytyisi olla funktio, joka ottaa vastaan kaikki parametrit. Tämä on myös ohjelman käytön helppouden kannalta välttämätön vaihtoehto. Siinä
yksi prosessi käynnistyy yhdellä funktiolla. Prosessi itsessään ei ole aivan optimoitu toistuvaan sarja-ajoon.

Sen pitäisi olla siten optimoitu, että sarja-ajona esimerkiksi väestödataa ei tarvitse ajaa toistuvasti, kun taas ajokohtaiset tiedot on määritettävä
funktio kutsussa.

Eli erikseen asetetaan globaalit asetukset 
1. settingsobjektiin (periodit, väestöstandardi, )
2. väestödata objektiin
seuraava vaihe toistetaan:
3. kutsu ajofunktiota, joka
    - lataa casedatan
    - määrittelee sukupuolen (settingsobj)
    - käynnistää laskennan
