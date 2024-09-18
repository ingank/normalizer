$currentPath = (Get-Location).Path + '\'
$soundFiles = cmd /r dir /b /on *.mp3 *.flac *.wav *.aiff
$decodedFile = $currentPath + "decoded.wav"
$analyzeFile = $currentPath + "decoded.txt"

try {

    $soundFiles | ForEach-Object {

        $soundFile = $_
        $ebur128File = "${soundFile}.ebur128"
    
        if (Test-Path "${ebur128File}") {

            Write-Host "Already analyzed :: ${soundFile}"

        }

        else {

            Write-Host "Analyze :: ${soundFile}"

            ffmpeg -hide_banner -v error -i $soundFile -y $decodedFile
            .\ylm2.exe --input-file-path $decodedFile --export --export-type "TEXT_SUMMARY" > $null

            $text = Get-Content $analyzeFile
            $lastSixRows = $text[-6..-1]
            $lastSixRows | Set-Content $ebur128File
            Remove-Item -Path $analyzeFile -Force

        }
    }
}

finally {

    Write-Host "Leave and clean up ..."

    if (Test-Path $analyzeFile) {

        Remove-Item -Path $analyzeFile

    }

    if (Test-Path $decodedFile) {

        Remove-Item -Path "$decodedFile"

    }
}
