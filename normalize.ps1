$soundFiles = cmd /r dir /b /on *.mp3 *.flac *.wav *.aiff
mkdir normalized 2>&1 1> $null

$vT = -16
$dynT = 12
$loudT = 4

$soundFiles | ForEach-Object {
    $soundFile = $_
    $ebur128File = $soundFile + ".ebur128"
    $normalizedFile = '.\normalized\' + $soundFile + '.flac'

    if (Test-Path "${normalizedFile}") {

        Write-Host "Allready Normalized :: ${soundFile}"

    }
    else {

        # Read the file line by line
        $lines = Get-Content $ebur128File

        # Initialize variables for the numeric values
        $integrated = 0
        $loudnessRange = 0
        $averageDynamics = 0
        $momentaryMax = 0
        $shortTermMax = 0
        $truePeakMax = 0

        # Parse each line and extract only the numeric values
        foreach ($line in $lines) {
            $parts = $line -split '='
            $key = $parts[0].Trim()
            $value = $parts[1].Trim()
            $number = [regex]::Match($value, '-?\d+(\.\d+)?').Value

            # Assign the numeric value to the appropriate variable
            switch ($key) {
                'Integrated' { $integrated = [float]$number }
                'Loudness Range' { $loudnessRange = [float]$number }
                'Average Dynamics (PLR)' { $averageDynamics = [float]$number }
                'Momentary Max' { $momentaryMax = [float]$number }
                'Short Term Max' { $shortTermMax = [float]$number }
                'True Peak Max' { $truePeakMax = [float]$number }
            }
        }

        $delta = $vT - (($integrated * 3 + $shortTermMax * 2 + $momentaryMax * 1) / 6)
        $delta = $delta + (($averageDynamics - $dynT) / 5)
        $delta = $delta + (($loudnessRange - $loudT) / 5)
        $delta = $delta + (($integrated - $momentaryMax) / 5)
        $delta = $delta + (($integrated - $shortTermMax) / 5)
        $delta = $delta + (($shortTermMax - $momentaryMax) / 5)
        $delta = [math]::Round($delta, 2)
        $ntp = [math]::Round($truePeakMax + $delta, 2)
        $nil = [math]::Round($integrated + $delta, 2)
        Write-Host "Normalize :: ${soundFile} :: Delta = ${delta} :: Integrated = ${nil} :: TruePeak = ${ntp}"
        ffmpeg -v error -i ${soundFile} -af volume=${delta}dB -ar 44100 ${normalizedFile}
    }
}
