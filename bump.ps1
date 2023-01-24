try {
  Import-Module PsIni
} catch {
  Install-Module -Scope CurrentUser PsIni
  Import-Module PsIni
}
$repoName = "NationalSecurityAgency/ghidra"
$releasesUri = "https://api.github.com/repos/$repoName/releases/latest"
try { $tag = (Invoke-WebRequest $releasesUri | ConvertFrom-Json).tag_name }
catch {
  Write-Host "Error while pulling API."
  echo "SHOULD_COMMIT=no" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
  break
}
$tag2 = $tag.replace('Ghidra_','') -Replace '_build',''
Write-Host $tag2
if ($tag2 -match "alpha")
{
  Write-Host "Found alpha."
  echo "SHOULD_COMMIT=no" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
}
elseif ($tag2 -match "beta")
{
  Write-Host "Found beta."
  echo "SHOULD_COMMIT=no" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
}
elseif ($tag2 -match "RC")
{
  Write-Host "Found Release Candidate."
  echo "SHOULD_COMMIT=no" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
}
else{
    echo "UPSTREAM_TAG=$tag2" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
    $appinfo = Get-IniContent ".\ghidraPortable\App\AppInfo\appinfo.ini"
    if ($appinfo["Version"]["DisplayVersion"] -ne $tag2){
        $appinfo["Version"]["PackageVersion"]=-join($tag2,".0")
        $appinfo["Version"]["DisplayVersion"]=$tag2

        $installer = Get-IniContent ".\ghidraPortable\App\AppInfo\installer.ini"

        $asset1Pattern = "$tag2"
        $asset1 = (Invoke-WebRequest $releasesUri | ConvertFrom-Json).assets | Where-Object name -like $asset1Pattern
        $asset1Download = $asset1.browser_download_url.replace('%2B','+')
        $installer["DownloadFiles"]["DownloadURL"]=$asset1Download
        $installer["DownloadFiles"]["DownloadName"]=$asset1.name.replace('.zip','')
        $installer["DownloadFiles"]["DownloadFilename"]=$asset1.name
        $installer | Out-IniFile -Force -Encoding ASCII -Pretty -FilePath ".\ghidraPortable\App\AppInfo\installer.ini"

        $appinfo["Control"]["BaseAppID"]=-join("%BASELAUNCHERPATH%\App\ghidra_\App\ghidra_",$tag2,"_PUBLIC\ghidraRun.bat")
        $appinfo | Out-IniFile -Force -Encoding ASCII -FilePath ".\ghidraPortable\App\AppInfo\appinfo.ini"

        $launcher = Get-IniContent ".\ghidraPortable\App\AppInfo\Launcher\ghidraPortable.ini"
        $launcher["Launch"]["ProgramExecutable"]=-join("ghidra_",$tag2,"_PUBLIC\ghidraRun.bat")
        $launcher | Out-IniFile -Force -Encoding ASCII -FilePath ".\ghidraPortable\App\AppInfo\Launcher\ghidraPortable.ini"
        Write-Host "Bumped to "+$tag2
        echo "SHOULD_COMMIT=yes" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
    }
    else{
      Write-Host "No changes."
      echo "SHOULD_COMMIT=no" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
    } 
}
