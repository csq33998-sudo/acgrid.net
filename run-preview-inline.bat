@echo off
cd /d "%~dp0"
title MaisonLooks Preview Server
echo MaisonLooks local preview
echo.
echo Keep this window open.
echo Open this URL in your browser:
echo.
echo   http://127.0.0.1:8080/
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$Root=(Resolve-Path '.').Path; $Port=8080; $Listener=[System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse('127.0.0.1'),$Port); $Listener.Start(); Write-Host ('Serving '+$Root+' at http://127.0.0.1:8080/'); while($true){ $Client=$Listener.AcceptTcpClient(); try{ $Stream=$Client.GetStream(); $Buffer=New-Object byte[] 8192; $Read=$Stream.Read($Buffer,0,$Buffer.Length); $Req=[Text.Encoding]::ASCII.GetString($Buffer,0,$Read); $Path=((($Req -split \"`r?`n\")[0] -split ' ')[1] -split '\?')[0].TrimStart('/'); if([string]::IsNullOrWhiteSpace($Path)){ $Path='index.html' }; $Path=[Uri]::UnescapeDataString($Path); $File=[IO.Path]::GetFullPath([IO.Path]::Combine($Root,$Path)); $RootSlash=$Root.TrimEnd('\')+'\'; if((-not $File.StartsWith($RootSlash,[StringComparison]::OrdinalIgnoreCase)) -or (-not (Test-Path -LiteralPath $File -PathType Leaf))){ $Body=[Text.Encoding]::UTF8.GetBytes('Not found'); $Head=[Text.Encoding]::ASCII.GetBytes(\"HTTP/1.1 404 Not Found`r`nContent-Length: $($Body.Length)`r`nConnection: close`r`n`r`n\"); $Stream.Write($Head,0,$Head.Length); $Stream.Write($Body,0,$Body.Length); $Client.Close(); continue }; $Ext=[IO.Path]::GetExtension($File).ToLowerInvariant(); $Type=if($Ext -eq '.html'){'text/html; charset=utf-8'}elseif($Ext -eq '.css'){'text/css; charset=utf-8'}elseif($Ext -eq '.js'){'application/javascript; charset=utf-8'}elseif($Ext -eq '.xml'){'application/xml; charset=utf-8'}else{'application/octet-stream'}; $Body=[IO.File]::ReadAllBytes($File); $Head=[Text.Encoding]::ASCII.GetBytes(\"HTTP/1.1 200 OK`r`nContent-Type: $Type`r`nContent-Length: $($Body.Length)`r`nConnection: close`r`n`r`n\"); $Stream.Write($Head,0,$Head.Length); $Stream.Write($Body,0,$Body.Length); $Client.Close() } catch { if($Client){$Client.Close()} } }"
echo.
echo Server stopped or failed.
pause
