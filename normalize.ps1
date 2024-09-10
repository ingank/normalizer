# Variablen und Einstellungen
$iT = -20

# Aktuellen Pfad auf Skript-Ordner setzen
Push-Location $(Split-Path $Script:MyInvocation.MyCommand.Path)

# Ordner für normalisierte Dateien erstellen
mkdir normalized 2>&1 1> $null

# Sounddateien des aktuellen Ordners ermitteln
$soundFiles = cmd /r dir /b /on *.mp3 *.flac *.wav *.aiff

# einzelne Soundfiles abarbeiten
$soundFiles | ForEach-Object {
    $soundFilePath = $_
    $configFilePath = $soundFilePath + ".txt"
    $normalizedFilePath = '.\normalized\'
    $normalizedFilePath += [System.IO.Path]::GetFileName($soundFilePath)
    $normalizedFilePath += '.flac'

    if (Test-Path "${normalizedFilePath}") {

        Write-Host "Allready Done :: ${normalizedFilePath}"

    }
    else {

        $inhalt = Get-Content $configFilePath

        # Initialisiere Variablen für die Werte
        $loudness_i = $null
        $loudness_threshold = $null
        $lra = $null
        $lra_threshold = $null
        $lra_low = $null
        $lra_high = $null
        $true_peak = $null

        # Durchlaufe jede Zeile und extrahiere die Werte
        foreach ($zeile in $inhalt) {
            if ($zeile -match "Integrated Loudness \(I\):\s+([-+]?\d+(\.\d+)?) LUFS") {
                $loudness_i = $matches[1]
            }
            elseif ($zeile -match "Loudness Threshold:\s+([-+]?\d+(\.\d+)?) LUFS") {
                $loudness_threshold = $matches[1]
            }
            elseif ($zeile -match "Loudness Range \(LRA\):\s+([-+]?\d+(\.\d+)?) LU") {
                $lra = $matches[1]
            }
            elseif ($zeile -match "Loudness Range Threshold:\s+([-+]?\d+(\.\d+)?) LUFS") {
                $lra_threshold = $matches[1]
            }
            elseif ($zeile -match "LRA Low:\s+([-+]?\d+(\.\d+)?) LUFS") {
                $lra_low = $matches[1]
            }
            elseif ($zeile -match "LRA High:\s+([-+]?\d+(\.\d+)?) LUFS") {
                $lra_high = $matches[1]
            }
            elseif ($zeile -match "True Peak:\s+([-+]?\d+(\.\d+)?) dBFS") {
                $true_peak = $matches[1]
            }
        }

        $iDiff = $iT - (([decimal]$lra_high + [decimal]$loudness_i * 2) / 3) + ($lra / 4)
        $iDiff = [math]::Round($iDiff, 2)

        Write-Host "Normalize :: ${normalizedFilePath} :: ${iDiff}"

        ffmpeg -v error -i ${soundFilePath} -af volume=${iDiff}dB -ar 44100 ${normalizedFilePath}
    }
}
