# Azure Snapshot Automation

Azure Functions PowerShell automation for managing the full lifecycle of Azure VM disk snapshots.

# Features
- Automated VM disk snapshot creation
- Cross-region snapshot copy (Italy North to Spain Central)
- Automatic snapshot cleanup based on retention policy
- Secure authentication using Managed Identity

# Architecture
The solution is implemented using three independent Azure Functions, each with a specific responsibility:
1. CreateSnapshotItalyNorth
2. CopySnapshotsItalyToSpain
3. DeleteOldSnapshots

# Technologies Used
- Azure Functions (PowerShell)
- Azure Compute (Disks & Snapshots)
- Managed Identity
- Azure PowerShell (Az module) 
