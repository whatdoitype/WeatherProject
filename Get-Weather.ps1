param(
    [Parameter(Mandatory = $true)]
    [string]
    $City,
    
    [Parameter(Mandatory = $true)]
    [string]
    $State,

    [Parameter()]
    [ValidateSet("Farenheit","Kelvin","Celsius")]
    [string]
    $Units = "Farenheit"
)

# Enter API key for OpenWeatherMap
# https://openweathermap.org/
$APIKey = "98abd06c92bf652c48d3c50f9582113b"

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
    
    if ($null -eq $output.name){
        Write-Error "$City, $State is not a valid location. Please try again."
        break;
    }

    return $output
}

$tempUnit = switch ($Units){
    "Farenheit" {"imperial"}
    "Celsius" {"metric"}
    "Kelvin" {"standard"}
    default {"imperial"}
}

$location = Get-WeatherLocation -City $city -State $State -APIKey $APIKey
$weather = Get-WeatherFromLatLon -Latitude $location.lat -Longitude $location.lon -APIKey $APIKey -Units $tempUnit

$temperature = [Math]::round($weather.main.temp)
$mintemp = [Math]::round($weather.main.temp_min)
$maxtemp = [Math]::round($weather.main.temp_max)    

Write-Host "The weather in $($location.Name), $($location.State) today features: $($weather.weather.description)."
Write-Host "The minimum temperature for today is $mintemp degrees $Units."
Write-Host "The max temperature for today is $maxtemp degrees $Units."
Write-Host "The current temperature is $temperature degrees $Units."