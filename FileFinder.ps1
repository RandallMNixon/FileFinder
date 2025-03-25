# Function to get available root drives
function Get-AvailableRootDrives {
    Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match "^[A-Z]:\\$" } | Select-Object -ExpandProperty Root
}

# Get the list of available root drives
$availableDrives = Get-AvailableRootDrives

# Display the available root drives to the user
Write-Host "Available drives:"
$availableDrives | ForEach-Object { Write-Host $_ }

# Prompt the user to choose a drive letter
$driveLetter = (Read-Host "Enter the drive letter to search (e.g., C)").ToUpper()

# Validate the selected drive letter
if (-not ($availableDrives -contains "${driveLetter}:\")) {
    Write-Host "Invalid drive letter. Please run the script again and choose a valid drive."
    exit
}

# Prompt the user for the filename to search for
$filename = Read-Host "Enter the filename to search for"

# Prompt the user for the number of matches to find before stopping
$maxMatches = [int](Read-Host "Enter the number of matches to find before stopping")

# Initialize the file counter and match counter
$fileCount = 0
$matchCount = 0

# Initialize the search timer
$searchTimer = [System.Diagnostics.Stopwatch]::StartNew()

# Get all files recursively from the selected drive
$drive = "${driveLetter}:\"
$files = Get-ChildItem -Path $drive -Recurse -ErrorAction SilentlyContinue

# Initialize the index for the while loop
$index = 0

# Use a while loop to process each file
while ($index -lt $files.Length -and $matchCount -lt $maxMatches) {
    $file = $files[$index]
    $fileCount++
    
    # Check if the current file matches the search criteria (partial match)
    if ($file.Name -like "*$filename*") {
        Write-Host "Found file: $($file.FullName)"
        $matchCount++
    }

    # Increment the index
    $index++
}

# Stop the search timer
$searchTimer.Stop()

# Print the final count of checked files, matches found, and total time spent searching
Write-Host "Total files checked: $fileCount"
Write-Host "Total matches found: $matchCount"
Write-Host "Total time spent searching: $($searchTimer.Elapsed.TotalSeconds) seconds"

Read-Host