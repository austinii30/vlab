#################################################
# Filename: cal_temp_stat.R
# Purpose : calculate statistics from preprocessed data
# Student : Liu, Chih-Tse
# Date    : 2025/07/11
#################################################

source(file.path(this.path::this.dir(), "../../common_script/utils.R"))

load(ppdatpath("stdat_2023.RData"))  # stdat

# ------------------------------------------------------------
# calculate temperature statistics for each station
# ------------------------------------------------------------
for (st in stdat) {
    dat <- st[, c("yyyymmddhh", "TX01")]
    str(dat)



}























