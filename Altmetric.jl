"""
This Julia module retrieves Altmetrics data using a article's digital object identifier and formats it as a data frame.

# Functions:
    altmetric - Access Altmetric API v1 and store the results in a data frame.
   
# Author:
    Nick Redfern
    nickredfernres@outlook.com
    http://computationalfilmanalysis.wordpress.com
    https://github.com/DrNickRedfern
    27/05/23
"""

module Altmetric

using DataFrames, DataFramesMeta, HTTP, JSON, Pipe

export explode_vectors, json_normalize, altmetric, unpaywall

"""
   result = explode_vectors(d)

Expand a nested JSON data file where the value in (key, value) is an a vector.
Values are expanded to (key, value) with the name key_i, where i is the index of the item
of an element of the original array.
Similar to pandas.explode.

Use explode_vectors to make sure that any arrays of dictionaries are exposed before they are expanded 
using json_normalize.

# Arguments:
- `d::Dict{String,Any}`: A JSON object retrieved from the Altmetric API

# Example:
```
# Load the module
include("./Altmetric.jl")
using .Altmetric

result = explode_vectors(x)
```
"""

function explode_vectors(d::Dict{String, Any})
    new_dict = Dict{String, Any}()
    for (key, value) in d
        if isa(value, Vector{Any})
            if length(value) > 0
                for i in 1:1:length(value)
                    new_dict[string(key, "_", i)] = value[i]
                end
            end
        else
            new_dict[key] = value
        end
    end
    return new_dict
end

"""
   result = json_normalize(d)

Expand a nested JSON data file where the value in (key, value) is a dictionary.
Values are expanded to (key, value) with the name Key1.Key2, where Key1 is the original name of the
(key, value) pair being expanded and key2 is the respective key from the nested dictionary.
Similar to pandas.json_normalize.

# Arguments:
- `d::Dict{String,Any}`: A JSON object retrieved from the Altmetric API

# Example:
```
# Load the module
include("./Altmetric.jl")
using .Altmetric

result = json_normalize(x)
```
"""

function json_normalize(d::Dict{String, Any})
    new_dict = Dict{String, Any}()
    for (key, value) in d
        if isa(value, Dict)
            flat_value = json_normalize(value)
            for (key2, value2) in flat_value
                new_dict[string(key, ".", key2)] = value2
            end
        else
            new_dict[key] = value
        end
    end
    return new_dict
end

"""
   result = altmetric(doi)

Access Altmetric API v1 and store the results in a data frame.

# Arguments:
- `doi::Vector{String}`: an arrays of strings of the digital object identifiers of research outputs

# Example:
```
# Load the module
include("./Altmetric.jl")
using .Altmetric

# Create a vector of dois to search for
doi = ["10.1163/22134913-bja10046", "10.2190/EM.32.2.g"]

# Get data from the API as a data frame
result = altmetric(doi)
```
"""

function altmetric(doi::Vector{String})
    df_output = DataFrame()
    for i ∈ eachindex(doi)
        url = string("https://api.altmetric.com/v1/doi/", doi[i])
        resp = HTTP.get(url)
        if resp.status != 200
            println("Unsuccessful 😞: ", doi)
        else
            data = String(resp.body) |>
            JSON.parse |>
            explode_vectors |>
            json_normalize
            df = DataFrame(keys = collect(keys(data)), values = collect(values(data)))
            df = @chain df begin
                @transform :id = repeat([i], size(df)[1])
                sort!([:id, :keys])
                unstack(:id, :keys, :values)
                select!(Not(:id))
                select(:doi, Not(:doi))        
            end
            df_output = vcat(df_output, df, cols = :union)
        end
    end
    println("Finished 🏁")
    return df_output
end

"""
   result = unpaywall(doi)

Access Unpaywall API and store the results in a data frame.

# Arguments:
- `doi::Vector{String}`: an arrays of strings of the digital object identifiers of research outputs
- `email::{String}`: Unpaywall requests that users add an email address to the url

# Example:
```
# Load the module
include("./Altmetric.jl")
using .Altmetric

# Create a vector of dois to search for
doi = ["10.1163/22134913-bja10046", "10.2190/EM.32.2.g"]
EMAIL = "demo@email.com"

# Get data from the API as a data frame
result = unpaywall(doi, EMAIL)
```
"""

function unpaywall(doi::Vector{String}, email::String)
    df_output = DataFrame()
    for i ∈ eachindex(doi)
        url = string("https://api.unpaywall.org/v2/", doi[i], "?email=", email)
        resp = HTTP.get(url)
        if resp.status != 200
            println("Unsuccessful 😞: ", doi)
        else
            data = String(resp.body) |>
            JSON.parse |>
            explode_vectors |>
            json_normalize
            df = DataFrame(keys = collect(keys(data)), values = collect(values(data)))
            df = @chain df begin
                @transform :id = repeat([i], size(df)[1])
                sort!([:id, :keys])
                unstack(:id, :keys, :values)
                select!(Not(:id))
                select(:doi, Not(:doi))
            end
            df_output = vcat(df_output, df, cols = :union)
        end
    end
    for col in eachcol(df_output)
        replace!(col, nothing => "NA")
        replace!(col, missing => "NA")
    end
    println("Finished 🏁")
    return df_output
end

end