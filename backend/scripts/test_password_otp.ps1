param(
  [string]$BaseUrl = "http://localhost:8000",
  [Parameter(Mandatory=$true)][string]$Email,
  [Parameter(Mandatory=$true)][string]$NewPassword
)

$ErrorActionPreference = 'Stop'

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Ok($msg) { Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err($msg) { Write-Host "[ERR] $msg" -ForegroundColor Red }

$authUrl = "$BaseUrl/api/auth"

try {
  Write-Info "Requesting password reset OTP for $Email"
  $reqBody = @{ email = $Email } | ConvertTo-Json
  $resp = Invoke-RestMethod -Method POST -Uri "$authUrl/password-otp/request" -ContentType 'application/json' -Body $reqBody
  $code = $null
  if ($resp -and $resp.preview -and $resp.preview.code) {
    $code = [string]$resp.preview.code
    Write-Ok "Received preview code (dev): $code"
  } else {
    Write-Warn "No preview code in response. If running in production mode, check your email mailbox."
    $code = Read-Host "Enter the 6-digit code received by email"
  }

  if (-not $code -or $code.Length -ne 6) {
    throw "Invalid code length. Expected 6 digits."
  }

  Write-Info "Confirming password reset with code"
  $confirmBody = @{ email = $Email; code = $code; new_password = $NewPassword } | ConvertTo-Json
  $confirm = Invoke-RestMethod -Method POST -Uri "$authUrl/password-otp/confirm" -ContentType 'application/json' -Body $confirmBody
  Write-Ok "Password reset confirmed: $($confirm | ConvertTo-Json -Compress)"

  Write-Info "Attempting login with new password (OAuth2 password flow)"
  $form = "username=$([uri]::EscapeDataString($Email))&password=$([uri]::EscapeDataString($NewPassword))&grant_type=password"
  $login = Invoke-RestMethod -Method POST -Uri "$authUrl/token" -ContentType 'application/x-www-form-urlencoded' -Body $form
  Write-Ok "Login succeeded. Access token (truncated): $($login.access_token.Substring(0,24))..."
} catch {
  # Attempt to surface backend-provided error detail
  if ($_.Exception.Response -and $_.Exception.Response.GetResponseStream) {
    try {
      $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
      $raw = $reader.ReadToEnd()
      Write-Err "API error: $raw"
    } catch {
      Write-Err $_.Exception.Message
    }
  } else {
    Write-Err $_.Exception.Message
  }
  exit 1
}
