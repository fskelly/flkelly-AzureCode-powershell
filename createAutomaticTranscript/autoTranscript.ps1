notepad $profile

##copy below into profile file

$transcriptFolderName = "psTranscripts"
$transcriptPath = "c:\users\" + $env:USERNAME + "\" + $transcriptFolderName + "\" + (get-date -Format dd.MM.yyyy-hh.mm.ss) + ".txt"
Start-Transcript -Path $transcriptPath
