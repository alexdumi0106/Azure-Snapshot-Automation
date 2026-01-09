param($Timer)

Write-Host "===== DELETE OLD SNAPSHOTS SCRIPT STARTED ====="

# CONFIG
$subscriptionId = "44c13384-4ef0-46b3-899d-c83670f3ae38"
$resourceGroup  = "ALEXRG1"
$maxAgeMinutes  = 1440 # 24 hours   

# LOGIN
Connect-AzAccount -Identity
Select-AzSubscription -SubscriptionId $subscriptionId

# GET ALL SNAPSHOTS
$snapshots = Get-AzSnapshot -ResourceGroupName $resourceGroup

if ($snapshots.Count -eq 0) {
    Write-Host "No snapshots found."
    return
}

Write-Host "Found $($snapshots.Count) total snapshot(s). Checking age..."

$now = Get-Date

foreach ($snap in $snapshots) {

    $ageMinutes = ($now - $snap.TimeCreated).TotalMinutes

    Write-Host "Snapshot: $($snap.Name) -> Age = $([math]::Round($ageMinutes,2)) minute"

    if ($ageMinutes -gt $maxAgeMinutes) {
        Write-Host "Deleting snapshot: $($snap.Name)"

        try {
            Remove-AzSnapshot `
                -ResourceGroupName $resourceGroup `
                -SnapshotName $snap.Name `
                -Force

            Write-Host "DELETED: $($snap.Name)"
        }
        catch {
            Write-Host "ERROR deleting $($snap.Name):"
            Write-Host $_
        }
    }
    else {
        Write-Host "Keeping snapshot: $($snap.Name) (NOT old enough)"
    }
}

Write-Host "===== DELETE OLD SNAPSHOTS SCRIPT FINISHED ====="
