## FLP 2023 Projekt 2 -- Turingův stroj
### Autor: Vojtěch Fiala \<xfiala61\>

## Návod k použití
Program lze přeložit příkazem *make* v kořenové složce.
Spustit lze program například jako ./flp22-log < input.txt > output.txt

## Testy
Testy (a také testovací vstupy a očekávané výstupy), na kterých bylo řešení odzkoušeno, se nacházejí ve složce tests/

Jejich spuštění je možné z kořenového adresáře příkazem *make test*. 

## Popis řešení
Pro úspěšně spuštění je nutné, aby vstup byl ve formátu LF (tedy windowsovské CRLF nedokáže zparsovat).

Řešení využívá poskytnuté predikáty pro načítání vstupu.
Z těch následně odstraní poslední řádek (očekávanou pásku), z jednotlivých řádků odstraní mezery mezi načítanými symboluy tak, ať každý řádek obsahuje pouze 4 znaky a dynamicky přidá jednotlivé symboly na řádcích jako pravidla.

Následně získá poslední řádek, který je chápán jako páska, kterou předá dále ke zpracaování.

V každé rekurzivní "iteraci" získá aktuální čtený symbol pásky, vloží do pásky aktuální stav a tento výstup přidá v případě nalezení finálního stavu do výstupního seznamu posloupností.

Následně získá na základě aktuálního stavu a znaku z množiny pravidel další možné stavy a znaky.

Na pásce nahradí odpovídající znak tím, který odpovídá pravidlu. Pokud byl tento znak L/R, tak dekrementuje, respektive inkrementuje aktuální index, který reprezentuje hlavici. Pásku přepíše pouze, pokud se o tyto znaky nejednalo.

Následně se rekurzivně spustí s novou páskou a novým stavem. Pokud byl v pravidlu znak L/R, tak se spustí s původní páskou, ale posunutou hlavicí.

V případě, že dojde do koncového stavu, tedy na vstupu má stav *F*, získá finální konfiguraci pásky a vloží ji do seznamu, který vrátí. Rekurzivně se do něj poté přidají i další konfigurace, které k výsledku vedly.

Seznam obsahující výsledné konfigurace pásky se nakonec výpíše na výstup.

V případě, že TS dojde na poslední symbol pásky (před nekonečnou posloupností symbolů blank), tedy vstup bude např jako níže, přidá tento symbol blank pod "hlavu" jako aktuální čtený symbol a blank v podobě mezery bude tedy součástí výstupní posloupnosti: Sa -> aF*, kde * značí mezeru, ovšem na výstupu bude skutečná mezera, zde je symbol * pouze ilustrativní pro lepší čitelnost.
```
S a F R
a
```

Pokud dojde k abnormálnímu zastavení (není kam přejít z aktuálního stavu a ten zároveň není koncovým), program končí a nevypisuje nic.

Pokud dojde k tomu, že by se TS měl zacyklit, konkrétně např. se vstupem níže (viz tests/input12.txt), program to detekuje tím, že porovnává 2 předchozí pásky s aktuální páskou a pokud najde shodu, tak větev výpočtu skončí a backtrackingem zkusí jinou. Jelikož ve vstupu níže žádná "jiná" větev není, tak program obdobně jako v případě abnormálního zastavení končí a nevypisuje nic.
```
S a S a
aaaaaaaaaaa
```

## Omezení
Program funguje pouze na validní vstupy - očekává, že zadaná pravidla budou obsahovat posloupnost od startujícího (S) stavu až do cílového (F) stavu.

Program očekává, že formát pravidel bude validní (Stav, znak, NovýStav, NovýZnak|R|L) - tak, jak je uvedeno v zadání.

Obdobně program předpokládá, že na posledním řádku vstupu bude páska, za kterou ještě může (a nemusí) následovat newline.
