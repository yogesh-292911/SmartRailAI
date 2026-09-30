# SmartRail — Windows setup (run in Cursor terminal / PowerShell)

Write-Host "Installing Python 3.12..."
winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements

Write-Host "Installing Git (optional)..."
winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements

Write-Host "Next (these open installers / take longer):"
Write-Host "  winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements"
Write-Host "  winget install -e --id Google.AndroidStudio --accept-package-agreements --accept-source-agreements"
Write-Host "  winget install -e --id Oracle.MySQL --accept-package-agreements --accept-source-agreements"
Write-Host "Flutter is not on winget. After Git is installed, reopen the terminal and run:"
Write-Host "  git clone https://github.com/flutter/flutter.git -b stable C:\flutter"
Write-Host "  then add C:\flutter\bin to your User PATH"
Write-Host "OR install XAMPP if you prefer a simpler MySQL: https://www.apachefriends.org/"
Write-Host "After Python install, CLOSE and REOPEN the Cursor terminal so 'python' is on PATH."
