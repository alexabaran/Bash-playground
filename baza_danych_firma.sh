#!/bin/bash

# Debuggowanie w razie potrzeby
# set -x

# ***** PROJEKT BASH -  SYSTEMY OPERACYJNE *****
# Data utworzenia: 13.01.2025

# Skrypt tworzy baze danych firmowych (Jesli nie istnieje) w formacie CSV - liste pracownikow oraz liste dzialow.

# Uzycie:
# Dane wejsciowe ID pracownika, Imie, Nazwisko, ID dzialu, nazwa dzialu
# Skrypt umozliwia: dodawanie danych, wyswietalnie danych, edytowanie i modyfikacja danych.
# Skrypt obsluguje bledy: Tabela isnieje/Nie istnieje, Duplikaty danych w ID - ID musi byc unikalne

echo "Witam w programie do tworzenia bazy danych pracownikow"


# Plan MENU GLOWNE i funkcjonalnosc programu

menu_glowne()
{
while true;
do
	echo ""
	echo " *** MENU GLOWNE *** "
	echo "0. Wyjscie z programu"
	echo "1. Stworz baze danych dzialow firmy"
	echo "2. Stworz baze danych pracownikow firmy"
	echo "3. Dodaj dzial firmy"
	echo "4. Dodaj dane pracownika"
	echo "5. Wyswietl dane dla dzialow"
	echo "6. Wyswietl dane dla pracownikow"
	echo "7. Modyfikuj dane pracownika"
	echo "8. Usun dane pracownika"
	echo "-------------------------------------------------"

	read -p "Prosze o wybranie opcji z menu glownego: " wybor

	echo "-------------------------------------------------"

	case $wybor in
		0) echo "Do Widzenia!!!"; exit 0;;
		1) stworz_bd_dzialy;;
		2) stworz_bd_pracownicy;;
		3) dodaj_dzial;;
		4) dodaj_pracownika;;
		5) wyswietl_dane "firma_dzialy.csv";;
		6) wyswietl_dane "firma_pracownicy.csv";;
		7) modyfikuj_pracownika;;
		8) usun_pracownika;;
		*) echo "Bledny wybor! Sprobuj ponownie wybrac opcje z MENU GLOWNEGO";;
		esac
	done
}

# FUNKCJE TWORZENIA BAZY DANYCH:

# DZIALY
# Sprawdzenie czy BD istnieje - jesli tak wylapanie bledu!
stworz_bd_dzialy()
{
	local plik="firma_dzialy.csv"
	if [[ -f $plik ]];
		then
		echo "Tabela $plik juz istnieje. Nie Mozna stworzyc nowej."
		return
	fi
	echo "ID_Dzialu,Nazwa_Dzialu,ID_Kierownika" > "$plik"
	echo "Baza danych dzialow utworzona poprawnie"
}

# PRACOWNICY
# Sprawdzenie czy BD istnieje - jesli tak wylapanie bledu!
stworz_bd_pracownicy()
{
	local plik="firma_pracownicy.csv"
	if [[ -f $plik ]];
		then
		echo "Tabela $plik juz istnieje. Nie Mozna stworzyc nowej."
		return
	fi
	echo "ID_Pracownika,Imie,Nazwisko,ID_Dzialu" > "$plik"
	echo "Baza danych pracownikow utworzona poprawnie"
}

# FUNKCJE DODAWANIA DANYCH DO TABELI

# DZIALY
dodaj_dzial()
{
	local plik="firma_dzialy.csv"

	# Dzialy
	if [[ ! -f $plik ]];
		then
		echo "Baza danych $plik nie istnieje. Prosze ja najpierw utworzyc"
		return
	fi

	read -p "Prosze podac identyfikator dzialu: " id_dzialu

	# sprawdzenie czy ID sie nie powtarza - obsluga wyjatku
	is_unique "$plik" "$id_dzialu"
	if [[ $? -ne 0 ]];
		then
		echo "ID dzialu: $id_dzialu juz istnieje. Prosze o sprawdzenie ID!"
		return
	fi

	read -p "Prosze podac nazwe dzialu: " nazwa_dzialu
	read -p "Prosze podac ID Kierownika dzialu: " id_kierownika

	echo "$id_dzialu,$nazwa_dzialu,$id_kierownika" >> "$plik"
	echo "Dzial zostal dodany pomyslnie"
}

# PRACOWNICY
dodaj_pracownika()
{
	local plik_prac="firma_pracownicy.csv"
	local plik_dzial="firma_dzialy.csv"

	# Sprawdzenie czy bazy danych istnieja:
	# Pracownicy
	if [[ ! -f $plik_prac ]];
		then
		echo "Baza danych $plik_prac nie istnieje. Prosze ja najpierw utworzyc"
		return
	fi

	# Dzialy
	if [[ ! -f $plik_dzial ]];
		then
		echo "Baza danych $plik_dzial nie istnieje. Prosze ja najpierw utworzyc"
		return
	fi

	read -p "Prosze podac identyfikator pracownika: " id_pracownika

	# sprawdzenie czy ID sie nie powtarza - obsluga wyjatku
	is_unique "$plik_prac" "$id_pracownika"
	if [[ $? -ne 0 ]];
		then
		echo "ID pracownika: $id_pracownika juz istnieje. Prosze o sprawdzenie ID!"
		return
	fi

	read -p "Prosze podac imie pracownika: " imie
	read -p "Prosze podac nazwisko pracownika: " nazwisko

	echo ""
	echo "Lista dostepnych dzialow: "
	column -s, -t "$plik_dzial"
	echo ""
	read -p "Prosze podac identyfikator dzialu do jakiego nalezy pracownik: " id_dzialu
	
	# sprawdzenie czy ID dzialu poprawne
	if ! grep -q "^$id_dzialu," "$plik_dzial";
		then
		echo "Nieprawidlowe ID dzialu!"
		return
	fi

	echo "$id_pracownika,$imie,$nazwisko,$id_dzialu" >> "$plik_prac"
	echo "Pracownik zostal dodany pomyslnie"
}

# Wprowadzamy dodatkowa funkcje ktora nam sprawdzi czy Identyfikatory pracownikow lub dzialow sie nie powtarzaja.

is_unique()
{
	local plik=$1
	local id=$2
	if grep -q "^$id," "$plik";
		then
		return 1 # ID istnieje!
	fi
	return 0
}

# Funkcja ktora nam wyswietla tabele
wyswietl_dane()
{
	clear
	local plik=$1
	if [[ ! -f $plik ]];
		then
		echo "Tabela $file nie istnieje! Prosze ja najpierw utworzyc"
		return
	fi
	column -s, -t "$plik"
	
	echo ""
	read -p "Enter by kontynuowac..."
}

# Funkcja do modyfikowania danych pracownika
modyfikuj_pracownika()
{
	local plik="firma_pracownicy.csv"
	if [[ ! -f $plik ]];
		then
		echo "Tabela $file nie istnieje! Prosze ja najpierw utworzyc"
		return
	fi
	column -s, -t "$plik"
	
	read -p "Prosze podac ID pracownika do modyfikacji: " id_pracownika
	
	if ! grep -q "^$id_pracownika," "$plik";
		then
		echo "Pracownik o ID $id_pracownika nie istnieje!"
		return
	fi
	
	read -p "Prosze podac imie pracownika: " nowe_imie
	read -p "Prosze podac nazwisko pracownika: " nowe_nazwisko
	read -p "Prosze podac identyfikator dzialu do jakiego nalezy pracownik: " nowe_id_dzialu
 
	awk -F"," -v OFS="," -v id="$id_pracownika" -v imie="$nowe_imie" -v nazwisko="$nowe_nazwisko" -v dzial="$nowe_id_dzialu" \
    '$1 == id {$2 = imie; $3 = nazwisko; $4 = dzial} 1' "$plik" > temp && mv temp "$plik"
	#  wynik dzialania awk jest zapisany do tymczasowego pliku i jesli awk zakonczy sie sukcesem nadpisuje temp na plik.
	echo "Dane pracownika zostaly zmodyfikowane"
}

# Funkcja do usuwania danych pracownika
usun_pracownika()
{
	local plik="firma_pracownicy.csv"
	if [[ ! -f $plik ]];
		then
		echo "Tabela $file nie istnieje! Prosze ja najpierw utworzyc"
		return
	fi
	column -s, -t "$plik"
	read -p "Prosze podac ID pracownika do usuniecia: " id_pracownika
	if ! grep -q "^$id_pracownika," "$plik";
		then
		echo "Pracownik o ID $id_pracownika nie istnieje!"
		return
	fi
	grep -v "^$id_pracownika," "$plik" > temp && mv temp "$plik"
	echo "Pracownik zostal usuniety"	
}

menu_glowne
