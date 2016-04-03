# Skrpyt SQL pozwalający na utworzenie hurtowni danych z wersjonowaniem SCD1 i SCD2

# Zadanie: Zaprojektuj i zaimplementuj moduł ładowania danych systemu DSA.

System DSA:
Wstępna warstwa hurtowni danych, której głównym modułem jest repozytorium danych utworzone na bazie danych Oracle w schemacie XX_SCHOOL.

W repozytorium DSA utrzymywane są dane bieżące i historyczne (wersjonowane dziennie) w postaci tabel płaskich o strukturze odpowiadającej 1:1 tabelom źródłowym, plus kolumny techniczne. 

Wyróżniamy 2 rodzaje tabel różniące się wersjonowaniem danych historycznych: 
- migawki (dla każdej daty ładowania pełny zestaw danych)
- kartoteki (dodawane tylko dane zmienione, wersjonowanie SCD2, identyfikacja że zmiana dotyczy danego rekordu na podstawie PK). 

Zestaw kolumn technicznych: 
- migawka: 
	T_DATESTAMP DATE (data ładowania); 

- kartoteka: 
	T_STARTDATE DATE (początek obowiązywania wersji), 
	T_ENDDATE DATE (koniec obowiązywania wersji), 
	T_STATUS NUMBER(1) (2-rekord usunięty, 0-rekord dostępny). 

Na tabelach utrzymywane są klucze główne odpowiadające kluczowi biznesowemu tabeli źródłowej plus kolumna techniczna wersjonowania (T_DATESTAMP – migawka, T_STARTDATE - kartoteka).

Obecnie planowane jest ładowanie do DSA tabel ze schematu SH:

Migawki:
	- PROMOTIONS
	- SALES

Kartoteki:
	- COUNTRIES
	- CHANNELS
	- CUSTOMERS
	- PRODUCTS

W ramach zadania przygotuj i wykonaj skrypty tworzące ww. tabele w bazie. Tabele te  powinny mieć nazwy składające się ze systemu źródłowego (schematu) i nazwy tabeli źródłowej, np. SH_SALES.

Moduł ładujący DSA:

Moduł ładujący powinien posiadać następujące cechy:
	1.	Generyczność i elastyczność – rozbudowa modułu powinna sprowadzać się do minimalnych działań – utworzenie tabeli w repozytorium i dodania jednostki programowej z nazwą systemu źródłowego i tabeli źródłowej.
	Zmiany ogólne do ładowania (np. wartość ustawiana dla pierwszej wersji rekordu w kolumnie T_STARTDATE powinny być łatwe do wprowadzenia (w jednym miejscu).
	Informacje o strukturach tabel można pobierać z widoków Oracle USER_* i ALL_*, np. USER_TAB_COLUMNS.

	2.	Wersjonowanie – moduł powinien umożliwiać wyznaczanie przyrostu dla tabel typu kartoteka (wersjonowanie SCD2). W tabelach źródłowych dostępne są wszystkie dane bieżące (brak danych historycznych). Moduł przy uruchamianiu za kolejne daty powinien porównywać bieżącą wersję w DSA (jak rozpoznać?) i dane dostępne w systemie źródłowym i wyznaczyć przyrost (z usunięciami) i załadować przyrost.
	Do przetestowania wykonaj tymczasowe zmiany w tabeli źródłowej, data ładowania powinna być logiczna (parametr ładowania).

	-- na później -- 3.	Wysoka wydajność – moduł powinien wykorzystywać dostępne mechanizmy PL/SQL i obiekty bazodanowe umożliwiające ładowanie i wersjonowanie z dużą wydajnością.

	4.	Mechanizm logowania – procesy realizujące ładowanie poszczególnych tabel powinny logować komunikaty o swoim przebiegu. Mechanizm powinien składać się min. z:
		- tabeli logu z komunikatami (umożliwiającej łatwą identyfikację logu przebiegu poszczególnych procesów w porządku historycznym komunikatów).
		- tabeli słownikowej komunikatów zawierającej listę wykorzystywanych komunikatów z identyfikatorem. Komunikaty powinny być trzech typów (informacja, ostrzeżenie, błąd) identyfikowanymi np. przez zakres identyfikatorów (np. 3000-3999 - błędy). Uwaga – część komunikatów powinna zawierać elementy zmienne, np. liczba załadowanych wierszy.

	5.	Obsługa błędów – moduł powinien obsługiwać ewentualne błędy z wykorzystaniem mechanizmu logowania (zapisanie stosownego komunikatu w logu). Błędy danych (w zależności od parametryzacji dla poszczególnych procesów) powinny być obsługiwane poprzez:
		- odrzucenie wierszy błędnych z odpowiednim komunikatem i załadowanie wszystkich poprawnych
		- pojawienie się krytycznego błędu ładowania – nie załadowanie żadnego wiersza.

	6.	Łatwość utrzymania – moduł powinien być napisany starannie z zastosowaniem spójnego stylu programowania, formatowania i komentarzami tak żeby umożliwić łatwość utrzymania, a wypracowane jednostki mogły stać się wzorcami do stosowania przy nowych projektach.

	7.	Uniwersalność – przy projektowaniu modułu powinien zostać rozważony i zaproponowany sposób zastosowania modułu do ładowania tabel „nie wprost” (programista indywidualnie musi napisać kod ładujący, najlepiej sprowadzający się do kodu SQL, ponieważ w jednym procesie, na podstawie danych z wielu tabel może być ładowana jedna lub wiele tabel). Jeżeli jest możliwość zastosowania konstrukcji ułatwiających takie użycie modułu powinny one zostać zaimplementowane.





