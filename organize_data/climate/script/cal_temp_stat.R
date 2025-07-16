#################################################
# Filename: cal_temp_stat.R
# Purpose : calculate statistics from preprocessed data
# Student : Liu, Chih-Tse
# Date    : 2025/07/11
#################################################

source(file.path(this.path::this.dir(), "../../common_script/utils.R"))

load(ppdatpath("stdat_2023.RData"))  # stdat


# average and max/min daily temperature
ammdt <- function (dat, dtidx=1, tempidx=2) { 
    # sort the data by date
    dat <- dat[order(dat[, dtidx]), c(dtidx, tempidx)]
    dt <- dat[, 1]; temp <- dat[, 2]
    #if (sum(is.na(temp)) > 0) stop("Missing value fonud!")
    #str(dat)

    daydt <- as.Date(dt)
    days <- unique(daydt)

    cols <- c("avg", "min", "max")
    res <- matrix(NA, nrow=length(days), ncol=length(cols))
    colnames(res) <- cols; rownames(res) <- days
    for (didx in 1:length(days)) {
        d <- days[didx]
        ddat <- dat[daydt == d, ]
        ddat <- ddat[complete.cases(ddat), ]
        meanres <- ifelse(nrow(ddat) > 0, mean(ddat[, 2]), NA)
        minres <- ifelse(nrow(ddat) > 0, min(ddat[, 2]), NA)
        maxres <- ifelse(nrow(ddat) > 0, max(ddat[, 2]), NA)
        res[didx, ] <- c(meanres, minres, maxres)
    }

    res <- as.data.frame(res)
    res$date <- days
    colnames(res) <- c(cols, "date")

    return(res)
}


# ------------------------------------------------------------
# calculate temperature statistics for each station
# return: a data-frame, rows: station, cols: statistics
# ------------------------------------------------------------
stnos <- names(stdat)
result <- matrix(NA, nrow=length(stdat), ncol=5)  # 5 statistics
for (stidx in 1:length(stdat)) {
    st <- stdat[[stidx]]; stno <- stnos[stidx]
    dat <- st[, c("yyyymmddhh", "TX01")]
    #str(dat)

    # daily data of each station
    stdaydat <- ammdt(dat)

    # 01
    th <- 17
    accutempdiff <- sum(stdaydat$avg[stdaydat$avg > th] - th)  # 01

    # 02
    thmin <- 27; thmax <- 33
    matchdays <- stdaydat$min >= thmin & stdaydat$max <= thmax
    totaldays <- sum(matchdays)  # 02

    # 03, 04
    mdat <- stdaydat[matchdays, ]; mdatdt <- mdat$date
    dtdiff <- mdatdt[-1] - mdatdt[-length(mdatdt)]
    boundary <- which(dtdiff > 1)
    mdays <- boundary - c(0, boundary[-length(boundary)])  
    if (isTRUE(is.na(mdays)) | length(mdays) == 0) maxmdays <- NA
    else maxmdays <- max(mdays)  # 04
    avgmdays <- mean(mdays)  # 03

    # 05 (for 2023, 01/01 is Sunday)
    wth <- 18   
    # separate each week (each week begins at Sunday)
    stdaydat$weekstart <- as.Date(cut(as.Date(stdaydat$date), breaks="week")) - 1

    weekstarts <- unique(stdaydat$weekstart)
    wat <- rep(NA, length(weekstarts))
    # calculate weekly average temperature
    for (wsidx in 1:length(weekstarts)) {
        ws <- weekstarts[wsidx]
        wdat <- stdaydat[stdaydat$weekstart == ws, "avg"]
        wat[wsidx] <- mean(wdat)
    }

    # sift matched weeks
    mweeks <- sum(wat > wth)  # 05

    # return results
    result[stidx, ] <- c(accutempdiff, totaldays, avgmdays, maxmdays, mweeks)
}
result <- data.frame(result)
result$stno <- stnos

write.csv(result, file=outpath("temperature-2023.csv"))
save(result, file=outpath("temperature-2023.RData"))

warnings()
