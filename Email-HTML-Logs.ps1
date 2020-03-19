<#PSScriptInfo

.VERSION 20.03.19

.GUID 566309af-d0f7-4bf6-8303-b903553af661

.AUTHOR Mike Galvin Contact: mike@gal.vin / twitter.com/mikegalvin_

.COMPANYNAME Mike Galvin

.COPYRIGHT (C) Mike Galvin. All rights reserved.

.TAGS Email HTML files logs

.LICENSEURI

.PROJECTURI 

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

#>

<#
    .SYNOPSIS
    Email HTML Logs Utility - Send HTML logs as e-mail

    .DESCRIPTION
    Sends the contents of HTML files as e-mails.

    To send a log file via e-mail using ssl and an SMTP password you must generate an encrypted password file.
    The password file is unique to both the user and machine.

    To create the password file run this command as the user and on the machine that will use the file:

    $creds = Get-Credential
    $creds.Password | ConvertFrom-SecureString | Set-Content c:\foo\ps-script-pwd.txt

    .PARAMETER Files
    The root path that contains the files to email, can use wildcards like: C:\foo\logs\*.html.

    .PARAMETER NoBanner
    Use this option to hide the ASCII art title in the console.

    .PARAMETER L
    The path to output the log file to.
    The file name will be Email-HTML_YYYY-MM-dd_HH-mm-ss.log
    Do not add a trailing \ backslash.

    .PARAMETER Subject
    The subject line for the e-mail log.
    Encapsulate with single or double quotes.
    If no subject is specified, the default of "Email HTML Logs Utility" will be used.

    .PARAMETER SendTo
    The e-mail address the log should be sent to.

    .PARAMETER From
    The e-mail address the log should be sent from.

    .PARAMETER Smtp
    The DNS name or IP address of the SMTP server.

    .PARAMETER User
    The user account to authenticate to the SMTP server.

    .PARAMETER Pwd
    The txt file containing the encrypted password for SMTP authentication.

    .PARAMETER UseSsl
    Configures the utility to connect to the SMTP server using SSL.

    .EXAMPLE
    Email-HTML-Logs.ps1 -Files C:\foo\logs\*.html -L C:\scripts\logs -Subject 'Server: HTML Logs' -SendTo me@contoso.com
    -From HTML-Logs@contoso.com -Smtp smtp.outlook.com -User me@contoso.com -Pwd C:\foo\pwd.txt -UseSsl

    The above command will get log files with the html extension from the folder C:\foo\logs and then email them using an SSL connection.
    A log file will be output to C:\scripts\logs.

#>

## Set up command line switches.
[CmdletBinding()]
Param(
    [alias("Files")]
    $HtmlFiles,
    [alias("L")]
    [ValidateScript({Test-Path $_ -PathType 'Container'})]
    $LogPath,
    [alias("Subject")]
    $MailSubject,
    [alias("SendTo")]
    $MailTo,
    [alias("From")]
    $MailFrom,
    [alias("Smtp")]
    $SmtpServer,
    [alias("User")]
    $SmtpUser,
    [alias("Pwd")]
    [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
    $SmtpPwd,
    [switch]$UseSsl,
    [switch]$NoBanner)

If ($NoBanner -eq $False)
{
    Write-Host -Object ""
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "                                                                    "
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "   ______                      _ _   _    _ _______ __  __ _        "
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "  |  ____|                    (_) | | |  | |__   __|  \/  | |       "
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "  | |__ ______ _ __ ___   __ _ _| | | |__| |  | |  | \  / | |       "
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "  |  __|______| '_   _ \ / _  | | | |  __  |  | |  | |\/| | |       "
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "  | |____     | | | | | | (_| | | | | |  | |  | |  | |  | | |____   "
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "  |______|    |_| |_| |_|\__,_|_|_| |_| _|_|_ |_|  |_|  |_|______|  "
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "  | |                     | |  | | | (_) (_) |                      "
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "  | |     ___   __ _ ___  | |  | | |_ _| |_| |_ _   _               "
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "  | |    / _ \ / _  / __| | |  | | __| | | | __| | | |              "
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "  | |___| (_) | (_| \__ \ | |__| | |_| | | | |_| |_| |              "
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "  |______\___/ \__, |___/  \____/ \__|_|_|_|\__|\__, |              "
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "                __/ |                            __/ |              "
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "               |___/                            |___/               "
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "                                                                    "
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "     Mike Galvin   https://gal.vin   Version 20.03.19               "
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "                                                                    "
    Write-Host -Object ""
}

## Function to get date in specific format.
Function Get-DateFormat
{
    Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

## Function for logging.
Function Write-Log($Type, $Event)
{
    If ($Type -eq "Info")
    {
        If ($Null -ne $LogPath)
        {
            Add-Content -Path $Log -Encoding ASCII -Value "$(Get-DateFormat) [INFO] $Event"
        }
        
        Write-Host -Object "$(Get-DateFormat) [INFO] $Event"
    }

    If ($Type -eq "Succ")
    {
        If ($Null -ne $LogPath)
        {
            Add-Content -Path $Log -Encoding ASCII -Value "$(Get-DateFormat) [SUCCESS] $Event"
        }

        Write-Host -ForegroundColor Green -Object "$(Get-DateFormat) [SUCCESS] $Event"
    }

    If ($Type -eq "Err")
    {
        If ($Null -ne $LogPath)
        {
            Add-Content -Path $Log -Encoding ASCII -Value "$(Get-DateFormat) [ERROR] $Event"
        }

        Write-Host -ForegroundColor Red -BackgroundColor Black -Object "$(Get-DateFormat) [ERROR] $Event"
    }

    If ($Type -eq "Conf")
    {
        If ($Null -ne $LogPath)
        {
            Add-Content -Path $Log -Encoding ASCII -Value "$Event"
        }

        Write-Host -ForegroundColor Cyan -Object "$Event"
    }
}

##
## Display the current config and log if configured.
##
Write-Log -Type Conf -Event "************ Running with the following config *************."
Write-Log -Type Conf -Event "File path:.............$HtmlFiles."

If ($Null -ne $LogPath)
{
    Write-Log -Type Conf -Event "Logs directory:........$LogPath."
}

else {
    Write-Log -Type Conf -Event "Logs directory:........No Config"
}

If ($MailTo)
{
    Write-Log -Type Conf -Event "E-mail log to:.........$MailTo."
}

else {
    Write-Log -Type Conf -Event "E-mail log to:.........No Config"
}

If ($MailFrom)
{
    Write-Log -Type Conf -Event "E-mail log from:.......$MailFrom."
}

else {
    Write-Log -Type Conf -Event "E-mail log from:.......No Config"
}

If ($MailSubject)
{
    Write-Log -Type Conf -Event "E-mail subject:........$MailSubject."
}

else {
    Write-Log -Type Conf -Event "E-mail subject:........Default"
}

If ($SmtpServer)
{
    Write-Log -Type Conf -Event "SMTP server is:........$SmtpServer."
}

else {
    Write-Log -Type Conf -Event "SMTP server is:........No Config"
}

If ($SmtpUser)
{
    Write-Log -Type Conf -Event "SMTP user is:..........$SmtpUser."
}

else {
    Write-Log -Type Conf -Event "SMTP user is:..........No Config"
}

If ($SmtpPwd)
{
    Write-Log -Type Conf -Event "SMTP pwd file:.........$SmtpPwd."
}

else {
    Write-Log -Type Conf -Event "SMTP pwd file:.........No Config"
}

Write-Log -Type Conf -Event "-UseSSL switch is:.....$UseSsl."
Write-Log -Type Conf -Event "************************************************************"
Write-Log -Type Info -Event "Process started"
##
## Display current config ends here.
##

## If logging is configured then finish the log file.
If ($LogPath)
{
    Add-Content -Path $Log -Encoding ASCII -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") [INFO] Log finished"

    ## This whole block is for e-mail, if it is configured.
    If ($SmtpServer)
    {
        ## Default e-mail subject if none is configured.
        If ($Null -eq $MailSubject)
        {
            $MailSubject = "Email HTML Logs Utility"
        }

        ## Setting the contents of the log to be the e-mail body. 
        $MailBody = Get-Content -Path $HtmlFiles | Out-String

        ## If an smtp password is configured, get the username and password together for authentication.
        ## If an smtp password is not provided then send the e-mail without authentication and obviously no SSL.
        If ($SmtpPwd)
        {
            $SmtpPwdEncrypt = Get-Content $SmtpPwd | ConvertTo-SecureString
            $SmtpCreds = New-Object System.Management.Automation.PSCredential -ArgumentList ($SmtpUser, $SmtpPwdEncrypt)

            ## If -ssl switch is used, send the email with SSL.
            ## If it isn't then don't use SSL, but still authenticate with the credentials.
            If ($UseSsl)
            {
                Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -Body $MailBody -BodyAsHtml -SmtpServer $SmtpServer -UseSsl -Credential $SmtpCreds
            }

            else {
                Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -Body $MailBody -BodyAsHtml -SmtpServer $SmtpServer -Credential $SmtpCreds
            }
        }

        else {
            Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -Body $MailBody -BodyAsHtml -SmtpServer $SmtpServer
        }
    }
}

## End
