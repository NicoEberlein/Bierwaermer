#!/bin/bash

FAN=false

BOTTOM_TRESH=$1
TOP_TRESH=$2
INTERVAL=$3

FAN_PIN=28
FUR_PIN=25
LED_PIN=29

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


if [ "$#" -ne "3" ]
then
	echo "Usage: $0 <BOTTOM_TRESH> <TOP_TRESH> <INTERVAL>"
	exit 1
else
	echo "Starting $0 with following parameters:"
	echo -e "    TOP_TRESHOLD:                $TOP_TRESH     °C      "
	echo -e "    BOTTOM_TRESHOLD:             $BOTTOM_TRESH  °C      "
	echo -e "    Interval temp measurement:   $INTERVAL       seconds"


	gpio mode $FAN_PIN out
	gpio mode $FUR_PIN out
	gpio mode $LED_PIN out

	#default values
	gpio write $FAN_PIN 1
	gpio write $FUR_PIN 1
	gpio write $LED_PIN 0


fi


while true
do
	BIGTEMP="$(cat /sys/bus/w1/devices/28-04166375daff/w1_slave | tail -n 1 | grep -o -E '[^=]*$')"
	div=1000
	TEMP=$(( $BIGTEMP / $div ))

	DATE="$(date +%d/%m/%Y-%H:%M)"
	echo "$DATE - $TEMP °C"
	echo "$DATE;$TEMP" >> /home/pi/templog_auto

	if [ "$TEMP" -lt "$BOTTOM_TRESH" ]
	then
		activate_fan 
	elif [ "$TEMP" -gt "$TOP_TRESH" ]
	then
		deactivate_fan
	fi

	sleep $INTERVAL
done


