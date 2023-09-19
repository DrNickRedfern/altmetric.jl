# altmetric.jl
This Julia module retrieves publication data using a article's digital object identifier from a vareity of open APIs and formats it as a data frame.

## Example

Load the module:

```
include("./Altmetric.jl")
using .Altmetric
```

Create a vector of dois to search for:

`doi = ["10.1163/22134913-bja10046", "10.2190/EM.32.2.g"]`

### Altmetrics

Get data from the Altmetric v1 API as a data frame:

`result = altmetric(doi)`

The result is a data frame sorted with one row per DOI.

| doi                       | added_on   | altmetric_id | authors_1    | cited_by_accounts_count | cited_by_posts_count | cited_by_tweeters_count | cohorts.pub | cohorts.sci |
|---------------------------|------------|--------------|--------------|-------------------------|----------------------|-------------------------|-------------|-------------|
| 10.1163/22134913-bja10046 | 1675345251 | 142074585    | Nick Redfern | 4                       | 4                    | 4                       | 3           | 1           |
| 10.2190/em.32.2.g         | 1539699447 | 49769950     | Nick Redfern | 1                       | 1                    |                         |

The number of columns will vary according to the Altmetric data available for an article and so Altmetric.jl will add empty cells when under a column when an article has missing values.

### Unpaywall

Get data from the Unpaywall v2 API as a data frame:

**Unpaywall asks that users be polite and include an email address in their requests. The function wonlt work unless youn include an email address.**

`result = unpaywall(doi, "email@address.com")`

The result is a data frame sorted with one row per DOI.

| doi                       | best_oa_location.endpoint_id | best_oa_location.evidence | best_oa_location.host_type | best_oa_location.is_best | best_oa_location.license |
|---------------------------|------------------------------|---------------------------|----------------------------|--------------------------|--------------------------|
| 10.1163/22134913-bja10046 | NA                           | open (via free pdf)       | publisher                  | true                     | NA                       |
| 10.2190/em.32.2.g         | NA                           | NA                        | NA                         | NA                       | NA                       |

`missing` and `nothing` values will be replaced with the string `NA`.

## Coming soon

I'll add some more bibliometric endpoints (e.g., Crossref events) as I come across them.
