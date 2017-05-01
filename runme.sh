if [ -f stop.txt ]
then
	rm stop.txt
fi


while [ true ]
do
	./Cuberite << EOF
fuzzing
stop
EOF

	# If file stop.txt has been created, fuzzing is done
	if [ -f stop.txt ]
	then
		break
	fi

	# If file current.txt exists, an crash occurred
	if [ -f "Plugins/APIFuzzing/current.txt" ]
	then
		mv "Plugins/APIFuzzing/current.txt" "Plugins/APIFuzzing/crashed.txt"
	else
		# Cuberite has been stopped and the command fuzzing was not run
		break
	fi
done

echo "Fuzzing stopped!"
