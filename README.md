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

The result is a data frame sorted with one row per DOI.

| doi                       | added_on   | altmetric_id | authors_1    | cited_by_accounts_count | cited_by_posts_count | cited_by_tweeters_count | cohorts.pub | cohorts.sci |
|---------------------------|------------|--------------|--------------|-------------------------|----------------------|-------------------------|-------------|-------------|
| 10.1163/22134913-bja10046 | 1675345251 | 142074585    | Nick Redfern | 4                       | 4                    | 4                       | 3           | 1           |
| 10.2190/em.32.2.g         | 1539699447 | 49769950     | Nick Redfern | 1                       | 1                    |                         |

The number of columns will vary according to the Altmetric data available for an article and so Altmetric.jl will add empty cells when under a column when an article has missing values.
