stty -F /dev/ttyUSB0 9600
ESP_COM_DEV="/dev/ttyUSB0"

echo 'file.remove("'${1}'");' > $ESP_COM_DEV
echo 'file.open("'${1}'","w+");' > $ESP_COM_DEV
echo "w = file.writeline" > $ESP_COM_DEV
while read line; do           
#while [ -z "$eof" ]; do
    echo 'w([['${line}']]);' > $ESP_COM_DEV
done <${1}

echo 'file.close();' > $ESP_COM_DEV
