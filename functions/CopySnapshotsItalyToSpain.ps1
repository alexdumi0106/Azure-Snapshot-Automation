param($Timer)

Write-Host "===== COPY SNAPSHOTS ITALY TO SPAIN SCRIPT STARTED ====="

$subscriptionId = "44c13384-4ef0-46b3-899d-c83670f3ae38"
$resourceGroup  = "ALEXRG1"
$sourceLocation = "Italy North"
$targetLocation = "Spain Central"

# Auth
Connect-AzAccount -Identity
Select-AzSubscription -SubscriptionId $subscriptionId

# First step: iterate through all the snapshots from Italy North
$snapshots = Get-AzSnapshot `
    | Where-Object { $_.Location -eq $sourceLocation }

if ($snapshots.Count -eq 0) {
    Write-Host "No snapshots found in $sourceLocation."
    return
}

Write-Host "Found $($snapshots.Count) snapshot(s) to copy."

foreach ($snap in $snapshots) {

    Write-Host "-----------------------------"
    Write-Host "Processing: $($snap.Name)"

    # Name of the copied snapshot
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $copyName = "$($snap.Name)-copy-$timestamp"

    # Second step: Configuring the new snapshot
    $snapshotConfig = New-AzSnapshotConfig `
        -SourceResourceId $snap.Id `
        -Location $targetLocation `
        -CreateOption Copy

    # Third step: create the snapshot in Spain Central
    try {
        New-AzSnapshot `
            -SnapshotName $copyName `
            -Snapshot $snapshotConfig `
            -ResourceGroupName $resourceGroup

        Write-Host "STEP OK: Created copy → $copyName"
    }
    catch {
        Write-Host "ERROR creating copy for snapshot $($snap.Name):"
        Write-Host $_
        continue
    }

    Write-Host "Waiting for snapshot copy to finish..."

    $maxAttempts = 30
    $attempt = 0
    $ready = $false

    while (-not $ready -and $attempt -lt $maxAttempts) {
        $attempt++

        try {
            $newSnap = Get-AzSnapshot -ResourceGroupName $resourceGroup -SnapshotName $copyName

            if ($newSnap.ProvisioningState -eq "Succeeded") {
                $ready = $true
                Write-Host "Copy is ready!"
            }
        }
        catch { }

        if (-not $ready) {
            Start-Sleep -Seconds 5
        }
    }

    if (-not $ready) {
        Write-Host "WARNING: Snapshot copy did not complete in time."
    }
}

Write-Host "==== COPY SNAPSHOTS ITALY TO SPAIN FINISHED ===="
