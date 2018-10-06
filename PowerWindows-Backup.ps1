
# Création d'une snapshot
function New-VSSSnapshot
{

    param(
        [Parameter(Mandatory=$true)]
        [string]$Volume,

        [string]$Computername

    )

    # Vérification paramètre Computername
    if($Computername -eq "")
    {
        (get-wmiobject -class win32_ShadowCopy -List).Create($Volume,"ClientAccessible")
    }

    else
    {
        (get-wmiobject -class win32_ShadowCopy -List -ComputerName $Computername).Create($Volume,"ClientAccessible")
    }

}

function Get-VSSSnapshot
{
    Param
    (
        [string]$Computername
    )

    # Vérification paramètre Computername
    if($Computername -eq "")
    {
        $Snapshots = (get-wmiobject -class win32_ShadowCopy) | Format-Table -Property DeviceObject, OriginatingMachine, @{Name='Date';expression={($_.InstallDate).Substring(0,4)+"/"+($_.InstallDate).Substring(4,2)+"/"+($_.InstallDate).Substring(6,2)+" "+($_.InstallDate).Substring(8,2)+":"+($_.InstallDate).Substring(10,2)}} -AutoSize
    }
    else
    {
        $Snapshots = (get-wmiobject -class win32_ShadowCopy -ComputerName $Computername) | Format-Table -Property DeviceObject, OriginatingMachine, @{Name='Date';expression={($_.InstallDate).Substring(0,4)+"/"+($_.InstallDate).Substring(4,2)+"/"+($_.InstallDate).Substring(6,2)+" "+($_.InstallDate).Substring(8,2)+":"+($_.InstallDate).Substring(10,2)}} -AutoSize
    }
    $Snapshots
}

function Mount-VSSSnapshot
{

    param(
        [Parameter(Mandatory=$true)]
        [string]$DeviceObject,

        [Parameter(Mandatory=$true)]
        [string]$MountPath

    )

    # Creation Symlink
    cmd /c "mklink /d $MountPath $($DeviceObject+"\")"
    

}

function Dismount-VSSSnapshot
{

    param(
        [Parameter(Mandatory=$true)]
        [string]$MountPath

    )

    cmd /c "rmdir $MountPath" 2>$null

    # Vérification Suppresssion Symlink via Code Erreur DOS
    if($LASTEXITCODE -ne 0)
    {
        Write-Host "Erreur dans le démontage de la snapshot" -ForegroundColor Red
        Write-host "Code Erreur : $LASTEXITCODE" -ForegroundColor Red
    }
    else
    {
        Write-host -ForegroundColor Green "La Snapshot a été démontée avec succès."
    }
}

function Remove-VSSSnapshot
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$DeviceObject,

        [string]$Computername
    )
    
    $loop = $true

    if($Computername -eq "")
    {
        $VSS = Get-WmiObject -Class win32_ShadowCopy | Where-Object{$_.DeviceObject -eq $DeviceObject}
    }
    else
    {
        $VSS = Get-WmiObject -Class win32_ShadowCopy -ComputerName $Computername | Where-Object{$_.DeviceObject -eq $DeviceObject}
    }


    while($loop -eq $true)
    {

        Write-host "Valider la suppression du volume shadow Copy ? (Date : $(($VSS.InstallDate).Substring(0,4)+"/"+($VSS.InstallDate).Substring(4,2)+"/"+($VSS.InstallDate).Substring(6,2)+" "+($VSS.InstallDate).Substring(8,2)+":"+($VSS.InstallDate).Substring(10,2)))"
        $Response = Read-Host "Y/N"

        If($Response -eq "Y")
        {
            $VSS | Remove-WmiObject
            Write-host "Snapshot VSS Supprimé"
            $loop = $false
        }
        ElseIF ($Response -eq "N")
        {
            Write-host "Annulation de la suppression"
            $loop = $false
        }
    }

}