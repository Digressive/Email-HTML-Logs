# Email-HTML-Logs

Email HTML Logs to a given address.

Tweet me if you have questions: [@mikegalvin_](https://twitter.com/mikegalvin_)

## Generating A Password File

The password used for SMTP server authentication must be in an encrypted text file. To generate the password file, run the following command in PowerShell, on the computer that is going to run the script and logged in with the user that will be running the script. When you run the command you will be prompted for a username and password. Enter the username and password you want to use to authenticate to your SMTP server.

Please note: This is only required if you need to authenticate to the SMTP server when send the log via e-mail.

``` powershell
$creds = Get-Credential
$creds.Password | ConvertFrom-SecureString | Set-Content c:\scripts\ps-script-pwd.txt
```

After running the commands, you will have a text file containing the encrypted password. When configuring the -Pwd switch enter the path and file name of this file.

### Configuration

Here’s a list of all the command line switches and example configurations.

    [alias("files")]
    $HtmlFiles,
    [alias("subject")]
    $MailSubject,
    [alias("sendto")]
    $MailTo,
    [alias("from")]
    $MailFrom,
    [alias("smtp")]
    $smtpServer,
    [alias("user")]
    $smtpUser,
    [alias("pwd")]
    $smtpPwd,
    [switch]$Usessl)

``` txt
-Files
```

The root path that contains the files to email, can use wildcards like: C:\foo\logs\*.html.

``` txt
-Subject
```

The subject of the email.

``` txt
-SendTo
```

The e-mail address the log should be sent to.

``` txt
-From
```

The from address the log should be sent from.

``` txt
-Smtp
```

The DNS name or IP address of the SMTP server.

``` txt
-User
```

The user account to connect to the SMTP server.

``` txt
-Pwd
```

The password for the user account.

``` txt
-UseSsl
```

Connect to the SMTP server using SSL.

### Example

``` txt
Email-HTML-Logs.ps1 -Files C:\foo\logs\*.html -Subject "HTML Logs" -SendTo me@contoso.com -From HTML-Logs@contoso.com -Smtp exch01.contoso.com -User me@contoso.com -Pwd P@ssw0rd -UseSsl
```

With these settings, the script will get log files with the extension .html fron the folder C:\foo\logs and then emailed using an SSL connection.
