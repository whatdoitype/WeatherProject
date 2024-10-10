param(
    [Parameter(Mandatory = $true)]
    [string]
    $City,
    
    [Parameter(Mandatory = $true)]
    [string]
    $State,

    [Parameter(Mandatory = $true)]
    [string]
    $OpenWeatherMapAPIKey,

    [Parameter()]
    [ValidateSet("Farenheit","Kelvin","Celsius")]
    [string]
    $Units = "Farenheit"
)

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

    $output = try {
        Invoke-RestMethod @params
    }
    catch {
        Write-Error $_
        break;
    }
    
    if ($null -eq $output.name){
        Write-Error "$City, $State is not a valid location. Please try again."
        break;
    }

    return $output
}

$location = Get-WeatherLocation -City $city -State $State -APIKey $OpenWeatherMapAPIKey

$tempUnit = switch ($Units){
    "Farenheit" {"imperial"}
    "Celsius" {"metric"}
    "Kelvin" {"standard"}
    default {"imperial"}
}

$weather = Get-WeatherFromLatLon -Latitude $location.lat -Longitude $location.lon -APIKey $OpenWeatherMapAPIKey -Units $tempUnit

$temperature = [Math]::round($weather.main.temp)
$mintemp = [Math]::round($weather.main.temp_min)
$maxtemp = [Math]::round($weather.main.temp_max)

[PSCustomObject]@{
    City = $Location.Name
    State = $Location.State
    Description = $Weather.Weather.Description
    MaximumTemperature = "$maxtemp" + [char]176 + "$($Units[0])"
    MinmumTemperature = "$mintemp" + [char]176 + "$($Units[0])"
    CurrentTemperature = "$temperature" + [char]176 + "$($Units[0])"
}