<#PSScriptInfo

.VERSION 21.12.08.01

.GUID 566309af-d0f7-4bf6-8303-b903553af661

.AUTHOR Mike Galvin Contact: mike@gal.vin / twitter.com/mikegalvin_ / discord.gg/5ZsnJ5k

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
    $creds.Password | ConvertFrom-SecureString | Set-Content C:\scripts\ps-script-pwd.txt

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

    .PARAMETER Port
    The Port that should be used for the SMTP server.

    .PARAMETER User
    The user account to authenticate to the SMTP server.

    .PARAMETER Pwd
    The txt file containing the encrypted password for SMTP authentication.

    .PARAMETER UseSsl
    Configures the utility to connect to the SMTP server using SSL.

    .EXAMPLE
    Email-HTML-Logs.ps1 -Files C:\foo\logs\*.html -L C:\scripts\logs -Subject 'Server: HTML Logs' -SendTo me@contoso.com
    -From HTML-Logs@contoso.com -Smtp smtp.outlook.com -User me@contoso.com -Pwd c:\scripts\ps-script-pwd.txt -UseSsl

    The above command will get log files with the html extension from the folder C:\foo\logs and then email them using an SSL connection.
    A log file will be output to C:\scripts\logs.

#>

## Set up command line switches.
[CmdletBinding()]
Param(
    [alias("Files")]
    $HtmlFiles,
    [alias("L")]
    $LogPath,
    [alias("Subject")]
    $MailSubject,
    [alias("SendTo")]
    $MailTo,
    [alias("From")]
    $MailFrom,
    [alias("Smtp")]
    $SmtpServer,
    [alias("Port")]
    $SmtpPort,
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
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "     Mike Galvin   https://gal.vin   Version 21.12.08.01            "
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "                                                                    "
    Write-Host -Object ""
}

## If logging is configured, start logging.
## If the log file already exists, clear it.
If ($LogPath)
{
    ## Make sure the log directory exists.
    $LogPathFolderT = Test-Path $LogPath

    If ($LogPathFolderT -eq $False)
    {
        New-Item $LogPath -ItemType Directory -Force | Out-Null
    }

    $LogFile = ("Email-HTML-Logs_{0:yyyy-MM-dd_HH-mm-ss}.log" -f (Get-Date))
    $Log = "$LogPath\$LogFile"

    $LogT = Test-Path -Path $Log

    If ($LogT)
    {
        Clear-Content -Path $Log
    }

    Add-Content -Path $Log -Encoding ASCII -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") [INFO] Log started"
}

## Function to get date in specific format.
Function Get-DateFormat
{
    Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

## Function for logging.
Function Write-Log($Type, $Evt)
{
    If ($Type -eq "Info")
    {
        If ($Null -ne $LogPath)
        {
            Add-Content -Path $Log -Encoding ASCII -Value "$(Get-DateFormat) [INFO] $Evt"
        }
        
        Write-Host -Object "$(Get-DateFormat) [INFO] $Evt"
    }

    If ($Type -eq "Succ")
    {
        If ($Null -ne $LogPath)
        {
            Add-Content -Path $Log -Encoding ASCII -Value "$(Get-DateFormat) [SUCCESS] $Evt"
        }

        Write-Host -ForegroundColor Green -Object "$(Get-DateFormat) [SUCCESS] $Evt"
    }

    If ($Type -eq "Err")
    {
        If ($Null -ne $LogPath)
        {
            Add-Content -Path $Log -Encoding ASCII -Value "$(Get-DateFormat) [ERROR] $Evt"
        }

        Write-Host -ForegroundColor Red -BackgroundColor Black -Object "$(Get-DateFormat) [ERROR] $Evt"
    }

    If ($Type -eq "Conf")
    {
        If ($Null -ne $LogPath)
        {
            Add-Content -Path $Log -Encoding ASCII -Value "$Evt"
        }

        Write-Host -ForegroundColor Cyan -Object "$Evt"
    }
}

## getting Windows Version info
$OSVMaj = [environment]::OSVersion.Version | Select-Object -expand major
$OSVMin = [environment]::OSVersion.Version | Select-Object -expand minor
$OSVBui = [environment]::OSVersion.Version | Select-Object -expand build
$OSV = "$OSVMaj" + "." + "$OSVMin" + "." + "$OSVBui"

##
## Display the current config and log if configured.
##

Write-Log -Type Conf -Evt "************ Running with the following config *************."
Write-Log -Type Conf -Evt "Utility Version:.......21.12.08.01"
Write-Log -Type Conf -Evt "Hostname:..............$Env:ComputerName."
Write-Log -Type Conf -Evt "Windows Version:.......$OSV."
Write-Log -Type Conf -Evt "File path:.............$HtmlFiles."

If ($Null -ne $LogPath)
{
    Write-Log -Type Conf -Evt "Logs directory:........$LogPath."
}

else {
    Write-Log -Type Conf -Evt "Logs directory:........No Config"
}

If ($MailTo)
{
    Write-Log -Type Conf -Evt "E-mail log to:.........$MailTo."
}

else {
    Write-Log -Type Conf -Evt "E-mail log to:.........No Config"
}

If ($MailFrom)
{
    Write-Log -Type Conf -Evt "E-mail log from:.......$MailFrom."
}

else {
    Write-Log -Type Conf -Evt "E-mail log from:.......No Config"
}

If ($MailSubject)
{
    Write-Log -Type Conf -Evt "E-mail subject:........$MailSubject."
}

else {
    Write-Log -Type Conf -Evt "E-mail subject:........Default"
}

If ($SmtpServer)
{
    Write-Log -Type Conf -Evt "SMTP server is:........$SmtpServer."
}

else {
    Write-Log -Type Conf -Evt "SMTP server is:........No Config"
}

If ($SmtpPort)
{
    Write-Log -Type Conf -Evt "SMTP Port:.............$SmtpPort."
}

else {
    Write-Log -Type Conf -Evt "SMTP Port:.............Default"
}

If ($SmtpUser)
{
    Write-Log -Type Conf -Evt "SMTP user is:..........$SmtpUser."
}

else {
    Write-Log -Type Conf -Evt "SMTP user is:..........No Config"
}

If ($SmtpPwd)
{
    Write-Log -Type Conf -Evt "SMTP pwd file:.........$SmtpPwd."
}

else {
    Write-Log -Type Conf -Evt "SMTP pwd file:.........No Config"
}

Write-Log -Type Conf -Evt "-UseSSL switch is:.....$UseSsl."
Write-Log -Type Conf -Evt "************************************************************"
Write-Log -Type Info -Evt "Process started"

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

        ## Default Smtp Port if none is configured.
        If ($Null -eq $SmtpPort)
        {
            $SmtpPort = "25"
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
                Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -Body $MailBody -BodyAsHtml -SmtpServer $SmtpServer -Port $SmtpPort -UseSsl -Credential $SmtpCreds
            }

            else {
                Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -Body $MailBody -BodyAsHtml -SmtpServer $SmtpServer -Port $SmtpPort -Credential $SmtpCreds
            }
        }

        else {
            Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -Body $MailBody -BodyAsHtml -SmtpServer $SmtpServer -Port $SmtpPort
        }
    }
}

## End
