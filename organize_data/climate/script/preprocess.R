#################################################
# Filename: preprocess.R
# Purpose : preprocess climate raw data
# Student : Liu, Chih-Tse
# Date    : 2025/07/10
#################################################

source(file.path(this.path::this.dir(), "../../common_script/utils.R"))

#filename <- sprintf("2023%02d99.auto_hr.txt", 1:12)
years <- sprintf("2023%02d", 1:12)

generate_hourly_POSIXct <- function(year) {
  # Create start and end datetime
  start_time <- as.POSIXct(paste0(year, "-01-01 00:00:00"), tz = "UTC")
  end_time   <- as.POSIXct(paste0(year + 1, "-01-01 00:00:00"), tz = "UTC") - 3600

  # Generate hourly sequence
  times <- seq(from = start_time, to = end_time, by = "hour")

  return(times)
}

hours2023 <- generate_hourly_POSIXct(2023)

# data for each month
alldat <- vector("list", length=12); names(alldat) <- years
allst <- c()  # all stations

# preprocess data for each month separately, and combine for each station later
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
    # replace 'None' as '-9999' (explicitly for 2023-12)
    dat <- gsub("None", "-9999", dat)

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

    # for 2023-12, each day begins at 00:00
    # subtract each time by 1 hour for 2023-01 ~ 2023-11 to match that of 2023-12
    if (y != "202312") { dat$yyyymmddhh <- dat$yyyymmddhh - 3600 }
    

    # ------------------------------------------------------------
    # handle special values
    # 特殊值:
    # 2023-01 ~ 2023-11
    # -9991:儀器故障待修              --> NA
    # -9996:資料累計於後         
    # -9997:因不明原因或故障而無資料  --> NA
    # -9998:雨跡(Trace)
    # -9999:未觀測而無資料            --> NA
    # 2023-12
    # -999.1:儀器故障待修                                  --> NA
    # -9.6/-999.6:資料累計於後                             --> -9996
    # -9.5/-99.5/-999.5/-999.5/-9999.5:因故障而無資料      --> NA
    # -9.7/-99.7/-999.7/-999.7/-9999.7:因不明原因而無資料  --> NA
    # -9.8:雨跡(Trace)                                     --> -9998
    # None:未觀測而無資料                                  --> NA
    # ------------------------------------------------------------
    #print(dat[!complete.cases(dat), ])
    dat[dat == -9991 | dat == -9997 | dat == -9999] <- NA
    dat[dat == -999.1] <- NA
    dat[dat == -9.5 | dat == -99.5 | dat == -999.5 | dat == -9999.5] <- NA
    dat[dat == -9.7 | dat == -99.7 | dat == -999.7 | dat == -9999.7] <- NA
    dat[dat == -9.6 | dat == -999.6] <- -9996
    dat[dat == -9.8] <- -9998
    # !! the following values are not included in the documents !!!!
    #    -9999.1, -9995.0, -99.6, -99.1
    #values <- c(-9999.1, -9995, -99.6, -99.1)
    #> for (v in values) {
    #+ print(v)
    #+ for (i in 1:ncol(ndat)) {
    #+ coldat <- ndat[, i]
    #+ if (v %in% coldat) print(colnames(ndat)[i])
    #+ }}
    #[1] -9999.1
    #[1] "PS01"  PS01 測站氣壓(hPa) 
    #[1] -9995
    #[1] "RH01"  RH01 相對溼度(%)
    #[1] -99.6
    #[1] "TX01"  TX01 氣溫(℃)
    #[1] -99.1
    #[1] "TX01"  TX01 氣溫(℃)
    #[1] "WD01"  WD01 平均風風速(m/s)
    # assign all these values with NA since they are unreasonable
    dat[dat == -99.1 | dat == -9999.1 | dat == -9995 | dat == -99.6] <- NA


    # ------------------------------------------------------------
    # export the results to 'data/preprocessed/'
    # ------------------------------------------------------------
    save(dat, file=ppdatpath(paste0(y, "-pp.RData")))
    #str(dat)
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
# * make sure each station contains data for each hour in 2023 
# ------------------------------------------------------------
stdat <- vector("list", length=length(allst)); names(stdat) <- allst
for (st in allst) { 
    # separate data for each station, fill in every hour, and sort by date
    dat <- yearlydat[yearlydat[, 1] == st, ] 

    new_hours <- hours2023[!(hours2023 %in% dat$yyyymmddhh)]
    print(new_hours)
    new_len <- length(new_hours)
    
    # automatically fill NA for other columns
    new_rows <- as.data.frame( lapply(dat, function(col) NA) )
    new_rows <- new_rows[rep(1, new_len), ]
    new_rows$yyyymmddhh <- new_hours
    
    dat <- rbind(dat, new_rows)

    # for each station, sort by date
    dat <- dat[order(dat[, 2]), ]
    rownames(dat) <- 1:nrow(dat)

    # ------------------------------------------------------------
    # deal with -9996
    # 01: if -9996 is the last value of the station, replace all previous -9996 as NA
    # 02: if -9996 is followed with 0/NA, replace all previous -9996 as 0/NA
    # 03: if the next value is also -9996, skip the current one
    # 04: if none of the above cases match, leave the value as -9996
    # ------------------------------------------------------------
    temp <- c()
    missings <- which(dat$PP01 == -9996)
    if (length(missings) > 0) { 
        for (midx in 1:length(missings)) {
            m <- missings[midx]
            temp <- c(temp, m)
            # 01
            if (m == nrow(dat)) { dat$PP01[temp] <- NA } 
            # 02 (check NA first to avoid errors)
            else if (is.na(dat$PP01[m+1])) { dat$PP01[temp] <- NA } 
            else if (dat$PP01[m+1] == 0) { dat$PP01[temp] <- 0 } 
            # 03
            else if (dat$PP01[m+1] == -9996) { next } 
            # 04
            temp <- c()
        }
    }

    stdat[[st]] <- dat
}


# ------------------------------------------------------------
# save preprocessed data (as .RData / .csv)
# ------------------------------------------------------------
save(stdat, file=ppdatpath("stdat_2023.RData"))
save(rmdat, file=ppdatpath("rmdat_2023-12.RData"))

write.csv(do.call(rbind, stdat), lpdatpath("stdat_2023.csv"))
