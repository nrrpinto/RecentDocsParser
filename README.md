#RecentDocsParser

DESCRIPTION
    
It parses data from the registry key "HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" on a live system to collect the track of the last used files and opened folders.
This key belongs to HIVE: "NTUSER.DAT"
This is a piece of code from a bigger project I am developing called Inquisitor, which is going to be a complete tool for digital forensics and incident response.

To Activate the execution of Scripts, execute the following in powershell:
	
	Set-ExecutionPolicy -ExecutionPolicy Bypass
    
    
EXAMPLES

Exports the results to CSV format

	RecentDocsParser.ps1 -CSV

Exports the results to HTML format
    
	RecentDocsParser.ps1 -HTML

Exports the results to the screen

	RecentDocsParser.ps1 -SCREEN

Exports the results to the screen and exports both to CSV and HTML    

	RecentDocsParser.ps1 -CSV -HTML -SCREEN
