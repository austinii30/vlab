#################################################
# Filename: cal_perc_stat.R
# Purpose : calculate statistics from preprocessed data
# Student : Liu, Chih-Tse
# Date    : 2025/07/16
#################################################

source(file.path(this.path::this.dir(), "../../common_script/utils.R"))

load(ppdatpath("stdat_2023.RData"))  # stdat


# daily percipitation
dp <- function (dat, dtidx=1, ppidx=2) { 
    # sort the data by date
    dat <- dat[order(dat[, dtidx]), c(dtidx, ppidx)]

    daydt <- as.Date(dat[, dtidx])
    days <- unique(daydt)

    ppdaily <- rep(NA, length(days))
    for (didx in 1:length(days)) {
        d <- days[didx]
        ddat <- dat[daydt == d, ]

        



        ppdaily[didx] <- sum(ddat$PP01, na.rm=TRUE)
    }

    return(data.frame(date=days, PP01=ppdaily))
}


# ------------------------------------------------------------
# calculate percipitation statistics for each station
# return: a data-frame, rows: station, cols: statistics
# NOTE: statistic 01 can't be calculated
# ------------------------------------------------------------
result <- matrix(nrow=length(stdat), ncol=10)  # 10 statistics
for (stidx in 1:length(stdat)) {
    st <- stdat[[stidx]]
    dat <- st[, c("yyyymmddhh", "PP01")]

#    # set NA for all -9996 and its subsequent value
#    temp <- c()
#    missings <- which(dat$PP01 == -9996)
#    if (length(missings) > 0) {
#        for (midx in 1:length(missings)) {
#            m <- missings[midx]
#            temp <- c(temp, m)
#            if (dat$PP01[m+1] != -9996) { dat$PP01[c(temp, m+1)] <- NA }
#            else { next }
#            temp <- c()
#        }
#    }

    # minimum unit is day for 'ddat'
    ddat <- dp(dat)

    # 02, 03, 04
    th1 <- 10; th2 <- 80
    sraindays <- sum(ddat$PP01 < th1)  # 02
    mraindays <- sum(ddat$PP01 >= th1 & ddat$PP01 <= th2)  # 03
    lraindays <- sum(ddat$PP01 > th2)  # 04


    # 05
    yearmeanpp <- mean(ddat$PP01, na.rm=TRUE)  # 05


    # 06
    yearmeanppif <- mean(ddat$PP01[ddat$PP01 > 0], na.rm=TRUE)  # 06


    # 07, 08
    jtmdat <- ddat[as.numeric(format(ddat$date, "%m")) <= 5, ]
    res <- (jtmdat$PP01 > 0)
    res[is.na(res)] <- 0  # all NA eliminated
    res <- rle(res)
    periods <- res$lengths[res$values == 1]
    if (length(periods) == 0) jtmraindays <- 0
    else jtmraindays <- max(periods)  # 07

    res <- (jtmdat$PP01 < 5)
    res[is.na(res)] <- 0  # all NA eliminated
    res <- rle(res)
    periods <- res$lengths[res$values == 1]
    if (length(periods) == 0) jtmbraindays <- 0
    else jtmbraindays <- max(periods)  # 08


    # 09, 
    jtndat <- dat[as.numeric(format(dat$yyyymmddhh, "%m")) >= 6, ]
    jtndat <- jtndat[as.numeric(format(jtndat$yyyymmddhh, "%m")) <= 11, ]
    # ignore values -9996
    jtncleandat <- jtndat[jtndat$PP01 != -9996, ]

    jtntotalpp <- sum(jtncleandat$PP01, na.rm=TRUE)  # 09


    # 10, 11
    jtnddat <- ddat[as.numeric(format(ddat$date, "%m")) >= 6, ]
    jtnddat <- jtnddat[as.numeric(format(jtnddat$date, "%m")) <= 11, ]

    jtnraindays <- sum(jtnddat$PP01 > 0, na.rm=TRUE)  # 10
    jtnhraindays <- sum(jtnddat$PP01 > 200, na.rm=TRUE)  # 11


    # return results
    result[stidx, ] <- c(sraindays, mraindays, lraindays,
                         yearmeanpp, yearmeanppif, 
                         jtmraindays, jtmbraindays,
                         jtntotalpp, jtnraindays, jtnhraindays)
}
result <- as.data.frame(result)
result$stno <- names(stdat)
result <- result[, c(11, 1:10)]

write.csv(result, file=outpath("percepitation-2023.csv"))
save(result, file=outpath("percepitation-2023.RData"))

warnings()
