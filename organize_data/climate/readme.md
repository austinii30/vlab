# Climate Data
#### 2025/07/29 Liu, Chih Tse

### Project Structure
```
.
├── reference         
├── data               
│   ├── preprocessed  -- preprocessed data
│   └── raw           -- raw data
├── output            -- calculated statistics
└── script            -- all R codes
```

### Preprocessing Steps
1. Preprocess for Linux OS 
    - convert the original data from ```BIG-5``` encoding to ```UTF-8``` encoding
1. Extract data from the ```.txt``` file and convert it to a R data-frame
    - import data by each line
    - replace any number of spaces with single space
    - remove data descriptions starting with ```*```
    - remove ```#``` from the header
    - remove any leading and trailing spaces in all lines
    - extract header of the data
    - recognize the 'stno' column as a character vector
    - recognize the 'yyyymmddhh' column as a POSIXct vector
    - recognize the remaining columns as numeric vectors
    - gather and store the vectors as a data-frame
    - for all rows of 2023-01 ~ 2023-11, substract each datetime value by 1 hour to match that with 2023-12, so the first and last hour of each day is 00:00 and 23:00
1. Handle special values    
    - replace ```None``` with ```-9999``` (mainly for 2023-12) 
    - replace the following special values with ```NA```
        - ```-9991```, ```-9997```, ```-9999```
        - ```-999.1```
        - ```-9.5```, ```-99.5```, ```-999.5```, ```-9999.5```
        - ```-9.7```, ```-99.7```, ```-999.7```, ```-9999.7```
        - ```-99.1```, ```-9999.1```, ```-9995```, ```-99.6``` (these values are not noted in the data descriptions, but they are too extreme to be true)
    - replace the following special values with ```-9996``` (雨量資料累計於後)
        - ```-9.6```, ```-999.6```
    - replace the following special values with ```-9998``` (雨跡：有降雨，但不大於某個很小的值)
        - ```-9.8```
    - save the above data-frame in ```./data/preprocessed```, named by ```yyyymm-pp.RData``` (eg. 202301-pp.RData)
    - form a large data-frame by row-bining data of each month
    - seperate the data by station (create a data-frame for each station)
    - make sure each station contains data for the entire year (fill in ```NA``` for datetime without values)
    - for each station, sort the data by datetime 
    - handle special value ```-9996```
        - if ```-9996``` is the last value of the station, replace all previous ```-9996``` as ```NA```
        - if ```-9996``` is followed with ```0```/```NA```, replace all previous ```-9996``` as ```0```/```NA```
        - if the next value is also ```-9996```, skip the current one
        - if none of the above cases match, leave the value as ```-9996```
    - save preprocessed data at ```./data/preprocessed/```

    
### Climate Statistics
Statistics in the following figure are calculated. Note that "布氏指數" is unavailable since the amount of "positive containers" are unavailable. 
<div style="text-align: center;">
<img src="./reference/climate_statistics.jpg" alt="" style="width:794; height:836;">
</div>
