## FLP 2023 Projekt 2 -- Turingův stroj
### Autor: Vojtěch Fiala \<xfiala61\>

## Návod k použití
Program lze přeložit příkazem *make* v kořenové složce.
Spustit lze program například jako ./flp22-log < input.txt > output.txt

## Popis řešení
Řešení využívá poskytnuté predikáty pro načítání vstupu.
Z těch následně odstraní poslední řádek (očekávanou pásku), z jednotlivých řádků odstraní mezery ať každý řádek obsahuje pouze 4 znaky a dynamicky přidá jednotlivé řádky jako pravidla.

Následně získá poslední řádek, který je chápán jako páska, kterou předá dále ke zpracaování.
V každé rekurzivní iteraci získá aktuální čtený symbol pásky, vloží do pásky aktuální stav a tento výstup přidá v případě nalezení finálního stavu do výstupního seznamu posloupností.
Následně získá na základě aktuálního stavu a znaku z množiny pravidel další možné stavy a znaky.
Na pásce nahradí odpovídající znak tím, který odpovídá pravidlu. Pokud byl tento znak L/R, tak dekrementuje, respektive inkrementuje aktuální index, který reprezentuje hlavici. Pásku přepíše pouze, pokud se o tyto znaky nejednalo.
Následně se rekurzivně spustí s novou páskou a novým stavem. Pokud byl v pravidlu znak L/R, tak se spustí s původní páskou, ale posunutou hlavicí.
V případě, že dojde do koncového stavu, tedy na vstupu má stav *F*, získá finální konfiguraci pásky a vloží ji do seznamu, který vrátí. Rekurzivně se do něj poté přidají i další konfigurace, které k výsledku vedly.

Seznam obsahující výsledné konfigurace pásky se nakonec výpíše na výstup.

## Omezení
Program funguje pouze na validní vstupy - očekává, že zadaná pravidla budou obsahovat posloupnost od startujícího (S) stavu až do cílového (F) stavu.
Pokud tato posloupnost nalezena není, program cyklí.
Program očekává, že formát pravidel bude validní (Stav, znak, NovýStav, NovýZnak|R|L).
Obdobně program předpokládá, že na posledním řádku vstupu bude páska, za kterou ještě může (a nemusí) následovat newline.
