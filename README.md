.SYNOPSIS
	RecentDocsParser.ps1 parses the Registry on a live system to collect the track of the last files and folders opened.
    This info is in Key "HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs"
    Can be found also in HIVE: "NTUSER.DAT"
    This is a piece of code from a bigger project I am developing called Inquisitor, that is a tools for incident response.
    
.DESCRIPTION
    It parses data from the registry key "HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs"
    
    To Activate the execution of Scripts:
    # Set-ExecutionPolicy -ExecutionPolicy Bypass
    
.EXAMPLE
	RecentDocsParser.ps1 -CSV
    Exports the results to CSV format
    
.EXAMPLE
	RecentDocsParser.ps1 -HTML
    Exports the results to HTML format
    
.EXAMPLE
	RecentDocsParser.ps1 -SCREEN
    Exports the results to the screen
    
.EXAMPLE
	RecentDocsParser.ps1 -CSV -HTML -SCREEN
    Exports the results to the screen and exports both to CSV and HTML
    
.NOTES
    Author:  f4d0
    Last Updated: 2019.05.17
    To Activate the execution of Scripts:
    # Set-ExecutionPolicy -ExecutionPolicy Bypass
        
    More info:
    - https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-6
    - https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-6
    
.LINK
    f4d0.eu
