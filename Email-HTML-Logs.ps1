<#PSScriptInfo

.VERSION 22.06.02

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
    Run with -help or no arguments for usage.
#>

## Set up command line switches.
[CmdletBinding()]
Param(
    [alias("Files")]
    $HtmlFilesUsr,
    [alias("L")]
    $LogPathUsr,
    [alias("LogRotate")]
    $LogHistory,
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
    [switch]$Help,
    [switch]$NoBanner)

If ($NoBanner -eq $False)
{
    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "
         ______                      _ _   _    _ _______ __  __ _                   
        |  ____|                    (_) | | |  | |__   __|  \/  | |                  
        | |__ ______ _ __ ___   __ _ _| | | |__| |  | |  | \  / | |                  
        |  __|______| '_   _ \ / _  | | | |  __  |  | |  | |\/| | |                  
        | |____     | | | | | | (_| | | | | |  | |  | |  | |  | | |____              
        |______|    |_| |_| |_|\__,_|_|_| |_| _|_|_ |_|  |_|  |_|______|             
        | |                     | |  | | | (_) (_) |                                 
        | |     ___   __ _ ___  | |  | | |_ _| |_| |_ _   _                          
        | |    / _ \ / _  / __| | |  | | __| | | | __| | | |        Mike Galvin      
        | |___| (_) | (_| \__ \ | |__| | |_| | | | |_| |_| |      https://gal.vin    
        |______\___/ \__, |___/  \____/ \__|_|_|_|\__|\__, |                         
                      __/ |                            __/ |     Version 22.06.02    
                     |___/                            |___/     See -help for usage  
                                                                                     
                       Donate: https://www.paypal.me/digressive                      
"
}

If ($PSBoundParameters.Values.Count -eq 0 -or $Help)
{
    Write-Host -Object "Usage:
    From a terminal run: [path\]Email-HTML-Logs.ps1 -Files [path\] -SendTo [example@contoso.com]
    -From [example@contoso.com] -Smtp [smtp server address]
    -User [example@contoso.com] -Pwd [path\]ps-script-pwd.txt -UseSsl
    This will get log files with the .html extension and then email them to the specified address.

    To output a log: -L [path\].
    To remove logs produced by the utility older than X days: -LogRotate [number].
    Run with no ASCII banner: -NoBanner

    To use the 'email log' function:
    Specify the subject line with -Subject ""'[subject line]'"" If you leave this blank a default subject will be used
    Make sure to encapsulate it with double & single quotes as per the example for Powershell to read it correctly.

    Specify the 'to' address with -SendTo [example@contoso.com]
    For multiple address, separate with a comma.

    Specify the 'from' address with -From [example@contoso.com]
    Specify the SMTP server with -Smtp [smtp server name]

    Specify the port to use with the SMTP server with -Port [port number].
    If none is specified then the default of 25 will be used.

    Specify the user to access SMTP with -User [example@contoso.com]
    Specify the password file to use with -Pwd [path\]ps-script-pwd.txt.
    Use SSL for SMTP server connection with -UseSsl.

    To generate an encrypted password file run the following commands
    on the computer and the user that will run the script:
"
    Write-Host -Object '    $creds = Get-Credential
    $creds.Password | ConvertFrom-SecureString | Set-Content [path\]ps-script-pwd.txt'
}

else {
    ## If logging is configured, start logging.
    ## If the log file already exists, clear it.
    If ($LogPathUsr)
    {
        ## Clean User entered string
        $LogPath = $LogPathUsr.trimend('\')

        ## Make sure the log directory exists.
        If ((Test-Path -Path $LogPath) -eq $False)
        {
            New-Item $LogPath -ItemType Directory -Force | Out-Null
        }

        $LogFile = ("Email-HTML-Logs_{0:yyyy-MM-dd_HH-mm-ss}.log" -f (Get-Date))
        $Log = "$LogPath\$LogFile"

        If (Test-Path -Path $Log)
        {
            Clear-Content -Path $Log
        }
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
            If ($LogPathUsr)
            {
                Add-Content -Path $Log -Encoding ASCII -Value "$(Get-DateFormat) [INFO] $Evt"
            }
            
            Write-Host -Object "$(Get-DateFormat) [INFO] $Evt"
        }

        If ($Type -eq "Succ")
        {
            If ($LogPathUsr)
            {
                Add-Content -Path $Log -Encoding ASCII -Value "$(Get-DateFormat) [SUCCESS] $Evt"
            }

            Write-Host -ForegroundColor Green -Object "$(Get-DateFormat) [SUCCESS] $Evt"
        }

        If ($Type -eq "Err")
        {
            If ($LogPathUsr)
            {
                Add-Content -Path $Log -Encoding ASCII -Value "$(Get-DateFormat) [ERROR] $Evt"
            }

            Write-Host -ForegroundColor Red -BackgroundColor Black -Object "$(Get-DateFormat) [ERROR] $Evt"
        }

        If ($Type -eq "Conf")
        {
            If ($LogPathUsr)
            {
                Add-Content -Path $Log -Encoding ASCII -Value "$Evt"
            }

            Write-Host -ForegroundColor Cyan -Object "$Evt"
        }
    }

    If ($Null -eq $HtmlFilesUsr)
    {
        Write-Log -Type Err -Evt "You need to specify a directory with -Files."
        Exit
    }

    else {
        ## Clean User entered string
        $HtmlFiles = $HtmlFilesUsr.trimend('\')
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
    Write-Log -Type Conf -Evt "Utility Version:.......22.06.02"
    Write-Log -Type Conf -Evt "Hostname:..............$Env:ComputerName."
    Write-Log -Type Conf -Evt "Windows Version:.......$OSV."
    If ($HtmlFilesUsr)
    {
        Write-Log -Type Conf -Evt "File path:.............$HtmlFilesUsr."
    }

    If ($LogPathUsr)
    {
        Write-Log -Type Conf -Evt "Logs directory:........$LogPathUsr."
    }

    If ($Null -ne $LogHistory)
    {
        Write-Log -Type Conf -Evt "Logs to keep:..........$LogHistory days."
    }

    If ($MailTo)
    {
        Write-Log -Type Conf -Evt "E-mail log to:.........$MailTo."
    }

    If ($MailFrom)
    {
        Write-Log -Type Conf -Evt "E-mail log from:.......$MailFrom."
    }

    If ($MailSubject)
    {
        Write-Log -Type Conf -Evt "E-mail subject:........$MailSubject."
    }

    If ($SmtpServer)
    {
        Write-Log -Type Conf -Evt "SMTP server is:........$SmtpServer."
    }

    If ($SmtpPort)
    {
        Write-Log -Type Conf -Evt "SMTP Port:.............$SmtpPort."
    }

    If ($SmtpUser)
    {
        Write-Log -Type Conf -Evt "SMTP user is:..........$SmtpUser."
    }

    If ($SmtpPwd)
    {
        Write-Log -Type Conf -Evt "SMTP pwd file:.........$SmtpPwd."
    }

    If ($SmtpServer)
    {
        Write-Log -Type Conf -Evt "-UseSSL switch is:.....$UseSsl."
    }
    Write-Log -Type Conf -Evt "************************************************************"
    Write-Log -Type Info -Evt "Process started"
    ##
    ## Display current config ends here.
    ##

    If ($HtmlFilesUsr)
    {
        $FileNo = Get-ChildItem -Path "$HtmlFiles\*.html" -File | Measure-Object

        If ($FileNo.count -ne 0)
        {
            Write-Log -Type Info -Evt "The following objects will be processed:"
            Get-ChildItem -Path "$HtmlFiles\*.html" | Select-Object -ExpandProperty Name

            If ($LogPathUsr)
            {
                Get-ChildItem -Path "$HtmlFiles\*.html" | Select-Object -ExpandProperty Name | Out-File -Append $Log -Encoding ASCII
            }

            Write-Log -Type Info -Evt "Process finished."

            If ($Null -ne $LogHistory)
            {
                ## Cleanup logs.
                Write-Log -Type Info -Evt "Deleting logs older than: $LogHistory days"
                Get-ChildItem -Path "$LogPath\Email-HTML-Logs_*" -File | Where-Object CreationTime -lt (Get-Date).AddDays(-$LogHistory) | Remove-Item -Recurse
            }

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
                $MailBody = Get-Content -Path "$HtmlFiles\*.html" | Out-String

                ForEach ($MailAddress in $MailTo)
                {
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
                            Send-MailMessage -To $MailAddress -From $MailFrom -Subject $MailSubject -Body $MailBody -BodyAsHtml -SmtpServer $SmtpServer -Port $SmtpPort -UseSsl -Credential $SmtpCreds
                        }

                        else {
                            Send-MailMessage -To $MailAddress -From $MailFrom -Subject $MailSubject -Body $MailBody -BodyAsHtml -SmtpServer $SmtpServer -Port $SmtpPort -Credential $SmtpCreds
                        }
                    }

                    else {
                        Send-MailMessage -To $MailAddress -From $MailFrom -Subject $MailSubject -Body $MailBody -BodyAsHtml -SmtpServer $SmtpServer -Port $SmtpPort
                    }
                }
            }

            else {
                Write-Log -Type Err -Evt "There is no smtp server configured."
            }
            ## End of Email block
        }

        else {
            Write-Log -Type Err -Evt "There are no files to process."
        }
    }

    else {
        Write-Log -Type Err -Evt "There are no files configured to process."
    }
}
## End