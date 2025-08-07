source ./get_nidap_conda_environments.sh

function get_docker_input {
  
  NIDAP_JSON=$(get_nidap_env $@ environmentv2)
  
  echo "" > conda_pkg.txt
  
  for line in $NIDAP_JSON
  do
    if [[ $line == *"=="* ]];
    then
    
      line_s_1=${line//[==]/ }
      line_s_2=${line_s_1//['"']/}
      line_s_3=${line_s_2//[,]/}
      echo "$line_s_3" >> conda_pkg2.txt
      
    fi
  done
  
  sed -i '/^$/d' conda_pkg2.txt
  sed -i 's/ \{1,\}/ /g' conda_pkg2.txt
}
