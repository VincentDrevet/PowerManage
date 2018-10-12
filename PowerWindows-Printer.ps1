$DebugPreference = "Continue"

function Install-PrinterDriver {
    param (
        [Parameter(Mandatory=$true)]
        [string]$InfFilePath,

        [Parameter(Mandatory=$true)]
        [string]$DriverName

    )

    Write-Debug "Importation et installation du driver $DriverName dans le magasin de driver"
    $pnpreturn = pnputil.exe /add-driver $InfFilePath /install

    # On récupère le nom du fichier inf publié dans store
    foreach ($line in $pnpreturn)
    {
        if($line -like "*Nom publi*")
        {
            $linearray = $line.split(" ")
            $DriverNameStore = $linearray[(($linearray.count) -1)]
            Write-Debug $DriverNameStore
        }

    }
    
    Add-PrinterDriver -Name $DriverName -InfPath "C:\Windows\INF\$DriverNameStore"

    Write-host -ForegroundColor Green "Driver installé"

}


function Get-InfPrinterDriver {
    param (
        [Parameter(Mandatory=$true)]
        [string]$InfFilePath

    )

    $InfContent = Get-Content $InfFilePath


    # On récupère les noms des drivers
    foreach($line in $InfContent)
    {
        if($line -match "TODO REGEX")
        {
            
        }
    }


    
}
