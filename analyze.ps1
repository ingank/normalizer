# Variablen und Einstellungen
$dateiListe = "list.txt"
$eingabeDateiPfad = "text.txt"

# Aktuellen Pfad auf Skript-Ordner setzen
Push-Location $(Split-Path $Script:MyInvocation.MyCommand.Path)

# Sounddateien des aktuellen Ordners sammeln
cmd /r dir /b /on *.mp3 *.flac *.wav *.aiff > $dateiListe

# Alle Sounddateien des Ordners analysieren
Get-Content -Path $dateiListe | ForEach-Object {
    $dateiPfad = $_
    if (Test-Path "${dateiPfad}.txt") {
        Write-Host "Already Analyzed :: ${dateiPfad}.txt"
    }
    else {

        Write-Host "Analyze :: ${dateiPfad}"

        ffmpeg -hide_banner -i ${dateiPfad} -af ebur128=framelog=quiet:peak=true -f null - 2> ${eingabeDateiPfad}

        # Lese den gesamten Inhalt der Datei ein
        $inhalt = Get-Content $eingabeDateiPfad

        # Initialisiere Variablen für die Werte
        $loudness_i = $null
        $loudness_threshold = $null
        $lra = $null
        $lra_threshold = $null
        $lra_low = $null
        $lra_high = $null
        $true_peak = $null
        $threshold_flag = 0

        # Durchlaufe jede Zeile und extrahiere die Werte
        foreach ($zeile in $inhalt) {
            if ($zeile -match "I:\s+([-+]?\d+(\.\d+)?) LUFS") {
                $loudness_i = $matches[1]
            }
            elseif ($zeile -match "Threshold:\s+([-+]?\d+(\.\d+)?) LUFS") {
                if ($threshold_flag) {
                    $lra_threshold = $matches[1]
                }
                else {
                    $loudness_threshold = $matches[1]
                    $threshold_flag = 1
                }
            }
            elseif ($zeile -match "LRA:\s+([-+]?\d+(\.\d+)?) LU") {
                $lra = $matches[1]
            }
            elseif ($zeile -match "LRA low:\s+([-+]?\d+(\.\d+)?) LUFS") {
                $lra_low = $matches[1]
            }
            elseif ($zeile -match "LRA high:\s+([-+]?\d+(\.\d+)?) LUFS") {
                $lra_high = $matches[1]
            }
            elseif ($zeile -match "Peak:\s+([-+]?\d+(\.\d+)?) dBFS") {
                $true_peak = $matches[1]
            }
        }

        # Ausgabe der extrahierten Werte
        $text = @(
            "Integrated Loudness (I): $loudness_i LUFS",
            "Loudness Threshold: $loudness_threshold LUFS",
            "Loudness Range (LRA): $lra LU",
            "Loudness Range Threshold: $lra_threshold LUFS",
            "LRA Low: $lra_low LUFS",
            "LRA High: $lra_high LUFS",
            "True Peak: $true_peak dBFS"
        )
        $text | Out-File -FilePath "${dateiPfad}.txt"
    }
}
