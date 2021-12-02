# Email HTML Logs Utility

Send HTML logs as e-mail

``` txt
 ______                      _ _   _    _ _______ __  __ _
|  ____|                    (_) | | |  | |__   __|  \/  | |
| |__ ______ _ __ ___   __ _ _| | | |__| |  | |  | \  / | |
|  __|______| '_   _ \ / _  | | | |  __  |  | |  | |\/| | |
| |____     | | | | | | (_| | | | | |  | |  | |  | |  | | |____
|______|    |_| |_| |_|\__,_|_|_| |_| _|_|_ |_|  |_|  |_|______|
| |                     | |  | | | (_) (_) |
| |     ___   __ _ ___  | |  | | |_ _| |_| |_ _   _
| |    / _ \ / _  / __| | |  | | __| | | | __| | | |
| |___| (_) | (_| \__ \ | |__| | |_| | | | |_| |_| |
|______\___/ \__, |___/  \____/ \__|_|_|_|\__|\__, |
              __/ |                            __/ |
             |___/                            |___/

     Mike Galvin   https://gal.vin   Version 20.03.19
```

Please consider supporting my work:

* Sign up [using Patreon.](https://www.patreon.com/mikegalvin)
* Support with a one-time payment [using PayPal.](https://www.paypal.me/digressive)

Email HTML Logs Utility can also be downloaded from:

* [The Microsoft PowerShell Gallery](https://www.powershellgallery.com/packages/Email-HTML-Logs)

Join the [Discord](http://discord.gg/5ZsnJ5k) or Tweet me if you have questions: [@mikegalvin_](https://twitter.com/mikegalvin_)

-Mike

## Features and Requirements

* Send the contents of HTML files as the body in e-mails.
* Useful for applications that output HTML logs with no e-mail option.

This utility has been tested on Windows 10, Windows Server 2019, Windows Server 2016 and Windows Server 2012 R2 (Datacenter and Core Installations).

### Generating A Password File

The password used for SMTP server authentication must be in an encrypted text file. To generate the password file, run the following command in PowerShell on the computer and logged in with the user that will be running the utility. When you run the command, you will be prompted for a username and password. Enter the username and password you want to use to authenticate to your SMTP server.

Please note: This is only required if you need to authenticate to the SMTP server when send the log via e-mail.

``` powershell
$creds = Get-Credential
$creds.Password | ConvertFrom-SecureString | Set-Content c:\scripts\ps-script-pwd.txt
```

After running the commands, you will have a text file containing the encrypted password. When configuring the -Pwd switch enter the path and file name of this file.

### Configuration

Here’s a list of all the command line switches and example configurations.

| Command Line Switch | Description | Example |
| ------------------- | ----------- | ------- |
| -Files | The root path that contains the files to email, can use wildcards. | C:\foo\logs\*.html |
| -L | The path to output the log file to. The file name will be Email-HTML_YYYY-MM-dd_HH-mm-ss.log. Do not add a trailing \ backslash. | C:\scripts\logs |
| -NoBanner | Use this option to hide the ASCII art title in the console. | N/A |
| -Subject | The subject line for the e-mail log. Encapsulate with single or double quotes. If no subject is specified, the default of "Email HTML Logs Utility" will be used. | 'Server: Notification' |
| -SendTo | The e-mail address the log should be sent to. | me@contoso.com |
| -From | The e-mail address the log should be sent from. | HTML-Logs@contoso.com |
| -Smtp | The DNS name or IP address of the SMTP server. | smtp.live.com OR smtp.office365.com |
| -User | The user account to authenticate to the SMTP server. | example@contoso.com |
| -Pwd | The txt file containing the encrypted password for SMTP authentication. | C:\scripts\ps-script-pwd.txt |
| -UseSsl | Configures the utility to connect to the SMTP server using SSL. | N/A |

### Example

``` txt
Email-HTML-Logs.ps1 -Files C:\foo\logs\*.html -L C:\scripts\logs -Subject 'Server: HTML Logs' -SendTo me@contoso.com -From HTML-Logs@contoso.com -Smtp smtp.outlook.com -User me@contoso.com -Pwd C:\foo\pwd.txt -UseSsl
```

The above command will get log files with the html extension from the folder C:\foo\logs and then email them using an SSL connection. A log file will be output to C:\scripts\logs.
