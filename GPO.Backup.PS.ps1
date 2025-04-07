# Report PROPERTIES
# Set the recipients of the report.
	
    $users = "infra@elando.com"
    
    $date = get-date -format d.M.yyyy
 
#Path to the backup folder

    $backupPath = "\\ELANDO-DC\Backup\GPO\"

# Path to the report folder
		
    $reportPath = "\\ELANDO-DC\Backup\GPO\Reports\"

# Report name
		
    $reportName = "GPO.Backup_$($date).txt"


# Path and Report name together

    $GPOReport = $reportPath + $reportName

# Remove the report if it has already been run today so it does not append to the existing report
    
    If (Test-Path $GPOReport)
        {
            Remove-Item $GPOReport
        }
# Remove the report if it has already been run today so it does not append to the existing report
    
    <#If (Test-Path $backupPath)
        {
            Remove-Item $backupPath -Force
        }#>

#Cleanup 5 days old files

    $Daysback = "5"

    $CurrentDate = Get-Date;

    $DateToDelete = $CurrentDate.AddDays($Daysback);

    Get-ChildItem $backupPath | Where-Object { $_.LastWriteTime -lt $DateToDelete } | Remove-Item -Force;
    

# Run GPO Backup Script

    Import-Module grouppolicy

    New-Item -Path $backupPath\$date -ItemType directory | New-Item -Path $reportPath -ItemType directory

    Backup-Gpo -All -Path $backupPath\$date | Out-File $GPOReport

# Give credentials for Send email functionality 

    $s = New-Object System.Security.SecureString

    $creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "NT AUTHORITY\ANONYMOUS LOGON", $S

    $creds.GetNetworkCredential()

# Create Send email functionality

    $From = "infra@elando.bg"

    $To = $users

    $Attachment = $GPOReport

    $Subject = "GPO Backup Report File"

    $Body = "This is report from the domain controler that GPO backup script finished successfull."

    $SMTPServer = "webmail.elando.com"

    $SMTPPort = "26"

    Send-MailMessage -From $From -to $To -Subject $Subject `
    -Body $Body -SmtpServer $SMTPServer `
    -Attachments $Attachment -Credential ($creds)