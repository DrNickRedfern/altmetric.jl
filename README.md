# altmetric.jl
This Julia module retrieves Altmetrics data using a article's digital object identifier and formats it as a data frame.

## Example:

Load the module:

```
include("./Altmetric.jl")
using .Altmetric
```

Create a vector of dois to search for:

`doi = ["10.1163/22134913-bja10046", "10.2190/EM.32.2.g"]`

Get data from the API as a data frame:

`result = altmetric(doi)`

The result is a data frame sorted with one row per DOI
