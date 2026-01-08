https://parsec.app/downloads
Ran installer as admin

Installing Nvidia Drivers from 
https://www.nvidia.com/en-us/software/nvidia-app/

Updating RDP and Parsec

Windows App is the latest RDP:
NOPE: ~/Library/Containers/com.microsoft.rdc.macos/Data/Library/Application Support/com.microsoft.rdc.macos/
Maybe: /Users/darianhickman/Library/Containers/com.microsoft.rdc.macos/Data
Maybe: ./Library/Application Support/com.microsoft.rdc.macos/.com.microsoft.rdc.application-data_SUPPORT

/Users/darianhickman/Library/Containers/com.microsoft.rdc.macos/Data//Library/Application Support/com.microsoft.rdc.macos/.com.microsoft.rdc.application-data_SUPPORT

Winner: /Users/darianhickman/Library/Containers/com.microsoft.rdc.macos/Data/Library/Application Support/com.microsoft.rdc.macos/com.microsoft.rdc.application-data.sqlite

sqlite3 "/Users/darianhickman/Library/Containers/com.microsoft.rdc.macos/Data/Library/Application Support/com.microsoft.rdc.macos/com.microsoft.rdc.application-data.sqlite" .dump | grep "34.85.208.238"


Found hostname in ZBOOKMARKENTITY.ZHOSTNAME. 

There is no friendly nickname for the connection.  So probably just track existing primary key

sqlite3 "/Users/darianhickman/Library/Containers/com.microsoft.rdc.macos/Data/Library/Application Support/com.microsoft.rdc.macos/com.microsoft.rdc.application-data.sqlite" .dump > current.sql

So primary key is either Z_PK = 3 or 4. So change
UPDATE ZBOOKMARKENTITY
SET ZHOSTNAME= "ip address"
WHERE Z_PK = 3;
 

 Fixing Game Controller
 C:\Program Files\Parsec\pservice.exe
 C:\Program Files\Parsec


 NAME            ZONE        MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
win11-gpu-east  us-east1-d  n1-standard-4  true         10.142.0.2   34.75.133.177  RUNNING

ip_address: 34.75.133.177
password:   H_>:h(Zva8]l*+I
username:   darian_device

darian.hickman@gmail.com