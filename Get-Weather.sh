#!/bin/bash

# ./Get-Weather.sh $city $state $units
# $units can be: "imperial", "metric" or "standard"
# will default to imperial if no unit is provided
# Example:
# ./Get-Weather.sh Houston Texas "metric"

# Requires environment variable APIKey be defined for OpenWeatherMap
# https://openweathermap.org/

if [[ ! $1 ]]
then
    echo "Error: city parameter not specified"
    exit 1
fi

if [[ ! $2 ]]
then
    echo "Error: state parameter not specified"
    exit 1
fi

if [[ ! $APIKey ]]
then
    echo "Error: APIKey variable not defined"
    exit 1
fi

if [[ ! $3 ]]
then
    echo -e "Unit not specified, defaulting to imperial/Farenheit\n"
    units="imperial"
elif [[ ! $3 = "metric" && ! $3 = "imperial" && ! $3 = "standard" ]]
then
    echo -e "Unit parameter invalid, defaulting to imperial/Farenheit\n"
    units="imperial"
else
    units=$3
fi

city=$1
state=$2

case $units in
    imperial)
        tempUnit="F"
        ;;
    metric)
        tempUnit="C"
        ;;
    standard)
        tempUnit="K"
        ;;
esac

function get_weather_location() {
    local baseURL="http://api.openweathermap.org/geo/1.0/direct"

    if [[ "$city" == *" "* ]]
    then
        city=$(echo "$city" | sed 's/ /+/g')
    fi

    local request="$baseURL?q=$city,$state&appid=$APIKey"

    local output=$(curl $request --silent)

    lat=$(echo $output | grep -o '"lat":[^,]*' | sed 's/"lat"://')
    lon=$(echo $output | grep -o '"lon":[^,]*' | sed 's/"lon"://')
    cityName=$(echo $output | grep -o 'name":[^,]*' | sed 's/name":"//; s/"//')
    stateName=$(echo $output | grep -o 'state":[^}]*' | sed 's/state":"//; s/"//')

    if [[ ! $lat || ! $lon || ! $cityName || ! $stateName ]]
    then
        echo "Error: unable to find location, invalid parameters entered. Please try again."
        exit 1
    fi
}

get_weather_location

function get_weather_from_lat_lon () {
    local baseURL="https://api.openweathermap.org/data/2.5/weather"

    local request="$baseURL?lat=$lat&lon=$lon&units=$units&appid=$APIKey"

    local output=$(curl $request --silent)

    description=$(echo $output | grep -o 'description":[^,]*' | sed 's/description"://; s/"//g')
    maxtemp=$(echo $output | grep -o 'temp_max":[^,]*' | sed 's/temp_max"://; s/"//g; s/\..*//')
    mintemp=$(echo $output | grep -o 'temp_min":[^,]*' | sed 's/temp_min"://; s/"//g; s/\..*//')
}

get_weather_from_lat_lon

echo "The weather in $cityName, $stateName today features: $description."
echo "The maximum temperature is $maxtemp degrees $tempUnit."
echo "The minimum temperature is $mintemp degrees $tempUnit."