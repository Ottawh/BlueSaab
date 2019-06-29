#!/bin/bash

SERIALPORT=$1
BINFILE=$2
PROJPATH="$(pwd)"
SERIALWC="/dev/tty.*"
BINWC="${PROJPATH}/*.bin"

echo "${BINWC}"

if [ ! $1 ]; then
	if ls -U ${SERIALWC} > /dev/null 2>&1; then
		echo "Serial port not specified."
		SPS=$(printf "%.0s\n" ${SERIALWC} | wc -l | tr -d '\040')
		if [ "$SPS" == "0" ]; then
			echo "No serial ports found. Please check your BlueSaab is connected."
			exit 1
		elif [ "$SPS" == "1" ]; then
			SP=(${SERIALWC})
			SERIALPORT="${SP[0]}"
			echo "One port found. Trying..."
		else
			echo "Please enter the number of the device matching your BlueSaab."
			select SERIALPORT in ${SERIALWC}
			do
				echo "($REPLY) $SERIALPORT selected."
				break
			done
			if [ ! ${SERIALPORT} ]; then
				echo "No serial port specified"
				exit 2
			fi
		fi
	else
		echo "No serial ports found. Please check your BlueSaab is connected."
		exit 3
	fi
fi

if [ ! -f "$PROJPATH/stm32flash" ]; then
	echo "Can't locate 'stm32flash' at $PROJPATH/"
	exit 4
fi

if [ ! $2 ]; then
	if ls -U ${BINWC} > /dev/null 2>&1; then
		echo "Binary file not specified."
		BFS=$(printf "%.0s\n" ${BINWC} | wc -l | tr -d '\040')
		if [ "$BFS" == "0" ]; then
			echo "No project .bin files found. Please check your folder contains a .bin file."
			exit 6
		elif [ "$BFS" == "1" ]; then
			BF=(${BINWC})
			BINFILE="${BF[0]}"
			echo "One .bin file found. Uploading..."
		else
			echo "Please enter the number of the .bin file to upload to your BlueSaab."
			select BINFILE in ${BINWC}
			do
				echo "($REPLY) $BINFILE selected."
				break
			done
			if [ ! ${BINFILE} ]; then
				echo "No bin file specified"
				exit 7
			fi
		fi
	else
		echo "Can't locate the project .bin file"
		exit 8
	fi
fi

${PROJPATH}/./stm32flash -R -v -w ${BINFILE} ${SERIALPORT}