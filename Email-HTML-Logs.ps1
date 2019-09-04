# ---------------------------------------------------------------------------------------
# Script: Email HTML Logs
# Version: 1.1
# Author: Mike Galvin & Dan Price (twitter.com/therezin), based on code by Bhavik Solanki
# Contact: mike@gal.vin or twitter.com/mikegalvin_
# Date: 2019-09-04
# ---------------------------------------------------------------------------------------

# Set up command line switches and what variables they map to
Param(
    [alias("Files")]
    $HtmlFiles,
    [alias("Subject")]
    $MailSubject,
    [alias("SendTo")]
    $MailTo,
    [alias("From")]
    $MailFrom,
    [alias("Smtp")]
    $smtpServer,
    [alias("User")]
    $smtpUser,
    [alias("Pwd")]
    $smtpPwd,
    [switch]$UseSsl)

# If email was configured, set the variables for the email subject and body
If ($smtpServer)
{
    # If no subject is set, use the string below
    If ($Null -eq $MailSubject)
    {
        $MailSubject = "HTML Logs"
    }

    $MailBody = Get-Content -Path $HtmlFiles | Out-String

    # If an email password was configured, create a variable with the username and password
    If ($smtpPwd)
    {
        $smtpCreds = New-Object System.Management.Automation.PSCredential -ArgumentList $smtpUser, $($smtpPwd | ConvertTo-SecureString -AsPlainText -Force)

        # If ssl was configured, send the email with ssl
        If ($Usessl)
        {
            Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -Body $MailBody -BodyAsHtml -SmtpServer $smtpServer -UseSsl -Credential $smtpCreds
        }

        # If ssl wasn't configured, send the email without ssl
        Else
        {
            Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -Body $MailBody -BodyAsHtml -SmtpServer $smtpServer -Credential $smtpCreds
        }
    }

    # If an email username and password were not configured, send the email without authentication
    Else
    {
        Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -Body $MailBody -BodyAsHtml -SmtpServer $smtpServer
    }
}

# End
