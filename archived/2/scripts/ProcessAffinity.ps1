Get-Process @("svchost", "audiodg") -ErrorAction SilentlyContinue | ForEach-Object { $_.ProcessorAffinity=0x8 }
