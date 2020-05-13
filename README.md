<a href="https://www.rearc.io/data/">
    <img src="./rearc_logo_rgb.png" alt="Rearc Logo" title="Rearc Logo" height="52" />
</a>

**English README is presented after the German README**

# COVID-19 Deutschland Daten | Robert Koch-Institut (RKI)

Sie können das AWS Data Exchange-Produkt mithilfe der in diesem Repository enthaltenen Automatisierung unter []() abonnieren.

## Hauptübersicht
Die QuellDaten werden vom Robert Koch-Institut (RKI) erstellt und täglich mit Details zur aktuellen Anzahl von COVID-19-Fällen in Deutschland aktualisiert.

#### Datenquelle
Der Datensatz wird im CSV- und JSON-Format dargestellt und enthält die folgenden Spalten:
- `FID`: Eindeutige ID für den  Datensatz
- `IdBundesland`: Id des Bundeslands des Falles
- `Bundesland`: Name des Bundeslanes
- `Landkreis`: Name des Landkreises
- `Altersgruppe`: Altersgruppe des Falles aus den 6 Gruppe 0-4, 5-14, 15-34, 35-59, 60-79, 80+, sowie unbekannt
- `Geschlecht`: Geschlecht des Falles
- `AnzahlFall`: Anzahl der Fälle in der entsprechenden Gruppe
- `AnzahlTodesfall`: Anzahl der Todesfälle in der entsprechenden Gruppe
- `Meldedatum`: Datum, wann der Fall dem Gesundheitsamt bekannt geworden ist
- `IdLandkreis`: Id des Landkreises des Falles
- `Datenstand`:  Datum, wann der Datensatz zuletzt aktualisiert worden ist
- `NeuerFall`:
    * `0`: Fall ist in der Publikation für den aktuellen Tag und in der Publikation für den Vortag enthalten
    * `1`: Fall ist nur in der aktuellen Publikation enthalten
    * `-1`: Fall ist nur in der Publikation des Vortags enthalten
- `NeuerTodesfall`:
    * `0`: Fall ist in der Publikation für den aktuellen Tag und in der Publikation für den Vortag jeweils ein Todesfall
    * `1`: Fall ist in der aktuellen Publikation ein Todesfall, nicht jedoch in der Publikation des Vortages
    * `-1`: Fall ist in der aktuellen Publikation kein Todesfall, jedoch war er in der Publikation des Vortags ein Todesfall
    * `-9`: Fall ist weder in der aktuellen Publikation noch in der des Vortages ein Todesfall
- `Refdatum`
- `NeuGenesen`:
    * `0`: Fall ist in der Publikation für den aktuellen Tag und in der Publikation für den Vortag jeweils Genesen
    * `1`: Fall ist in der aktuellen Publikation Genesen, nicht jedoch in der Publikation des Vortages
    * `-1`: Fall ist in der aktuellen Publikation nicht Genesen, jedoch war er in der Publikation des Vortags Genesen
    * `-9`: Fall ist weder in der aktuellen Publikation noch in der des Vortages Genesen
- `AnzahlGenesen`: Anzahl der Genesenen in der entsprechenden Gruppe
- `IstErkrankungsbeginn`: `1`, wenn das `Refdatum` der Erkrankungsbeginn ist, `0` sonst
- `Altersgruppe2`: Altersgruppe des Falles aus 5-Jahresgruppen 0-4, 5-9, 10-14, ..., 75-79, 80+, sowie unbekannt

## Kontaktdetails
- Wenn Sie Probleme oder Verbesserungen mit diesem Produkt feststellen, öffnen Sie ein GitHub [issue](https://github.com/rearc-data/covid-19-deutschland-robert-koch-institut/issues), und wir werden es uns gerne ansehen. Besser noch, senden Sie eine Pull-Anfrage. Alle Beiträge, die Sie leisten, werden sehr geschätzt :heart:.
- Wenn Sie an anderen offenen Datensätzen interessiert sind, erstellen Sie bitte eine Anfrage in unserem Projektboard [hier](https://github.com/rearc-data/covid-datasets-aws-data-exchange/projects/1).
- Bei Fragen zu den Quelldaten wenden Sie sich bitte an das Robert Koch Institut.
- Wenn Sie weitere Fragen oder Feedback haben, senden Sie uns eine E-Mail an data@rearc.io(opens in new tab).

## Mehr Informationen
- Quelle - [RKI COVID19](https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0)
- [Robert Koch-Institut](https://www.rki.de/DE/Home/homepage_node.html)
- [Bundesamt für Kartographie und Geodäsie](https://www.bkg.bund.de/DE/Home/home.html)
- Häufigkeit: Täglich
- Formate: CSV, JSON

---

# COVID-19 Germany Data | Robert Koch Institute (RKI)

You can subscribe to the AWS Data Exchange product utilizing the automation featured in this repository by visiting []().

## Main Overview

This resource is produced by the Robert Koch Institute (RKI), and updates daily with details regarding the current number of COVID-19 cases in Germany.

Note, The dataset included with this product is in German.

#### Data Source
The included dataset is presented in CSV and JSON format, and features the following columns:

- `FID` (ObjectId): Unique ID for reach entry in the dataset
- `IdBundesland` (StateId): Id of the federal state of the case
- `Bundesland` (State): Name of state
- `Landkreis` (County): Name of the county
- `Altersgruppe` (AgeGroup): Age group of the case from the 6 groups 0-4, 5-14, 15-34, 35-59, 60-79, 80+, and unknown
- `Geschlecht` (Gender): Gender of case
- `AnzahlFall` (NumberOfCases): Number of cases in the corresponding group
- `AnzahlTodesfall` (NumberOfDeaths): Number of deaths in the corresponding group
- `Meldedatum` (RegistrationDate): Date when the case became known to the health department
- `IdLandkreis` (CountyId): Id of the county of the case
- `Datenstand` (DateStatus): Date when the data record was last updated
- `NeuerFall` (NewCase):
    * `0`: Case is included in the publication for the current day and in the one for the previous day
    * `1`: Case is only included in the current publication
    * `-1`: Case is only included in the previous day's publication
- `NeuerTodesfall` (NewDeath):
    * `0`: In the publication, there is one death for the current day and one for the previous day
    * `1`: In the current publication, the case is a death, but not in the previous day's publication
    * `-1`: The case is not a death in the current publication, but it was a death in the previous day's publication
    * `-9`: The case is neither a death in the current publication nor in the previous day
- `Refdatum` (RefDate)
- `NeuGenesen` (NewRecovery):
    * `0`: The case is in the publication for the current day and in the one for the previous day
    * `1`: Case is recovered in the current publication, but not in the previous day's publication
    * `-1`: Case is not recovered in the current publication, but it was recovered in the publication of the previous day
    * `-9`: The case is neither recovered in the current publication nor in the previous day
- `AnzahlGenesen` (NumberOfRecoveries): Number of recoveries in the corresponding group
- `IstErkrankungsbeginn` (IsOnsetOfIllness): `1` if `Refdatum` is the onset of illness, `0` otherwise
- `Altersgruppe2` (AgeGroup2): Age group of the case from 5-year groups 0-4, 5-9, 10-14, ..., 75-79, 80+, and unknown

## Contact Details
- If you find any issues or have enhancements with this product, open up a GitHub [issue](https://github.com/rearc-data/covid-19-deutschland-robert-koch-institut/issues) and we will gladly take a look at it. Better yet, submit a pull request. Any contributions you make are greatly appreciated :heart:.
- If you are interested in any other open datasets, please create a request on our project board [here](https://github.com/rearc-data/covid-datasets-aws-data-exchange/projects/1).
- If you have questions about this source data, please contact the Robert Koch Institute.
- If you have any other questions or feedback, send us an email at data@rearc.io.

## More Information
- Source - [RKI COVID19](https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0) | Note, this webpage is in German
- [Robert Koch Institute](https://www.rki.de/EN/Home/homepage_node.html)
- [Federal Agency for Cartography and Geodesy](https://www.bkg.bund.de/EN/Home/home.html)
- Frequency: Daily
- Formats: CSV, JSON