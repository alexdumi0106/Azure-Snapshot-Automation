param($Timer)

$subscriptionId = "44c13384-4ef0-46b3-899d-c83670f3ae38"
$resourceGroup  = "ALEXRG1"
$diskName       = "alex-vm1_OsDisk_1_6d8e5f37c58643c2b3eb4d9a7b93fde0"

$location = "Italy North"

$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$snapshotName = "snapshot-$timestamp"

Write-Host "===== SCRIPT STARTED ====="

# Auth
Connect-AzAccount -Identity
Select-AzSubscription -SubscriptionId $subscriptionId

# First step: Create snapshot in Italy North
$snapshotConfig = New-AzSnapshotConfig `
    -SourceUri "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Compute/disks/$diskName" `
    -Location $location `
    -CreateOption Copy

New-AzSnapshot -SnapshotName $snapshotName -Snapshot $snapshotConfig -ResourceGroupName $resourceGroup
Write-Host "STEP 1 OK: Snapshot creat în Italy North: $snapshotName"

# Wait until snapshot is ready/finished
$maxAttempts = 20
$attempt = 0
$snapshotReady = $false

while (-not $snapshotReady -and $attempt -lt $maxAttempts) {
    $attempt++
    Write-Host "Waiting for snapshot to be ready... attempt $attempt / $maxAttempts"

    try {
        $snap = Get-AzSnapshot -ResourceGroupName $resourceGroup -SnapshotName $snapshotName -ErrorAction Stop
        if ($snap.ProvisioningState -eq "Succeeded") {
            $snapshotReady = $true
            Write-Host "Snapshot is ready!"
        }
    }
    catch {
        # snapshot not detected, still waiting...
    }

    Start-Sleep -Seconds 5
}

if (-not $snapshotReady) {
    Write-Host "ERROR: Snapshot did not finish provisioning!"
    return
}

Write-Host "===== SCRIPT FINISHED ====="
