source ./get_nidap_conda_environments.sh

function get_environment_file_input {
  
  environment_name="$3"
  
  mkdir -p $3
  
  extension=".json"
  prefix_1="environment_file_"
  prefix_2="resolved_environment_file_"
  
  environment_file_name="$prefix_1$environment_name$extension"
  resolved_environment_file_name="$prefix_2$environment_name$extension"
  
  get_nidap_env $1 $2 environmentv2 1> ./$3/$environment_file_name
  get_nidap_env $1 $2 resolvedEnvironment 1> ./$3/$resolved_environment_file_name
  
  cd ./$3
  
  python ../nidap_parse_environments.py $environment_file_name $resolved_environment_file_name $3
  
  cd ..
  set +x
}
