param(
    [Parameter(Mandatory=$true)]
    $inputDetailsLocation,
    [Parameter(Mandatory=$true)]
    $bic,
    [Parameter(Mandatory=$true)]
    $iban,
    $creationDate
)

$entryTemplateFile = "EntryTemplate.txt"

if (!(Test-Path -path $entryTemplateFile -PathType Leaf)){
    Write-Error "Entry template does not exist"
    return
}

$fileTemplateFile = "FileTemplate.txt"

if (!(Test-Path -path $fileTemplateFile -PathType Leaf)){
    Write-Error "File template does not exist"
    return
}

if (!(Test-Path -path $inputDetailsLocation -PathType Leaf)){
    Write-Error "Input details file does not exist"
    return
}

if ($null -eq $creationDate){
    $creationDate = (Get-Date).ToString('yyyy-MM-dd')
}

$inputDetails = Import-Csv $inputDetailsLocation 

$entries = ""

foreach ($inputDetail in $inputDetails)
{
    $entry = Get-Content $entryTemplateFile

    $entryReplaces = New-Object System.Collections.Generic.List[System.Object]
    
    $entryReplaces.Add(@('*bookingDate*', $inputDetail.BookingDate))
    $entryReplaces.Add(@('*proprietaryCode*', $inputDetail.ProprietaryCode))
    $entryReplaces.Add(@('*transactionId*', $inputDetail.TransactionId))
    $entryReplaces.Add(@('*amount*', $inputDetail.Amount))
    $entryReplaces.Add(@('*reason*', $inputDetail.Reason))
    $entryReplaces.Add(@('*iban*', $inputDetail.Iban))
    $entryReplaces.Add(@('*bic*', $inputDetail.Bic))
    $entryReplaces.Add(@('*name*', $inputDetail.Name))


    foreach ($replace in $entryReplaces) {
        $entry = $entry.Replace($replace[0], $replace[1])
    }

    $entries += $entry
}


$camt053 = Get-Content $fileTemplateFile

$fileReplaces = New-Object System.Collections.Generic.List[System.Object]

$fileReplaces.Add(@('*iban*', $iban))
$fileReplaces.Add(@('*bic*', $bic))
$fileReplaces.Add(@('*entries*', $entries))
$fileReplaces.Add(@('*creationDate*', $creationDate))

foreach ($replace in $fileReplaces) {
    $camt053 = $camt053.Replace($replace[0], $replace[1])
}

$date = Get-Date -Format "yyyyMMddThhmmss"
$camt053 | Set-Content "CAMT053-$date.xml"
