### Part 1.  Create the data frame from XML file

### (a) Load the data frame called LatLon from hw7.rda. 
load("/Users/lynn/Desktop/hw7.rda")
### (b) Download the gzipped XML factbook document from
### http://jmatchparser.sourceforge.net/factbook/
### and create an XML "tree" in R 
doc = xmlParse("/Users/lynn/Desktop/factbook.xml")
doc.list = xmlToList(doc)
catalog = xmlRoot(doc)

### (c) Use XPath to extract the infant mortality and the CIA country codes from the XML tree

getNodeSet(catalog, '//field[@name="Infant mortality rate"]')
getNodeSet(catalog, '//field[@name="Population"]')
infant = xpathSApply(doc, "//field[@name='Infant mortality rate']/rank", xmlGetAttr, "number")
country = xpathSApply(doc, "//field[@name='Infant mortality rate']/rank", xmlGetAttr, "country")
infant
country
### (d) Create a data frame called IM using this XML file.

IM = data.frame(infant,country)
### (e) Extract the country populations from the same XML document
### Create a data frame called Pop using these data.

population = xpathSApply(doc, "//field[@name='Population']/rank", xmlGetAttr, "number")
country = xpathSApply(doc, "//field[@name='Population']/rank", xmlGetAttr, "country")
Pop = data.frame(population,country)


### (f) Merge the two data frames to create a data frame called IMPop with 3 columns:
### IM, Pop, and CIA.Codes
IMPop = merge(IM,Pop, all = FALSE)
### (g)Merge IMPop with LatLon (from newLatLon.rda) to create a data frame called AllData that has 6 columns
### for Latitude, Longitude, CIA.Codes, Country Name, Population, and Infant Mortality

names(IMPop)[names(IMPop)=="country"]="CIA.Codes"
IMPop$CIA.Codes = toupper(IMPop$CIA.Codes)
AllData = merge(IMPop,LatLon,all = FALSE)

### Part 2.  Create a KML document for google earth visualization.


makeBaseDocument = function(){
### This code creates the template for KML document

xml_doc = newXMLDoc()
root = newXMLNode(name = "kml",namespaceDefinitions = c("http://www.opengis.net/kml/2.2"), doc = xml_doc)
document = newXMLNode(name = "Document", parent = root, doc = xml_doc)
newXMLNode(name = "Name","Country Facts",parent = document,doc = xml_doc)
newXMLNode("Description","Infant Motality",parent = document,doc = xml_doc)
lookat = newXMLNode(name = "Lookat", parent = document, doc = xml_doc)
folder = newXMLNode("Folder",parent = document,doc = xml_doc)
newXMLNode("Name","CIA Fact Book",parent = folder,doc = xml_doc)
newXMLNode("longitude","-121",parent = lookat,doc = xml_doc)
newXMLNode("latitude","43",parent = lookat,doc = xml_doc)
newXMLNode("altitude","4100000",parent = lookat,doc = xml_doc)
newXMLNode("title","0",parent = lookat,doc = xml_doc)
newXMLNode("heading","0",parent = lookat,doc = xml_doc)
newXMLNode("altitudeMode","absolute",parent = lookat,doc = xml_doc)
return(xml_doc)
}

kml_doc = makeBaseDocument()
kml_root =  xmlRoot(kml_doc)
kml_root_children =  xmlChildren(kml_doc)
kml_document_node = kml_root_children[[1]][[1]]
kml_lookat_node = kml_root_children[[1]][[1]][[3]]
kml_folder_node = kml_root_children[[1]][[1]][[4]]
kml_doc

addPlacemark = function(lat, lon, ctryCode, ctryName, pop, infM, parent, 
                        inf1, pop1, style = FALSE)
{
  pm = newXMLNode("Placemark", 
                  newXMLNode("name", ctryName), attrs = c(id = ctryCode), 
                  parent = parent)
  newXMLNode("description", paste(ctryName, "\n Population: ", pop, 
                                  "\n Infant Mortality: ", infM, sep =""),parent = pm)

  newXMLNode("Point",newXMLNode("coordinates",paste(lon,",",lat,",",0,sep = "")),parent = pm) ### Your code here)


  if(style) newXMLNode("styleUrl", paste("#YOR", inf1, "-", pop1, sep = ''), parent = pm)
}
for (i in 1:(dim(AllData)[1])){
  addPlacemark(lat = AllData$Latitude[[i]],lon = AllData$Longitude[[i]],ctryCode = AllData$CIA.Codes[[i]],
               ctryName = AllData$Country.Name[[i]],pop = AllData$population[[i]],infM = AllData$infant[[i]],parent = kml_document_node)
}


saveXML(kml_doc, "Part2.kml")

### Part 3.  Add Style to KML
### Use different circle labels for countris with size representing population and the color representing the infant motality rate.


doc2 = makeBaseDocument()

### create cut points for different categories of infant mortality and population size.

infCut = cut(as.numeric(as.character(AllData$infant)), breaks = c(0, 10, 25, 50, 75, 200))
infCut = as.numeric(infCut)
popCut = cut(log(as.numeric(as.character(AllData$population))), breaks = 5)
popCut = as.numeric(popCut)
AllData$popcut = as.numeric(popCut)
AllData$infcut = as.numeric(infCut)

scale = c(0.5,1,2,3.5,5.5) #Try your scale here for better visualization
colors = c("blue","green","yellow","orange","red")

addStyle = function(col1, pop1, parent, DirBase, scales = scale)
{
  st = newXMLNode("Style", attrs = c("id" = paste("YOR", col1, "-", pop1, sep="")), parent = parent)
  newXMLNode("IconStyle", 
             newXMLNode("scale", scales[pop1]), 
             newXMLNode("Icon", paste(DirBase, "color_label_circle_", colors[col1], ".png", sep ="")), parent = st)
}


root2 = xmlRoot(doc2)
DocNode = root2[["Document"]]


for (k in 1:5)
{
  for (j in 1:5)
  {
    addStyle(j, k, DocNode, '/Users/lynn/Desktop/color_label_circle/')
  }
}


for (i in 1:(dim(AllData)[1])){
  addPlacemark(lat = AllData$Latitude[[i]],lon = AllData$Longitude[[i]],ctryCode = AllData$CIA.Codes[[i]],
               ctryName = AllData$Country.Name[[i]],pop = AllData$population[[i]],infM = AllData$infant[[i]],parent = DocNode,inf1 = infCut[i],pop1 = popCut[i],style = TRUE)
}

###  Save it as Part3.kml and open it in Google Earth
saveXML(doc2, "Part3.kml")