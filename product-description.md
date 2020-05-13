# COVID-19 Deutschland Daten | Robert Koch-Institut (RKI)

# COVID-19 Germany Data | Robert Koch Institute (RKI)

The source code outlining how this product gathers, transforms, revises and publishes its datasets is available at [https://github.com/rearc-data/covid-19-deutschland-robert-koch-institut](https://github.com/rearc-data/covid-19-deutschland-robert-koch-institut).

## Main Overview

This resource is produced by the Robert Koch Institute (RKI), and updates daily with details regarding the current number of COVID-19 cases in Germany.

Note: The dataset included with this product is in German.

#### Data Source
The included dataset is presented in CSV and JSON format, and features the following columns:

- `FID` (ObjectId): Unique ID for reach entry in the dataset
- `IdBundesland` (StateId): Id of the federal state of the case
- `Bundesland` (State): Name of state
- `Landkreis` (County): Name of the county
- `Altersgruppe` (AgeGroup): Age group of the case from the 6 groups 0-4, 5-14, 15-34, 35-59, 60-79, 80+ and unknown
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
- `Altersgruppe2` (AgeGroup2): Age group of the case from 5-year groups 0-4, 5-9, 10-14, ..., 75-79, 80+ and unknown

## Contact Details
- If you find any issues or have enhancements with this product, open up a GitHub [issue](https://github.com/rearc-data/covid-19-deutschland-robert-koch-institut/issues) and we will gladly take a look at it. Better yet, submit a pull request. Any contributions you make are greatly appreciated :heart:.
- If you are interested in any other open datasets, please create a request on our project board [here](https://github.com/rearc-data/covid-datasets-aws-data-exchange/projects/1).
- If you have questions about this source data, please contact the Robert Koch Institute.
- If you have any other questions or feedback, send us an email at data@rearc.io.

## More Information
- Source - [RKI COVID19](https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0) 
- [Robert Koch Institute](https://www.rki.de/EN/Home/homepage_node.html)
- [Federal Agency for Cartography and Geodesy](https://www.bkg.bund.de/DE/Home/home.html)
- Frequency: Daily
- Formats: CSV, JSON