Import-Module -Name (Join-Path -Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) `
        -ChildPath 'xSQLServerHelper.psm1') `
    -Force

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]$SQLInstanceName,
        
        [ValidateNotNullOrEmpty()]
        [System.String]$SQLServer = $env:COMPUTERNAME,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]$BackupFileLocation

    )
    Write-Verbose "Getting database resource..."
    $SqlServerObject = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName

    if($SqlServerObject)
    {
        Write-Verbose -Message 'Getting the database restore status...'
        $RestoreStatus = Get-DatabaseRestoreStatus -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName -BackupFileLocation $BackupFileLocation
        
    }

    $returnValue = @{
        SQLInstanceName = $SQLInstanceName
        SQLServer       = $SQLServer
        RestoreStatus   = $RestoreStatus.DatabaseStatus
    }

    $returnValue

    
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [ValidateSet("Absent","Present")]
        [System.String]
        $Ensure,
        
        [parameter(Mandatory = $true)]
        [System.String]
        $BackupFileLocation,

        [System.String]
        $DataPath,

        [System.String]
        $LogPath,

        [System.String]
        $SQLServer,

        [System.String]
        $SQLInstanceName
    )
    Write-Verbose "Setting database resource..."
    if($Ensure -eq "Present")
    {
        $Splat = @{
            SQLServer = $SQLServer
            SQLInstanceName = $SQLInstanceName
            BackupFileLocation = $BackupFileLocation
            Verbose = $True
        }
        
        if($DataPath){$splat.add("DataPath",$DataPath)}
        if($LogPath){$splat.add("LogPath",$LogPath)}
        
        Invoke-DatabaseRestore @Splat
    }

}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [ValidateSet("Absent","Present")]
        [System.String]
        $Ensure,
        
        [parameter(Mandatory = $true)]
        [System.String]
        $BackupFileLocation,

        [System.String]
        $DataPath,

        [System.String]
        $LogPath,

        [System.String]
        $SQLServer,

        [System.String]
        $SQLInstanceName
    )
    Write-Verbose "Testing database restore..."
    $RestoreStatus = Get-DatabaseRestoreStatus -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName -BackupFileLocation $BackupFileLocation
    if($RestoreStatus.DatabaseExists)
    {
        Write-Verbose "Database '$($RestoreStatus.BackupDatabaseName)' exists and has a status of: '$($RestoreStatus.DatabaseStatus)'. No action required."
        $Result = $true
    }
    else
    {
        Write-Verbose "Database doesn't exist. Restore will commence."
        $Result = $false
    }
        
    $Result 
}

Export-ModuleMember -Function *-TargetResource
