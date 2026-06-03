param(
  [int]$Port = 8080
)

$ErrorActionPreference = "Stop"
$Root = (Resolve-Path $PSScriptRoot).Path
$Listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse("127.0.0.1"), $Port)
$Listener.Start()

Write-Host "Serving $Root at http://127.0.0.1:$Port/"

$MimeTypes = @{
  ".html" = "text/html; charset=utf-8"
  ".css" = "text/css; charset=utf-8"
  ".js" = "application/javascript; charset=utf-8"
  ".json" = "application/json; charset=utf-8"
  ".xml" = "application/xml; charset=utf-8"
  ".txt" = "text/plain; charset=utf-8"
  ".svg" = "image/svg+xml"
  ".png" = "image/png"
  ".jpg" = "image/jpeg"
  ".jpeg" = "image/jpeg"
  ".webp" = "image/webp"
  ".ico" = "image/x-icon"
}

function Write-Response {
  param(
    [System.Net.Sockets.NetworkStream]$Stream,
    [int]$Status,
    [string]$StatusText,
    [string]$ContentType,
    [byte[]]$Body
  )

  $Header = "HTTP/1.1 $Status $StatusText`r`nContent-Type: $ContentType`r`nContent-Length: $($Body.Length)`r`nConnection: close`r`n`r`n"
  $HeaderBytes = [System.Text.Encoding]::ASCII.GetBytes($Header)
  $Stream.Write($HeaderBytes, 0, $HeaderBytes.Length)
  $Stream.Write($Body, 0, $Body.Length)
}

try {
  while ($true) {
    $Client = $Listener.AcceptTcpClient()
    try {
      $Stream = $Client.GetStream()
      $Buffer = New-Object byte[] 8192
      $Read = $Stream.Read($Buffer, 0, $Buffer.Length)
      if ($Read -le 0) {
        $Client.Close()
        continue
      }

      $Request = [System.Text.Encoding]::ASCII.GetString($Buffer, 0, $Read)
      $FirstLine = ($Request -split "`r?`n")[0]
      $Parts = $FirstLine -split " "
      $RequestPath = if ($Parts.Length -ge 2) { $Parts[1] } else { "/" }
      $RequestPath = [System.Uri]::UnescapeDataString(($RequestPath -split "\?")[0].TrimStart("/"))
      if ([string]::IsNullOrWhiteSpace($RequestPath)) {
        $RequestPath = "index.html"
      }

      $FilePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($Root, $RequestPath))
      $RootWithSlash = $Root.TrimEnd("\") + "\"
      $RelativePath = if ($FilePath.Length -ge $RootWithSlash.Length) { $FilePath.Substring($RootWithSlash.Length) } else { "" }
      $HasHiddenSegment = $RelativePath.Split("\") | Where-Object { $_.StartsWith(".") } | Select-Object -First 1
      $IsBlocked = -not $FilePath.StartsWith($RootWithSlash, [System.StringComparison]::OrdinalIgnoreCase) -or $null -ne $HasHiddenSegment

      if ($IsBlocked -or -not (Test-Path -LiteralPath $FilePath -PathType Leaf)) {
        Write-Response $Stream 404 "Not Found" "text/plain; charset=utf-8" ([System.Text.Encoding]::UTF8.GetBytes("Not found"))
        $Client.Close()
        continue
      }

      $Extension = [System.IO.Path]::GetExtension($FilePath).ToLowerInvariant()
      $ContentType = if ($MimeTypes.ContainsKey($Extension)) { $MimeTypes[$Extension] } else { "application/octet-stream" }
      Write-Response $Stream 200 "OK" $ContentType ([System.IO.File]::ReadAllBytes($FilePath))
      $Client.Close()
    }
    catch {
      if ($Client) {
        $Client.Close()
      }
    }
  }
}
finally {
  $Listener.Stop()
}
