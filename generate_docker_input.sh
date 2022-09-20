source ./get_nidap_conda_environments.sh

function get_docker_input {
  
  NIDAP_JSON=$(get_nidap_env $@ environmentv2)
  
  #get_nidap_env $@ environmentv2 1>NIDAP_output.json
  
  echo "" > docker_package_list.txt
  
  for line in $NIDAP_JSON
  do
    if [[ $line == *"=="* ]];
    then
      line_s_1=${line//[==]/ }
      #$(sed -r 's/[==]+/ /g' "$line")
      line_s_2=${line_s_1//['"']/}
      line_s_3=${line_s_2//[,]/}
      echo "$line_s_3" >> docker_package_list.txt
    fi
  done
  
  sed -i '/^$/d' docker_package_list.txt
  sed -i 's/ \{1,\}/ /g' docker_package_list.txt
}
