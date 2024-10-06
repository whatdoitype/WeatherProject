$APIKey = "98abd06c92bf652c48d3c50f9582113b"

function Get-Weather{
    param(
        [Parameter()]
        [string]
        $Latitude,
        
        [Parameter()]
        [string]
        $Longitude,

        [Parameter()]
        [string]
        $APIKey
    )

    $baseURL = "https://api.openweathermap.org/data/2.5/weather"

    $Body = @{
        appid = $APIKey
        lat = $Latitude
        lon = $Longitude
    }

    $params = @{
        Uri = $baseURL
        Method = "GET"
        Body = $Body
    }

    $output = Invoke-RestMethod @params
    return $output

}

function Get-Location{
    param(
        [Parameter()]
        [string]
        $City,
        
        [Parameter()]
        [string]
        $State,

        [Parameter()]
        [string]
        $APIKey
    )
    $baseURL = "http://api.openweathermap.org/geo/1.0/direct"

    $Body = @{
        appid = $APIKey
        q = "$City,$State"
    }

    $params = @{
        Uri = $baseURL
        Method = "GET"
        Body = $Body
    }

    $output = Invoke-RestMethod @params
    return $output
}

$location = Get-Location -City Houston -State Texas -APIKey $APIKey

Get-Weather -Latitude $location.lat -Longitude $location.lon -APIKey $APIKey