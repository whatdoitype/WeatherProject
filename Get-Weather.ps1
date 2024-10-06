# Enter API key for OpenWeatherMap
# https://openweathermap.org/
$APIKey = "98abd06c92bf652c48d3c50f9582113b"

function Get-Weather{
    param(
        [Parameter()]
        [string]
        $City,
        
        [Parameter()]
        [string]
        $State,

        [Parameter()]
        [ValidateSet("imperial","standard","metric")]
        [string]
        $Units = "imperial"
    )
    $location = Get-WeatherLocation -City $city -State $State -APIKey $script:APIKey
    $weather = Get-WeatherFromLatLon -Latitude $location.lat -Longitude $location.lon -APIKey $script:APIKey -Units $Units
    $temperature = [Math]::round($weather.main.temp)
    $mintemp = [Math]::round($weather.main.temp_min)
    $maxtemp = [Math]::round($weather.main.temp_max)

    $tempUnit = switch ($Units){
        "imperial" {"Farenheit"}
        "metric" {"Celsius"}
        "standard" {"Kelvin"}
        default {"Farenheit"}
    }

    Write-Host "The weather in $City, $State today features $($weather.weather.description)."
    Write-Host "The min temperature is $mintemp degrees $tempUnit."
    Write-Host "The max temperature is $maxtemp degrees $tempUnit."
    Write-Host "The current temperature is $temperature degrees $tempUnit."
}

function Get-WeatherFromLatLon{
    param(
        [Parameter()]
        [string]
        $Latitude,
        
        [Parameter()]
        [string]
        $Longitude,

        [Parameter()]
        [string]
        $Units = "imperial",

        [Parameter()]
        [string]
        $APIKey
    )

    $baseURL = "https://api.openweathermap.org/data/2.5/weather"

    $Body = @{
        appid = $APIKey
        lat = $Latitude
        lon = $Longitude
        units = $Units
    }

    $params = @{
        Uri = $baseURL
        Method = "GET"
        Body = $Body
    }

    $output = Invoke-RestMethod @params
    return $output

}

function Get-WeatherLocation{
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

Get-Weather -City "Tallahassee" -State "Florida" -Units "Imperial"