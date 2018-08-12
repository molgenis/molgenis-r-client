# MOLGENIS R-api

The MOLGENIS R-api can communicate with an MOLGENIS instance and perform actions on that instance.

## Usage

As an example, let's create a plot for publicly available ASE data available on https://molgenis56.target.rug.nl/. For a description of the data, take a look at [http://molgenis.org/ase](http://molgenis.org/ase).

Start up the R environment.

In the shell type:

```r
install.packages("molgenisRApi", dependencies = TRUE)
library(molgenisRApi)
```

This loads the R API from the CRAN. If you take a look in your workspace by typing

```
ls()
```
You should see that a couple functions have been added for you to use:

```
 [1] "molgenis.add"                  "molgenis.addAll"               "molgenis.addList"              "molgenis.delete"               "molgenis.env"                
 [6] "molgenis.get"                  "molgenis.getAttributeMetaData" "molgenis.getEntityMetaData"    "molgenis.login"                "molgenis.logout"              
[11] "molgenis.update"     
```

Let's load some data from the server using `molgenis.get`:

```
molgenis.get("ASE")
```

This retrieves the top 1000 rows from the ASE entity.

```
P_Value Samples      SNP_ID Chr       Pos                           Genes
1    0.000000000000000020650473933963698652198164782417962682333833636491755847419682368126814253628253936767578125000000000000000000000000000000000000000000000000000000000000000000000     145   rs9901673  17   7484101 ENSG00000129226,ENSG00000264772
2    0.000000000000000008781097353981130661746700850633192724259771276345502150073585312384238932281732559204101562500000000000000000000000000000000000000000000000000000000000000000000     359   rs2597775   4  17503382                 ENSG00000151552
3    0.000000000000000001491745894983400057481059632909089858257546335023040629669255352496293198782950639724731445312500000000000000000000000000000000000000000000000000000000000000000     301      rs3216  11    214421                 ENSG00000177963
[...]
1000 0.000132500824069775005771554265976419628714211285114288330078125000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000      47   rs1056019  12  41337435                 ENSG00000018236
```

Let's retrieve a specific SNP from the ASE entity:

```
molgenis.get("ASE", q="SNP_ID==rs12460890")
```

```
  Fraction_alternative_allele Likelihood_ratio_test_D Alternative_allele Reference_allele                P_Value Samples     SNP_ID Chr    Pos           Genes
1                       0.527                56.02079               TRUE                C 0.00000000000007170854      21 rs12460890  19 829568 ENSG00000172232
```

This SNP has a mild but significant allele-specific expression, based on expression counts in 21 samples.

Let's retrieve the samples for this SNP:

```
samples <- molgenis.get("SampleAse", q="SNP_ID==rs12460890")
print(samples)
```

```
       SNP_ID SampleIds Ref_Counts Alt_Counts Chromosome Position      ID
1  rs12460890 ERS194242        130        121         19   829568 1418785
2  rs12460890 ERS326942       4142       4791         19   829568 1418786
3  rs12460890 ERS327006         19         28         19   829568 1418787
4  rs12460890 SRS353551         19         23         19   829568 1418788
5  rs12460890 SRS271084         32         11         19   829568 1418789
6  rs12460890 SRS375020        639        572         19   829568 1418790
7  rs12460890 SRS375024        202        309         19   829568 1418791
8  rs12460890 SRS375022        423        401         19   829568 1418792
9  rs12460890 SRS375030        271        234         19   829568 1418793
10 rs12460890 SRS375026        806       1081         19   829568 1418794
11 rs12460890 SRS375027        213        201         19   829568 1418795
12 rs12460890 SRS376459         74         96         19   829568 1418796
13 rs12460890 SRS375032        730        655         19   829568 1418797
14 rs12460890 SRS376461        584        699         19   829568 1418798
15 rs12460890 SRS376464        331        391         19   829568 1418799
16 rs12460890 SRS376469         13         14         19   829568 1418800
17 rs12460890 SRS376467         70        101         19   829568 1418801
18 rs12460890 SRS376468         47         35         19   829568 1418802
19 rs12460890 SRS418748         19         28         19   829568 1418803
20 rs12460890 SRS418754         44         47         19   829568 1418804
21 rs12460890 SRS418755         60         55         19   829568 1418805
```

There they are.
Let's plot the expression counts in these samples in a scatter plot.

```
plot(samples$Ref_Counts, samples$Alt_Counts, xlim = c(0, 5000), ylim = c(0, 5000), xlab='Reference Allele', ylab='Alternative Allele', main = 'Allele-Specific Expression for rs12460890')
```

And add a line for the non-specific expression.

```
lines(c(0,5000), c(0, 5000))
```
![image](man/images/rs12460890-r.png)

# Methods

Here is an overview of the API-methods. 

> The query must be in [fiql/rsql format](https://github.com/jirutka/rsql-parser).

## login
```
molgenis.login("host url", "your username", "your password")
```

To access private data, you can log in using

This will create a molgenis token on the server and set it in the `molgenis.token` variable in your R workspace.
The method will also return the token, so you can catch it in a variable. ```token <- molgenis.login()```.

**Examples**
```r
token <- molgenis.login("https://molgenis01.gcc.rug.nl", "admin", "admin")
```


## logout
```r
molgenis.logout()
```
Logout from the MOLGENIS REST API and destroy the session.

## get
```r
molgenis.get (entity, q = NULL, start = 0, num = 1000, attributes = NULL)
```

Retrieves entities and returns the result in a dataframe.

Parameter   | Description                                       | Required | Default
------------|---------------------------------------------------|----------|--------
`entity`    | The entity name                                   | yes      |
`q`         | Query string in rsql/fiql format (see below)      | No       | NULL
`start`	    | The index of the thirst row to return             | No       | 0
`num`       | The maximum number of rows to return (max 10000) | No       | 1000
`attributes`| Vector of attributenames(columns) to return       | No       | All attributes
`sortColumn`| attributeName of the column to sort on            | No       | NULL
`sortOrder` | sort order, 'ASC' of 'DESC'                       | No       | NULL


> Supported RSQL/FIQL query operators (see [https://github.com/jirutka/rsql-parser](https://github.com/jirutka/rsql-parser))

Operator|Symbol
--------|------
Logical AND | `;` or `and`
Logical OR	| `,` or `or`
Group | `(` and `)`
Equal to | `==`
Less then | `=lt=` or `<`
Less then or equal to | `=le=` or `<=`
Greater than | `=gt=` or `>`
Greater tha or equal to | `=ge=` or `>=`

Argument can be a single value, or multiple values in parenthesis separated by comma. Value that doesn’t contain any reserved character or a white space can be unquoted, other arguments must be enclosed in single or double quotes.			
			
**Examples**

```
molgenis.get("celiacsprue")
molgenis.get("celiacsprue", num = 100000, start = 1000)
molgenis.get("celiacsprue", attributes = c("Individual", "celiac_gender"))
molgenis.get("celiacsprue", q = "(celiac_weight>=80 and celiac_height<180) or (celiac_gender==Female)")
molgenis.get("celiacsprue", q = "(celiac_weight>=80;celiac_height<180),(celiac_gender==Female)")

```

<br />
## add
```
molgenis.add(entity, ...)
```

Creates a new instance of an entity (i.e. a new row of the entity data table) and returns the id.

Parameter|Description|Required
---------|-----------|--------
entity| The entity name of the entity to create|yes
...| Var arg list of attribute names and values|yes

**Example**

```
id <- molgenis.add(entity = "Person", firstName = "Piet", lastName = "Paulusma")
```

## addAll
```
molgenis.addAll(entity, rows)
```

Creates new instances of an entity (i.e. adds new rows to the entity data table) and returns the ids.

Parameter|Description|Required
---------|-----------|--------
entity| The entity name of the entity to create|yes
rows| data frame where each row represents an entity instance|yes

**Example**

```
firstName <- c("Piet", "Paulusma")
lastName <- c("Klaas", "de Vries")
df <- data.frame(firstName, lastName)

molgenis.addAll("Person", df)
```

<br />
## update
```
molgenis.update(entity, id, ...)
```

Updates un existing entity

Parameter|Description|Required
---------|-----------|--------
entity| The entity name|yes
id| The id of the entity|Yes
...| Var arg list of attribute names and values|yes

**Example**

```
molgenis.update(entity = "Person", id = 8, firstName = "Pietje", lastName = "Paulusma")
```

## delete
```
molgenis.delete(entity, id)
```

Deletes an entity.

Parameter|Description|Required
---------|-----------|--------
entity| The entity name|yes
id| The id of the entity|Yes

**Example**

```
molgenis.delete(entity = "Person", id = 8)
```

## deleteList
```
molgenis.deleteList(entity, c("id1", "id2"))
```

Deletes a list of entities in an entityType.

Parameter|Description|Required
---------|-----------|--------
entity| The entityType name|yes
rows| List with ids of the rows|yes

**Example**

```
molgenis.deleteList(entity = "Person", rows = c("1", "2", "3"))
```

## getEntityMetaData
```
molgenis.getEntityMetaData(entity)
```

Gets the entity metadata as list.

**Example**

```
meta <- molgenis.getEntityMetaData("celiacsprue")
meta$label
```

## getAttributeMetaData
```
molgenis.getAttributeMetaData(entity, attribute)
```

Gets attribute metadata as list.

Parameter|Description|Required
---------|-----------|--------
entity| The entity name|yes
attribute| The name of the attribute|Yes

**Example**

```
attr <- molgenis.getAttributeMetaData(entity = "celiacsprue", attribute = "celiac_gender")
attr$fieldType
```