#!/bin/bash

FAN=false

BOTTOM_TRESH=$1
TOP_TRESH=$2

FAN_PIN=28
FUR_PIN=25
LED_PIN=29

gpio mode $FAN_PIN out
gpio mode $FUR_PIN out
gpio mode $LED_PIN out

#default values
gpio write $FAN_PIN 1
gpio write $FUR_PIN 1
gpio write $LED_PIN 0


activate_fan() {

	if [ "$FAN" = "false" ]
	then
		DATE="$(date +%d/%m/%Y-%H:%M)"
		echo "$DATE - Aktiviere FAN wegen zu niedriger Temperaturen"

		#activate fan & fur
		gpio write $FAN_PIN 0
		gpio write $FUR_PIN 0
		
		#activate led
		gpio write $LED_PIN 1

		FAN=true
	fi	
}

deactivate_fan() {

	if [ "$FAN" = "true" ]
	then
		DATE="$(date +%d/%m/%Y-%H:%M)"
		echo "$DATE - Deaktiviere FAN"

		#Deaktiviere Furnace
		gpio write $FUR_PIN 1

		sleep 30
		
		#deactivate fan
		gpio write $FAN_PIN 1
		
		#deactivate led
		gpio write $LED_PIN 0

		FAN=false
	fi

}


if [ "$#" -ne "2" ]
then
	echo "Usage: ./$0 <BOTTOM_TRESH> <TOP_TRESH>"
	exit 1
else
	echo "Starting $0 with following parameters:"
	echo -e "    TOP_TRESHOLD:\t$TOP_TRESH °C"
	echo -e "    BOTTOM_TRESHHOLD:\t$BOTTOM_TRESH °C"
fi


while [ "1" -eq "1" ]
do
	BIGTEMP="$(cat /sys/bus/w1/devices/28-04166375daff/w1_slave | tail -n 1 | grep -o -E '[^=]*$')"
	div=1000
	TEMP=$(( $BIGTEMP / $div ))

	DATE="$(date +%d/%m/%Y-%H:%M)"
	echo "$DATE - $TEMP °C"

	if [ "$TEMP" -lt "$BOTTOM_TRESH" ]
	then
		activate_fan 
	elif [ "$TEMP" -gt "$TOP_TRESH" ]
	then
		deactivate_fan
	fi

	sleep 60
done


