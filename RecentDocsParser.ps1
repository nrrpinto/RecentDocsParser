<#
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
#>

param (
    
    <# Export information to CSV format #>
    [switch]$CSV=$false,
    
    <# Export information to HTML format #>
    [switch]$HTML=$false,

    <# Show information in the screen #>
    [switch]$SCREEN=$false
)

if($CSV -eq $false -and $HTML -eq $false -and $SCREEN -eq $false)
{
    cls

    echo ""
    echo ""
    Write-Host "`tNo output option selected. To get more info, please type:" -ForegroundColor Red
    Write-Host "`t`tGet-Help RecentDocsParser.ps1" -ForegroundColor Green
    
    echo ""
    echo ""
    echo ""

    exit
}

$SIDs = Get-ChildItem "REGISTRY::HKEY_USERS" | ForEach-Object { ($_.Name).Split("\")[1] } # list of user SIDs
$hostname = hostname

Function Write-Html-Header{

    echo "<!DOCTYPE HTML PUBLIC `"-//W3C//DTD HTML 3.2 Final//EN`">" > "$($hostname)_RecentDocs.html"
    echo "<html><head><title>Recent Documents, Folders, Emails, ...</title></head>" >> "$($hostname)_RecentDocs.html"
    echo "<body>" >> "$($hostname)_RecentDocs.html"
    echo "<br><h4>Creators webpage: <a href=`"http://f4d0.eu/`" target=`"newwin`">http://www.f4d0.eu</a></h4><h4>Creators github: <a href=`"https://github.com/nrrpinto`" target=`"newwin`">https://github.com/nrrpinto</a></h4><p>" >> "$($hostname)_RecentDocs.html"
    echo "<table border=`"1`" cellpadding=`"5`"><tr bgcolor=`"E0E0E0`"> " >> "$($hostname)_RecentDocs.html"
    echo "<th>User" >> "$($hostname)_RecentDocs.html"
    echo "<th>Most Recent" >> "$($hostname)_RecentDocs.html"
    echo "<th>Reg. Key Number" >> "$($hostname)_RecentDocs.html"
    echo "<th>Data 1" >> "$($hostname)_RecentDocs.html"
    echo "<th>Data 2" >> "$($hostname)_RecentDocs.html"
    echo "<th>Data 3" >> "$($hostname)_RecentDocs.html"
    

}

Function Write-Html-Line{
    param(
        [string]$name = "",
        [string]$mru = "",
        [string]$rkn = "",
        [string]$data1 = "",
        [string]$data2 = "",
        [string]$data3 = ""
    )

    echo "<tr><td bgcolor=#FFFFFF nowrap> $name <td bgcolor=#FFFFFF nowrap> $mru <td bgcolor=#FFFFFF nowrap> $rkn <td bgcolor=#FFFFFF nowrap> $data1 <td bgcolor=#FFFFFF nowrap> $data2 <td bgcolor=#FFFFFF nowrap> $data3" >> "$($hostname)_RecentDocs.html"
}

Function Write-Html-Finish{
    echo "</table>" >> "$($hostname)_RecentDocs.html"
    echo "</body></html>" >> "$($hostname)_RecentDocs.html"
}

if($CSV) { echo "User, Most Recent, Reg. Key Number, Data 1, Data 2, Data 3" > "$($hostname)_RecentDocs.csv" }
if($HTML) { Write-Html-Header }



foreach($SID in $SIDS){
    
    if ($SID.Split("-")[7] -ne $null -and $SID.Split("-")[7] -notlike "*_Classes"){ # the ones that users removes the system and network and classes

        $NAME = Get-ItemPropertyValue -Path "REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$SID\" -Name "ProfileImagePath"  # get's the name correspondent to the SID
        $NAME = $NAME.Split("\")[-1]

        if($SCREEN) { Write-Host "USER: $NAME" -ForegroundColor Magenta }
        if($SCREEN) { echo "" ; Write-Host "Script developed by F4D0, please visit f4d0.eu" -ForegroundColor Yellow ; Write-Host "User | Most Recent | Reg. Key Number | Data 1 | Data 2 | Data 3" -ForegroundColor Green }

        # Read the MRUListEx - Here we can find the different entries and their order, from most recent to less recent
        $cnt = Get-ItemPropertyValue "REGISTRY::HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" -Name MRUListEx

        $arrayOrder = @()

        $i=0
        $e=0
        foreach($b in $cnt)
        {
            if( ($i % 4 -eq 0)  -and ($b -ne 0) -and ($b -ne 255) )
            {
                $arrayOrder += $b
                $e++
            }
            $i++
        } # gets the number of entries
        $max = (($i / 4) - 1)

        
        # Using the order from the previous collect info, from MRUListEx, it picks 
        $n=0
        foreach($a in $arrayOrder){
            $n++
            $temp = Get-ItemPropertyValue "REGISTRY::HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" -Name $a
            
            $i = 0
            $tete1 = ""
            $tete2 = ""
            $tete3 = ""
            $pos = 1
            $lock = $false
            foreach($b in $temp){
                
                # If not a zero and not locked, write the character for its corresponding position string
                if([int]$b -ne 0 -and (-not $lock) ){
                    $c = [char][int]$b
                    if($pos -eq 1 ) { $tete1 += "$c" }
                    if($pos -eq 2 ) { $tete2 += "$c" }
                    if($pos -eq 3 ) { $tete3 += "$c" }
                }

                # Control consecutive zeros
                if([int]$b -eq 0) 
                { 
                    $i = $i + 1 
                }
                else 
                { 
                    $i = 0
                }

                # Put a lock when two consecutive zeros
                if($i -gt 1) 
                {
                    $lock = $true
                }

                # If in position 2 and 1 zero appears, lock
                if($i -gt 0 -and $pos -eq 2)
                {
                    $lock = $true
                }

                # If 11 consecutive zeros and in position 1, remove lock and write to position 2
                if($i -eq 11 -and $pos -eq 1) 
                {
                    $pos = 2
                    $lock = $false
                }

                # If 29 consecutive zeros and in position 2, remove lock and write to position 3
                if($i -eq 29 -and $pos -eq 2)
                {
                    $pos = 3
                    $lock = $false
                }
            }
            if($CSV) { echo "$NAME, $n, $a, $tete1, $tete2, $tete3" >> "$($hostname)_RecentDocs.csv" }
            if($HTML) { Write-Html-Line -name "$NAME" -mru "$n" -rkn "$a" -data1 "$tete1" -data2 "$tete2" -data3 "$tete3" }
            if($SCREEN) { Write-Host "$NAME | $n | $a | $tete1 | $tete2 | $tete3" }
        }
    }
}

if($CSV) { echo "Created by using RecentDocsParser.ps1 from f4d0" >> "$($hostname)_RecentDocs.csv" }
if($HTML) { Write-Html-Finish }
if($SCREEN) { echo "" }