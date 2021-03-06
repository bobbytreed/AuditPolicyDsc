
Import-Module $PSScriptRoot\..\Helper.psm1 -Verbose:0

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $CsvPath,

        [parameter()]
        [System.Boolean]
        $force = $false
    )

   
    $fileExists = Test-Path $CsvPath
    if($fileExists -and (Test-TargetResource $CsvPath -force $force))
    {
        $returnValue = @{
            CsvPath = $CsvPath
        }

    }
    else
    {
        if (!($fileExists))
        {
            Write-Verbose ($localizedData.FileNotFound -f $CsvPath)
        }
        $returnValue = @{
            CsvPath = ''
        }

    }
    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $CsvPath,

        [parameter()]
        [System.Boolean]
        $force = $false
    )

    if(Test-Path $CsvPath)
    {
        
        #clear existing policy!!
        Write-Verbose "Start Set" 
        try
        {
            Invoke-SecurityCmdlet -Action "Import" -Path $CsvPath | Out-Null
            Write-Verbose "Set Success"
        }
        catch
        {
            Write-Verbse "Set Fail" 
            Write-Verbose ($localizedData.ImportFailed -f $CsvPath)
        }


    }
    else
    {
        Write-Verbose ($localizedData.FileNotFound -f $CsvPath)
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $CsvPath,

        [parameter()]
        [System.Boolean]
        $force = $false
    )

    if(Test-Path $CsvPath)
    {
        #Question: Better way to create a temp file in SYSTEM context?
        $tempFile = "C:\Temp\test.CSV"
        if(! (Test-Path "c:\Temp\"))
        {
            New-Item -ItemType Directory -path "c:\temp\"
        }

        try
        {
            Invoke-SecurityCmdlet -Action "Export" -Path $tempFile
        }
        catch
        {
            Write-Verbose ($localizedData.ExportFailed -f $tempFile)
            return $false
        }

        #Ignore "Machine Name" since it will cause a failure if your CSV was generated on a different machine

        #compare GUIDs and values to see if they are the same
        #options have no GUIDs, just object names...

        #clearing settings just writes "0"s on top, so lets discard those from consideration

        $ActualSettings  =  import-csv $tempFile | ? { $_."Setting Value" -ne 0 -and $_."Setting Value" -ne ""} | Select-Object -Property "Subcategory GUID", "Setting Value"
        $DesiredSettings =  import-csv $CsvPath  | ? { $_."Setting Value" -ne 0 -and $_."Setting Value" -ne ""} | Select-Object -Property "Subcategory GUID", "Setting Value"
        
        

        $result = Compare-Object $DesiredSettings $ActualSettings
        #only report items where selected items are present in desired state but NOT in actual state
        if (! ($result) )
        {
            return $true
        }
        else
        {
            #TODO: branch on $force
            foreach ($entry in $result)
            {
                Write-Verbose ($localizedData.testCsvFailed -f $entry)
            }
            return $false
        }
    }

    else
    {
        Write-Verbose ($localizedData.FileNotFound -f $CsvPath)
        return $false
    }
    #this shouldn't get reached, but it is getting reached. 
    return $false
}

Export-ModuleMember -Function *-TargetResource
