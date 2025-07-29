# Handling Raw Climate Data
#### 2025/07/29 Liu, Chih Tse

### Project Structure
```
.
├── Reference         -- documentations and references
├── data               
│   ├── preprocessed  -- preprocessed data
│   └── raw           -- raw data
├── output            -- output statistics
└── script            -- all R codes
```

### Preprocessing Steps
1. For Linux OS 
    - Convert original data from ```BIG-5``` encoding to ```UTF-8``` encoding.
1. Extract data from the ```.txt``` File, convert the text data to a data-frame
    - Import data by each line
    - Replace any number of spaces with single space
    - Remove descriptions starting with ```*```
    - Remove ```#``` from the header
    - Remove any leading and trailing spaces in any line
    - Extract the table header
    - Recognize the 'stno' column as a character vector
    - Recognize the 'yyyymmddhh' column as a POSIXct vector
    - Recognize the remaining columns as numeric vectors
    - Gather and store the vectors as a data-frame
    - For all rows of 2023-01 ~ 2023-11, substract each datetime value by 1 hour to match that with 2023-12 (so the first and last hour of each day is 00:00 and 23:00, respectively)

1. Handling Special Values    
    - Replace 'None' with '-9999' (mainly for 2023-12) 
    - Replace the following special values with ```NA```
        - -9991, -9997, -9999
        - -999.1
        - -9.5, -99.5, -999.5, -9999.5
        - -9.7, -99.7, -999.7, -9999.7
        - -99.1, -9999.1, -9995, -99.6 (these values are not noted in the data descriptions, but they are too small to be true)
    - Replace the following special values with -9996 (雨量資料累計於後)
        - -9.6, -999.6
    - Replace the following special values with -9998 (雨跡，有降雨，但不大於某個很小的值)
        - -9.8
    - Save the above data-frame in ```./data/preprocessed```, named by ```yyyymm-pp.RData``` (eg. 202301-pp.RData)
1. 


### Calculating Statistics
Statistics in the following figure are calculated. Note that "布氏指數" is unavailable since the amount of "positive containers" are unavailable. 
<div style="text-align: center;">
<img src="./Reference/climate_statistics.jpg" alt="" style="width:700px; height:350px;">
</div>


#### Git Areas 
- Local: the user's machine (PC, laptop, etc.)
    - Working Directory: where scripts are stored and edited.
    - Staging Area: stores files from the working directory temporarily.
    - Repository: where previous snapshots of the working directory are stored.
- Remote: the remote directory (the online *codebase*, such as GitHub, GitLab, etc.).

#### Actions 
- ```add``` stores a snapshot of specified files from the working directory in the staging area and make git track modifications of the files.
- ```commit``` stores a snapshot of the **staging area** in the repository. 
    - Usually happens when the user reaches a specific state while developing. If there are multiple problems to address, commit once when each problem is resolved. Always make commit messages meaningful. 
- ```restore``` converts scripts in the working directory or the staging area back to the state of a specific snapshot.
- ```push``` uploads **all new snapshots** from local repository to remote. This makes the remote directory contain all files of the latest snapshot.
- ```pull``` downloads and stores **all new snapshots** (probably pushed by other users) from remote.
- ```clone``` downloads the entire remote directory, including the working directory, staging area and the repository.

There are many more actions that can be taken in git with different parameters and flags specified. Execute the following command for additional information and instructions:
```bash
git config --help  # opens a webpage for detailed information for 'git config'
git config -h      # displays brief instructions for 'git config' in console
```

### Setup Git
1. Download and install Git from: https://git-scm.com/
1. Make sure git is added to PATH (for windows, usually add ```C:\Program Files\Git\cmd```)
    * Execute ```git -v``` in console. If git is properly installed, it will display its version, such as ```git version 2.47.1.windows.1```. Alternatively, execute ```git``` and see if instructions of git commands pop out.
1. Setup git configurations
    1. Open a console or Git Bash (click the 'Git Bash' icon or execute ```git-bash``` in console)
    1. Specify user name and email
        ```bash
        git config --global user.name <username>
        git config --global user.email <useremail>
        ```
    1. Set default editor
        ```bash
        git config --global core.editor “code --wait" 
        # only if 'code' (VScode) was already added to PATH 
        # '--wait' puts the console on hold while a file is being edited when using git
        ```
    1. End of line (EOF) settings
        ```bash
        git config --global core.autocrlf true  # Windows: true, Liunx: input
        ```
    * To directly edit the global configuration file, execute the following command:
        ```bash
        git config --global -e  # edit global configurations by default editor
        ```