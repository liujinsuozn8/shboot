
while read -r line; do
  line=$(String_trim $line)
  
  # file_data+=("$line")

  if [ ! -z $line ] && (! String_startsWith "$line" '#');then
    # echo "$line"
    key=${line%%=*}
    echo $key
  fi

done < "./resource/log.properties"

# # for x in ${file_data[@]};do
# # 	echo "$x"
# # done