#################################################
# Filename: preprocess.R
# Purpose : preprocess climate raw data
# Student : Liu, Chih-Tse
# Date    : 2025/07/10
#################################################

source(file.path(this.path::this.dir(), "../../common_script/utils.R"))

#filename <- sprintf("2023%02d99.auto_hr.txt", 1:12)
years <- sprintf("2023%02d", 1:12)

# data for each month
alldat <- vector("list", length=12); names(alldat) <- years
allst <- c()  # all stations

# preprocess data for each year separately, and combine for each station later
for (y in years) {
    # ------------------------------------------------------------
    # prepeocess data into the correct format
    # ------------------------------------------------------------
    # load data from 'data/raw/', each line is a string object
    #dat <- readLines(rawdatpath(fname), encoding="UTF-8")
    dat <- readLines(rawdatpath(paste0(y, "99.auto_hr.txt")), encoding="UTF-8")
     
    # replace any number of spaces as single space
    dat <- gsub(" +", " ", dat)
    # remove descriptions starting with '*'
    dat <- dat[!grepl("^\\*", dat)]
    # remove '# ' from the header, and removing any leading/trailing spaces
    dat <- trimws(gsub("# ", "", dat))

    #PS01 測站氣壓(hPa)
    #TX01 氣溫(℃)
    #RH01 相對溼度(%)
    #WD01 平均風風速(m/s)
    #WD02 平均風風向(360 degree)
    #PP01 降水量(mm)
    #SS01 日照時數(hour)

    # extract header
    header <- strsplit(dat[1], " ")[[1]]
    
    # process data rows, split lines by space
    data_lines <- dat[-1]
    split_data <- strsplit(data_lines, " ")
    
    # combine into data frame
    df_raw <- as.data.frame(do.call(rbind, split_data), stringsAsFactors = FALSE)
    colnames(df_raw) <- header
    
    # first column: station ID
    df_raw[[1]] <- as.character(df_raw[[1]]) 
    # second column: convert 'yyyymmddhh' to POSIXct (datetime)
    df_raw[[2]] <- as.POSIXct(df_raw[[2]], format = "%Y%m%d%H", tz = "UTC")
    # all remaining columns: numeric data
    for (i in 3:length(header)) { df_raw[[i]] <- as.numeric(df_raw[[i]]) }

    dat <- df_raw


    # ------------------------------------------------------------
    # handle special values
    # 特殊值:
    # -9991:儀器故障待修              --> NA
    # -9996:資料累計於後         
    # -9997:因不明原因或故障而無資料  --> NA
    # -9998:雨跡(Trace)
    # -9999:未觀測而無資料            --> NA
    # ------------------------------------------------------------
    dat[dat == -9991 | dat == -9997 | dat == -9999] <- NA

    # ------------------------------------------------------------
    # export the results to 'data/preprocessed/'
    # ------------------------------------------------------------
    save(dat, file=ppdatpath(paste0(y, "-pp.RData")))
    str(dat)
    alldat[[y]] <- dat
    allst <- unique(c(allst, dat[, 1]))
    echo(y, " finished.")
}
warnings()


# combine data for each station 
talldat <- alldat
yearlydat <- talldat[[years[1]]]
cols <- colnames(yearlydat)

# combine data for the entire year
for (y in years[2:12]) { yearlydat <- rbind(yearlydat, talldat[[y]][, cols]) }

# additional columns for 2023-12
rmdat <- talldat[[years[12]]][, !(colnames(talldat[[years[12]]]) %in% cols)]


# ------------------------------------------------------------
# separate each station
# ------------------------------------------------------------
stdat <- vector("list", length=length(allst)); names(stdat) <- allst
for (st in allst) { 
    stdat[[st]] <- yearlydat[yearlydat[, 1] == st, ] 
    # for each station, sort by date
    stdat[[st]] <- stdat[[st]][order(stdat[[st]][, 2]), ]
    rownames(stdat[[st]]) <- 1:nrow(stdat[[st]])
    print(head(stdat[[st]]))
}


# ------------------------------------------------------------
# save preprocessed data
# ------------------------------------------------------------
save(stdat, file=ppdatpath("stdat_2023.RData"))
save(rmdat, file=ppdatpath("rmdat_2023-12.RData"))
