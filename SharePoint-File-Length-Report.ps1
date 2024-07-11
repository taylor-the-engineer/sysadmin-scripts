$Domain =  "enter your tenant domain"
$MaxUrlLength = 400
$CSVFile = "C:\temp\LongURLInventory.csv"
$Pagesize = 2000
$TenantURL = "https://$Domain.SharePoint.com"
$TenantAdminURL = "https://$Domain-Admin.SharePoint.com"

Function Get-PnPLongURLInventory{
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Web)
    Write-host "Scanning Files: '$($Web.URL)'" -f Yellow
    $ExcludedLists = @("Form Templates", "Preservation Hold Library","Site Assets", "Pages", "Site Pages", "Images",
                            "Site Collection Documents", "Site Collection Images","Style Library")
    Get-PnPList -Web $Web -Connection $SiteConn | Where-Object {$_.BaseType -eq "DocumentLibrary" -and $_.Hidden -eq $false -and $_.Title -notin $ExcludedLists -and $_.ItemCount -gt 0} | ForEach-Object {
        $global:counter = 0;
        $LongURLInventory = @()
        $ListItems = Get-PnPListItem -List $_ -Web $web -Connection $SiteConn -PageSize $Pagesize -Fields Author, Created, File_x0020_Type -ScriptBlock { Param($items) $global:counter += $items.Count; Write-Progress -PercentComplete ($global:Counter / ($_.ItemCount) * 100) -Activity "Getting List Items of '$($_.Title)'" -Status "Processing Items $global:Counter to $($_.ItemCount)";}
        $LongListItems = $ListItems | Where { ([uri]::EscapeUriString($_.FieldValues.FileRef).Length + $TenantURL.Length ) -gt $MaxUrlLength }               
        If($LongListItems.count -gt 0){
            $Folder = Get-PnPProperty -ClientObject $_ -Property RootFolder
            Write-host "`tFound '$($LongListItems.count)' Item(s) with Long URLs at '$($Folder.ServerRelativeURL)'" -f Green       
            ForEach($ListItem in $LongListItems){
                $AbsoluteURL =  "$TenantURL$($ListItem.FieldValues.FileRef)"
                $EncodedURL = [uri]::EscapeUriString($AbsoluteURL)
                    $LongURLInventory += New-Object PSObject -Property ([ordered]@{
                        SiteName  = $Web.Title
                        SiteURL  = $Web.URL
                        LibraryName = $List.Title
                        LibraryURL = $Folder.ServerRelativeURL
                        ItemName = $ListItem.FieldValues.FileLeafRef
                        Type = $ListItem.FileSystemObjectType
                        FileType = $ListItem.FieldValues.File_x0020_Type
                        AbsoluteURL = $AbsoluteURL
                        EncodedURL = $EncodedURL
                        UrlLength = $EncodedURL.Length                     
                        CreatedBy = $ListItem.FieldValues.Author.LookupValue
                        CreatedByEmail  = $ListItem.FieldValues.Author.Email
                        CreatedAt = $ListItem.FieldValues.Created
                        ModifiedBy = $ListItem.FieldValues.Editor.LookupValue
                        ModifiedByEmail = $ListItem.FieldValues.Editor.Email
                        ModifiedAt = $ListItem.FieldValues.Modified                       
                    })
                }
                $LongURLInventory | Export-Csv $CSVFile -NoTypeInformation -Append
            }
            Write-Progress -Activity "Completed:  $($_.Title)" -Completed
        }
}
Connect-PnPOnline -Url $TenantAdminURL -UseWebLogin
If (Test-Path $CSVFile) { Remove-Item $CSVFile }
$Sites = Get-PnPTenantSite -Filter "Url -like '$TenantURL'"
$Sites | ForEach-Object {
    $SiteConn = Connect-PnPOnline -Url $_.URL -UseWebLogin -ReturnConnection
    Get-PnPWeb -Connection $SiteConn | Get-PnPLongURLInventory
    Get-PnPSubWebs -Recurse -Connection $SiteConn | ForEach-Object { Get-PnPLongURLInventory $_ }
    Disconnect-PnPOnline -Connection $SiteConn
}
