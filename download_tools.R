library(RCurl)
library(httr)
library(arrow)
library(dplyr)
#pullnidap_raw(key = key,rid='ri.foundry.main.dataset.4b851b8f-1baa-4d06-a7c5-1ce125db2272')
report_differences<-function(target,new){
  if(class(target)!="data.frame"){
    return("Not a dataframe, skipping")
  }else{

    rownames(new)<-NULL
    rownames(target)<-NULL
    names(new) <- gsub("\\.", "_", names(new))
    colnames(new)<-gsub("-",".",colnames(new))
    a<-dplyr::all_equal(target%>%mutate_if(is.numeric, round, 7)%>% mutate_if(is.factor, as.character),
                        new%>%mutate_if(is.numeric, round, 7)%>% mutate_if(is.factor, as.character),
                     ignore_col_order=TRUE,
                     ignore_row_order=TRUE)
    return(a)
  }
}

figure_out_nidap_files<-function(transfers){
  fin1<-transfers
  if(sum(grepl(".parquet$",fin1))){
    print("Nidap datset")
    fin0<-fin1[grepl(".parquet$",fin1)]
    infos = file.info(fin0)
    #print(info)
    df_total<-data.frame()
    for(infoi in rownames(infos)){
      info<-infos[infoi,]
    if(info$size>0 ){
      df1<-read_parquet(infoi)
      df <- data.frame(df1)
      df_total <- rbind(df_total,df)
    }
      #print(df)
    }
    return(df_total)
  }else if(length(fin1)==1 && sum(grepl(".csv$",fin1))){
  # return(read.csv(fin1,stringsAsFactors=FALSE))
   return(read.csv(fin1,stringsAsFactors=FALSE, header = TRUE, check.names = FALSE))
  }else if(sum(grepl("abc$",fin1))){
    return(read.csv(fin1,stringsAsFactors=FALSE, header = TRUE, check.names = FALSE))
  }else if(sum(grepl(".rds$",fin1))){
    print("R rds object, todo readRds")
  }else{
    #raw files
  # browser()
    fraw<-data.frame(fin1,stringsAsFactors = FALSE)
    colnames(fraw)<-"value"
    return (fraw)


  }




}

pullnidap_raw<-function(key,rid,branch){
  dirdown<-"nidap_downloads"
  dir.create(dirdown,showWarnings = FALSE)

  url="https://nidap.nih.gov/"
  dataproxy="foundry-data-proxy/api/dataproxy/datasets/"
  catalog="foundry-catalog/api/catalog/datasets/"

  callurl<-paste0(url ,catalog , rid , '/views2/',branch,'/files?pageSize=100')
  # print(callurl)
  rm<-GET(url=callurl,add_headers(Authorization = paste("Bearer", key, sep = " ")), verify=FALSE,content_type_json())


  con<-content(rm,"parsed")
  cont<-content(rm,"text")
#  jsonlite::prettify(content(rm,"text"))
  files=c()

    filenum=0
    #print(con)
    for(a in con$values){
   #   print(a)
      filenum=filenum+1
      file_url = paste0(url,dataproxy,rid,"/transactions/",a$transactionRid,"/",a$logicalPath)
      #print(a$logicalPath)
      paths<-strsplit(a$logicalPath,"/")[[1]]

      ffd=paths[length(paths)]
      #print(file_url)
      #print(a$logicalPath)
      filename<-paste0(dirdown,"/",ffd)

      rm3<-GET(url=file_url,add_headers(Authorization = paste("Bearer", key, sep = " ")), verify=FALSE,write_disk(filename, overwrite=TRUE))
      info = file.info(filename)
      print(filename)
      files=c(files,filename)
    }

  #}

  return(files)
}


pullnidap_dataset<-function(key,rid,branch){

  url="https://nidap.nih.gov/"
  dataproxy="foundry-data-proxy/api/dataproxy/datasets/"
  catalog="foundry-catalog/api/catalog/datasets/"

  callurl<-paste0(url ,catalog , rid , '/reverse-transactions2/',branch,'?pageSize=100')
  # print(callurl)
  rm<-GET(url=callurl,add_headers(Authorization = paste("Bearer", key, sep = " ")), verify=FALSE,content_type_json())


  con<-content(rm,"parsed")
  cont<-content(rm,"text")
  jsonlite::prettify(content(rm,"text"))
  ts=""
  #find last committed transaction

  for(iv in 1:length(con$values)){
    if(con$values[[iv]]$transaction$status=="COMMITTED")
      if(ts==""){
        ts="COMMITTED"
        v=iv
      }
    if(con$values[[iv]]$transaction$closeTime>con$values[[v]]$transaction$closeTime){
      v<-iv
    }



  }
  if(ts==""){
    print("no committed transaction")

  }
  i<-con$values[[v]]$rid
    #v=1
    i<-con$values[[v]]$rid
    #print( i)
    call = paste0(url , catalog , rid , '/transactions/' , i , '/files/paged2?pageSize=100')
    #print( call)
    rm2<-GET(url=call,add_headers(Authorization = paste("Bearer", key, sep = " ")), verify=FALSE)
    con2<-content(rm2,"parsed")
    #jsonlite::prettify(content(rm2,"text"))
    df_total = data.frame()
    filenum=0
    for(a in con2$values){
      file_url = paste0(url,dataproxy,rid,"/transactions/",i,"/",a$logicalPath)
      #print(a$logicalPath)
      filename=paste0(filenum,"_test.txt")
      #print(file_url)
      #print(a$logicalPath)
      if(grepl(".parquet",a$logical)){
        rm3<-GET(url=file_url,add_headers(Authorization = paste("Bearer", key, sep = " ")), verify=FALSE,write_disk(filename, overwrite=TRUE))
        info = file.info(filename)
        #print(info)
        if(info$size>0 ){
          df1<-read_parquet(filename)
          df <- data.frame(df1)
          df_total <- rbind(df_total,df)
          #print(df)
        }
      }
    }





  return(df_total)


}
