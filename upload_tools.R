library(RCurl)
library(httr)

create_folder<-function(path,pathname,key){

  callurl<-paste0("https://nidap.nih.gov/compass/api/paths/",path,"/",pathname)

  rma<-PUT(url=callurl,add_headers(Authorization = paste("Bearer", key, sep = " ")))
  con<-content(rma,"parsed")
  cont<-content(rma,"text")
  cont
  return(con$rid)
}


#rid="ri.foundry.main.dataset.0950a6c3-fcae-45cd-b3f0-2386adb919a5"
upload_project<-function(upload_file_name,datasetname,email,key){


  #pushnidap<-function(key,rid){
  #curl -X POST -H "Authorization: Bearer $FOUNDRYTOKEN" https://nidap.nih.gov/foundry-data-proxy/api/dataproxy/datasets/$DATASET_RID/transactions/$TRANSACTION_RID/putFile?logicalPath=$path --data-binary "@{}";' \;

  url="https://nidap.nih.gov/"
  dataproxy="foundry-data-proxy/api/dataproxy/datasets/"
  catalog="foundry-catalog/api/catalog/datasets/"


  #Create Folder PATH




  ################3
  #Create Dataset
  callurlcreate<-paste0(url ,"foundry-catalog/api/catalog/datasets")
  # print(callurl)
  rmc<-POST(url=callurlcreate,add_headers(Authorization = paste("Bearer", key, sep = " ")), verify=FALSE,
            content_type_json(),body = list(path=paste0(email,"/",datasetname)),encode = "json")
  rmcc<-content(rmc,"parsed")
  #jsonlite::prettify(content(rmc,"text"))


  ##############
  #Create Branch
  callurlcreatebranch<-paste0(url ,"foundry-catalog/api/catalog/datasets/",rmcc$rid,"/branchesUnrestricted2/master")
  # print(callurl)
  rmcb<-POST(url=callurlcreatebranch,add_headers(Authorization = paste("Bearer", key, sep = " ")), verify=FALSE,
             content_type_json(),body = '{}', encode = "raw")
  rmccb<-content(rmcb,"parsed")
  #jsonlite::prettify(content(rmcb,"text"))





  #############
  #Create Transaction

  callurl<-paste0(url ,catalog , rmcc$rid , '/transactions')
  # print(callurl)
  rm<-POST(url=callurl,add_headers(Authorization = paste("Bearer", key, sep = " ")), verify=FALSE,
           content_type_json(),body = list(branchId="master"),encode = "json")


  con<-content(rm,"parsed")
  cont<-content(rm,"text")
  #jsonlite::prettify(content(rm,"text"))

  #############
  #Upload File

  trid<-con$rid
  print( trid)
  brid<-con$datasetRid


  file_url = paste0(url,dataproxy,brid,"/transactions/",trid,"/putFile?logicalPath=",upload_file_name)


  resp2=POST(url = file_url,add_headers(Authorization = paste("Bearer", key, sep = " ")),body = upload_file(upload_file_name))

  print(resp2)
  #jsonlite::prettify(content(resp2,"text"))
  #############
  #commit transaction

  callurlabort<-paste0(url ,catalog , brid , '/transactions/',trid,'/commit')
  # print(callurl)
  rma<-POST(url=callurlabort,add_headers(Authorization = paste("Bearer", key, sep = " ")), verify=FALSE,
            content_type_json(),body = '{}',encode = "raw")
  #"record": {}
  #body = '{}', encode = "raw")

  rma
  #jsonlite::prettify(content(rma,"text"))
  return(brid)
}


getDestinations<-function(key){
  #############
  #Create Transaction
  callurl<-"https://nidap.nih.gov/phonograph2/api/search/tables"
  requestbody<-'{
        "tableRids": [
            "ri.phonograph2.main.table.f2b7fa90-558e-4cbf-9636-8c0d28da820a"
        ],
        "filter": {
            "type": "matchAll",
            "matchAll": {}
        },
        "aggregations": {}
    }'
  # print(callurl)
  rm<-POST(url=callurl,add_headers(Authorization = paste("Bearer", key, sep = " ")), verify=FALSE,
           content_type_json(),body = requestbody,encode = "json")


  con<-content(rm,"parsed")
  cont<-content(rm,"text")

  return(fromJSON(cont)$hits[, 3][,2])
}

getRidFromPath<-function(key,path){
  callurl<-"https://nidap.nih.gov/compass/api/resources?path=/Users/robin.kramer@nih.gov/Atest/al6"

  rma<-GET(url=callurl,add_headers(Authorization = paste("Bearer", key, sep = " ")))
  con<-content(rma,"parsed")
  cont<-content(rma,"text")
  cont
  return(con$rid)
}

#counts_rid="ri.foundry.main.dataset.13674385-c194-4fb0-9496-cb123b669d3e"
#metadata_rid="ri.foundry.main.dataset.c9554360-8c56-45e7-98bf-f22de80067c4"
#todo: get rid from path
#path_rid="ri.compass.main.folder.852043ba-4f9d-41b2-9103-ee00bc454364"
#wname="A4"
#createWorkBook(key,counts_rid,metadata_rid,path_rid,wname)
createWorkBook<-function(key,counts_rid,metadata_rid,frid,wname){

  #create workbook
  #curl -XPOST -k  -H "Accept: application/json" -H "Content-Type: application/json"  -H "Authorization: Bearer ${token}" "https://nidap.nih.gov/vector/api/workbooks/" -o created.json -d @create_workbook.json

  path_rid<-frid   #getRidFromPath(path,key)


  callurl="https://nidap.nih.gov/vector/api/workbooks/"
  requestbody=paste0('{
    "parentFolderRid": "',path_rid,'",
    "name": "',wname,'"
  }')
  rma<-POST(url=callurl,add_headers(Authorization = paste("Bearer", key, sep = " ")), verify=FALSE,
            content_type_json(),body = requestbody,encode = "json")


  con<-content(rma,"parsed")
  cont<-content(rma,"text")

  callurl=paste0( "https://nidap.nih.gov/vector/api/workbooks/",con$workbook$rid,"/branches/master/logicNodes-batchCreate")
  requestbody=paste0('{
        "requests": [
            {
                "displayOptions": {
                    "dimensions": {
                        "height": 200,
                        "width": 300
                    },
                    "position": {
                        "left": -200,
                        "top": 300
                    },
                    "viewMode": "DATA_PREVIEW"
                },
                "inputs": [],
                "outputAlias": "counts_matrix",
                "spec": {
                    "importedDataset": {
                        "datasetRid": "',counts_rid,'"
                    },
                    "type": "importedDataset"
                }
            }
        ]
    }')

  rma2<-POST(url=callurl,add_headers(Authorization = paste("Bearer", key, sep = " ")), verify=FALSE,
             content_type_json(),body = requestbody,encode = "json")


  con2<-content(rma2,"parsed")
  cont2<-content(rma2,"text")
  requestbody=paste0('{
        "requests": [
  {
    "displayOptions": {
      "dimensions": {
        "height": 200,
        "width": 300
      },
      "position": {
        "left": 200,
        "top": 300
      },
      "viewMode": "DATA_PREVIEW"
    },
    "inputs": [],
    "outputAlias": "sample_metadata",
    "spec": {
      "importedDataset": {
        "datasetRid": "',metadata_rid,'"
      },
      "type": "importedDataset"
    }
  }
        ]
    }')

  rma3<-POST(url=callurl,add_headers(Authorization = paste("Bearer", key, sep = " ")), verify=FALSE,
             content_type_json(),body = requestbody,encode = "json")


  con3<-content(rma3,"parsed")
  cont3<-content(rma3,"text")

  return(con$workbook$rid)
}


