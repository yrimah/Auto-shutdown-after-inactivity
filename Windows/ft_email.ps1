# Configuration
$emailTo = "rimahyassine.pro@gmail.com"  # Update this to the actual recipient email address
$emailFrom = "rimahyassine2002@gmail.com"  # Update this to your Gmail address
$emailPassword = "..."  # Update this to your Gmail password or App Password
$smtpServer = "smtp.gmail.com"
$smtpPort = "587"
# $subject = "Test Email"

# Function to send email
function Send-Email($subject, $body) {
    $securePassword = ConvertTo-SecureString $emailPassword -AsPlainText -Force

    $message = New-Object System.Net.Mail.MailMessage
    $message.From = $emailFrom
    $message.To.Add($emailTo)
    $message.Subject = $subject
    $message.Body = $body

    $smtp = New-Object Net.Mail.SmtpClient($smtpServer, $smtpPort)
    $smtp.EnableSsl = $true
    $smtp.Credentials = New-Object System.Net.NetworkCredential($emailFrom, $securePassword)
    $smtp.Send($message)
}

# Sending test email
Send-Email -subject "Test Email1" -body "This is a test email from PowerShell using Gmail1."
