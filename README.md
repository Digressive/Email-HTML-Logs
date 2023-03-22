# Email HTML Logs Utility

Send HTML logs as e-mail

For full change log and more information, [visit my site.](https://gal.vin/utils)

Email HTML Logs Utility is available from:

* [GitHub](https://github.com/Digressive/Email-HTML-Logs)
* [The Microsoft PowerShell Gallery](https://www.powershellgallery.com/packages/Email-HTML-Logs)

Please consider supporting my work:

* Sign up using [Patreon](https://www.patreon.com/mikegalvin).
* Support with a one-time donation using [PayPal](https://www.paypal.me/digressive).

Please report any problems via the ‘issues’ tab on GitHub.

-Mike

## Features and Requirements

* Send the contents of HTML files as the body in e-mails.
* Useful for applications that output HTML logs with no e-mail option.
* The utility requires at least PowerShell 5.0.
* This utility has been tested on Windows 11, Windows 10, Windows Server 2022, Windows Server 2019, Windows Server 2016 and Windows Server 2012 R2.

## Generating A Password File For SMTP Authentication

The password used for SMTP server authentication must be in an encrypted text file. To generate the password file, run the following command in PowerShell on the computer and logged in with the user that will be running the utility. When you run the command, you will be prompted for a username and password. Enter the username and password you want to use to authenticate to your SMTP server.

Please note: This is only required if you need to authenticate to the SMTP server when send the log via e-mail.

``` powershell
$creds = Get-Credential
$creds.Password | ConvertFrom-SecureString | Set-Content c:\scripts\ps-script-pwd.txt
```

After running the commands, you will have a text file containing the encrypted password. When configuring the -Pwd switch enter the path and file name of this file.

## Configuration

Here’s a list of all the command line switches and example configurations.

| Command Line Switch | Description | Example |
| ------------------- | ----------- | ------- |
| -Files | The path that contains the HTML files to email. | [path\] |
| -L | The path to output the log file to. | [path\] |
| -LogRotate | Remove logs produced by the utility older than X days | [number] |
| -NoBanner | Use this option to hide the ASCII art title in the console. | N/A |
| -Help | Display usage information. No arguments also displays help. | N/A |
| -Subject | Specify a subject line. If you leave this blank the default subject will be used | "'[Server: Notification]'" |
| -SendTo | The e-mail address the log should be sent to. For multiple address, separate with a comma. | [example@contoso.com] |
| -From | The e-mail address the log should be sent from. | [example@contoso.com] |
| -Smtp | The DNS name or IP address of the SMTP server. | [smtp server address] |
| -Port | The Port that should be used for the SMTP server. If none is specified then the default of 25 will be used. | [port number] |
| -User | The user account to authenticate to the SMTP server. | [example@contoso.com] |
| -Pwd | The txt file containing the encrypted password for SMTP authentication. | [path\]ps-script-pwd.txt |
| -UseSsl | Configures the utility to connect to the SMTP server using SSL. | N/A |

## Example

``` txt
[path\]Email-HTML-Logs.ps1 -Files [path\] -SendTo [example@contoso.com] -From [example@contoso.com] -Smtp [smtp server address] -User [example@contoso.com] -Pwd [path\]ps-script-pwd.txt -UseSsl
```

This will get log files with the .html extension and then email them to the specified address.
