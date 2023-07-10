source ~/.Renviron
#get environments *Profile highest memory*

curl --request GET 'https://nidap.nih.gov/vector/api/workbooks/ri.vector.main.workbook.055d84fe-8d46-498b-af12-1c7b4105f8df/branches/master/resolvedEnvironment' --header "Authorization: Bearer $token"| python -mjson.tool > NIDAP_env.json


curl --request GET 'https://nidap.nih.gov/vector/api/workbooks/ri.vector.main.workbook.055d84fe-8d46-498b-af12-1c7b4105f8df/availableVectorEnvironmentsV2' --header "Authorization: Bearer $token" | python -mjson.tool> Available_env.json

curl --request GET 'https://nidap.nih.gov/vector/api/workbooks/ri.vector.main.workbook.055d84fe-8d46-498b-af12-1c7b4105f8df/branches/master/environmentv2' --header "Authorization: Bearer $token" | python -mjson.tool> environmentv2_env.json

#get all templates.

curl --request GET 'https://nidap.nih.gov/vector/api/templates' --header "Authorization: Bearer $token" | python -mjson.tool > templates.json

#parse rough list of libraries

cat templates.json| grep -Po '(?<=library\().*?(?=\))'|sed -e 's/\\\"//g'|sed -e 's/package = //g'|sed -e "s/'//g"|cut -d, -f1|sort |uniq > library_names.txt
cat main.R | grep -Po '(?<=library\().*?(?=\))'|sed -e 's/\\\"//g'|sed -e 's/package = //g'|sed -e "s/'//g"|cut -d, -f1|sort |uniq > library_main.txt

curl --request GET 'https://nidap.nih.gov/vector/api/workbooks/ri.vector.main.workbook.055d84fe-8d46-498b-af12-1c7b4105f8df/branches/master/' --header "Authorization: Bearer $token"| python -mjson.tool  > workbook.json

curl --request POST 'https://nidap.nih.gov/vector/api/workbooks/ri.vector.main.workbook.055d84fe-8d46-498b-af12-1c7b4105f8df/branches/master/logicNodes-batchGet' -H "Content-Type: application/json" -d {} --header "Authorization: Bearer $token"| python -mjson.tool  > logic_nodes.json


cat logic_nodes.json  |grep templateR|sort |uniq

cat library_main.txt | awk 'BEGIN{while(( getline line<"library_names.txt") > 0 ) { a[tolower(line)]=line }}{if($0 in a){b=a[$0]}else{b=$0} print "library("b")"}' > main2.R

