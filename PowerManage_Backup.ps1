

function Export-PartitionTable {

    # Disk Parameter
    param(
        [Parameter(Mandatory=$true)]
        [string]$DiskID,

        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    Get-Partition -DiskNumber $DiskID | Where-Object{$_.Type -ne "Reserved"} | Select-Object Offset, Size, DiskNumber | Export-Csv -NoTypeInformation -Path $Path

    
}

function New-PartitionTable {

    param(
        
        [Parameter(Mandatory=$true)]
        [string]$CSVPath
    )


    $content = Import-Csv -Path $CSVPath

    foreach($Element in $content)
    {
        New-Partition -DiskNumber $Element.DiskNumber -Offset $Element.Offset -Size $Element.Size
    }

    Write-Host "Table des partitions Cree" -ForegroundColor Green
}


