library(RJSONIO)
library(RCurl)

load_OHLC <- function(name, site, pair) {
  workDir = sprintf("~%s/bc",name)
  setwd(workDir)
  backup_file_name=sprintf("%s.%s.csv",pair,format(Sys.time(),"%Y%m%d_%H%M"))
  file_name=sprintf("%s.csv", pair)
  file.rename(file_name, backup_file_name)
  
  lastId_1 <- read.table("lastId.ini", head = FALSE)
  lastId = lastId_1[[1]]

  old_data = read.csv(backup_file_name, header = TRUE)
  ohlc_old <- data.matrix(old_data, rownames.force = NA)
  
  tmp = sprintf("Read\t%d\trecords from %s till %s\n", nrow(ohlc_old), as.POSIXct(as.numeric(as.character(ohlc_old[1,1])), origin='1970-01-01', tz='GMT'), as.POSIXct(as.numeric(as.character(ohlc_old[nrow(ohlc_old),1])), origin='1970-01-01', tz='GMT'))
  cat(tmp)

  szRequest = sprintf("https://%s?pair=%s&since=%d",site, pair, lastId)
  raw_data <- getURL(szRequest)  
  data <- fromJSON(raw_data)
  ohlc=do.call(rbind,data[[2]][[1]])
  tmp = sprintf("Loaded\t%d\trecords from %s till %s\n", nrow(ohlc), as.POSIXct(as.numeric(as.character(ohlc[1,1])), origin='1970-01-01', tz='GMT'), as.POSIXct(as.numeric(as.character(ohlc[nrow(ohlc),1])), origin='1970-01-01', tz='GMT'))
  cat(tmp)
  
  ohlc <- rbind(ohlc_old, ohlc)
  
#  plot(ohlc[,1],ohlc[,2],type="l", xaxt='n', col="red") 
#  lines(ohlc[,1],ohlc[,3],col="green")
#  timestamps <-  as.POSIXct(as.numeric(as.character(ohlc[,1])), origin='1970-01-01', tz='GMT')
#  axis.POSIXct(1, timestamps) 
  
  lastId = data[[2]][[2]]
  write.table(lastId, "lastId.ini", quote = FALSE, append = FALSE, col.names = FALSE, row.names = FALSE)

  write.csv(ohlc, file_name, row.names=FALSE)
  tmp = sprintf("Saved\t%d\trecords from %s till %s\n", nrow(ohlc), as.POSIXct(as.numeric(as.character(ohlc[1,1])), origin='1970-01-01', tz='GMT'), as.POSIXct(as.numeric(as.character(ohlc[nrow(ohlc),1])), origin='1970-01-01', tz='GMT'))
  cat(tmp)
}

args <- commandArgs(TRUE)
tmp = sprintf("Arguments: '%s', '%s', '%s'\n", args[1], args[2], args[3])
cat(tmp)
#load_OHLC("realname", "api.kraken.com/0/public/OHLC", "XBTEUR")
load_OHLC(args[1], args[2], args[3])
