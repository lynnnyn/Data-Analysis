## My Analysis for Infant Mortality Visualization

### DataSet 
<http://jmatchparser.sourceforge.net/factbook/>

### Tools
*   R
*   XML
*   Google Earth

### Steps
1. Create the data frame from XML file
    1. Use XPath to extract the infant mortality and the CIA country codes from the XML tree
    2. Create a data frame called IM using this XML file.
    3. Merge the two data frames to create a data frame called IMPop with 3 columns: IM, Pop, and CIA.
    4. Merge IMPop with LatLon (from newLatLon.rda) to create a data frame called AllData that has 6 columns for Latitude, Longitude, CIA.Codes, Country Name, Population, and Infant Mortality
2. Create a KML document for google earth visualization.
3. Add Style to KML
    1. create cut points for different categories of infant mortality and population size.
    2. Save it as Part3.kml and open it in Google Earth
    
### Visualization
![alt text](https://github.com/lynnnyn/Data-Analysis/blob/master/Infant%20Mortality%20Visualization/infant.png)