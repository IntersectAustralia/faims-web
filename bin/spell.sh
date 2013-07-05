#!/bin/bash

[ -z "$(echo $@ | hunspell -l)" ]

if [ "$?" == "1" ]
then 
	echo "Field value is not correct spelling"
	exit 1
else
	exit 0
fi

