#!/bin/bash

# ./Get-Weather.sh $city $state $units
# $units can be: "imperial", "metric" or "standard"
# will default to imperial if no unit is provided
# Example:
# ./Get-Weather.sh Houston Texas "metric"

city=$1
state=$2
units=$3

# Enter API key for OpenWeatherMap
# https://openweathermap.org/
APIKey=""

function get_weather_from_lat_lon () {
    local baseURL="https://api.openweathermap.org/data/2.5/weather"
    local lat=$1
    local lon=$2
    local units=$3
    local APIKey=$4

    local request="$baseURL?lat=$lat&lon=$lon&units=$units&appid=$APIKey"

    local output=$(curl $request --silent)

    echo $output
}

function get_weather_location() {
    local baseURL="http://api.openweathermap.org/geo/1.0/direct"
    local city=$1
    local state=$2
    local APIKey=$3

    if [[ "$city" == *" "* ]]; then
        city=$(echo "$city" | sed 's/ /+/g')
    fi

    local request="$baseURL?q=$city,$state&appid=$APIKey"

    local output=$(curl $request --silent)

    echo $output
}

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
    *)
        tempUnit="F"
        units="imperial"
esac

location=$(get_weather_location "$city" "$state" $APIKey)

lat=$(echo $location | grep -o '"lat":[^,]*' | sed 's/"lat"://')
lon=$(echo $location | grep -o '"lon":[^,]*' | sed 's/"lon"://')
city=$(echo $location | grep -o 'name":[^,]*' | sed 's/name":"//; s/"//')
state=$(echo $location | grep -o 'state":[^}]*' | sed 's/state":"//; s/"//')

weather=$(get_weather_from_lat_lon $lat $lon $units $APIKey)

description=$(echo $weather | grep -o 'description":[^,]*' | sed 's/description"://; s/"//g')
maxtemp=$(echo $weather | grep -o 'temp_max":[^,]*' | sed 's/temp_max"://; s/"//g; s/\..*//')
mintemp=$(echo $weather | grep -o 'temp_min":[^,]*' | sed 's/temp_min"://; s/"//g; s/\..*//')

echo "The weather in $city, $state today features: $description."
echo "The maximum temperature is $maxtemp degrees $tempUnit."
echo "The minimum temperature is $mintemp degrees $tempUnit."