stty -F /dev/ttyUSB0 9600
ESP_COM_DEV="/dev/ttyUSB0"
echo 'dofile("'${1}'")' > ${ESP_COM_DEV}
cat ${ESP_COM_DEV}
