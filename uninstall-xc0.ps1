#define parameters
$prefix = "xc903"
$XConnectCollectionService = "$prefix.xconnect"
$sitecoreSiteName = "$prefix.sc"
$SolrUrl = "https://localhost:8983/solr"
$SolrRoot = "c:\solr\Solr-6.6.2"
$SolrService = "Solr-6.6.2"
$SqlServer = "."
$SqlAdminUser = "sa"
$SqlAdminPassword = Read-Host -Prompt "Enter SQL SA Password"

#####################################################
# 
#  Uninstall Sitecore
# 
#####################################################
Set-Location $PSScriptRoot

$carbon = Get-Module Carbon
if (-not $carbon) {
    Write-Host "Installing latest version of Carbon" -ForegroundColor Green
    Install-Module -Name Carbon -Repository PSGallery -AllowClobber -Verbose
    Import-Module Carbon
}

Import-Module "$PSScriptRoot\uninstall\uninstall.psm1"

$database = Get-SitecoreDatabase -SqlServer $SqlServer -SqlAdminUser $SqlAdminUser -SqlAdminPassword $SqlAdminPassword

# Delete Commerce Sites
Remove-SitecoreIisSite "CommerceAuthoring_Sc9"
Remove-SitecoreIisSite "CommerceMinions_Sc9"
Remove-SitecoreIisSite "CommerceOps_Sc9"
Remove-SitecoreIisSite "CommerceShops_Sc9"
Remove-SitecoreIisSite "SitecoreBizFx"
Remove-SitecoreIisSite "SitecoreIdentityServer"

# Drop Commerce Databases
Remove-SitecoreDatabase -Name "SitecoreCommerce9_SharedEnvironments" -Server $database
Remove-SitecoreDatabase -Name "SitecoreCommerce9_Global" -Server $database

# Delete Commerce files
Remove-Item "C:\inetpub\wwwroot\CommerceAuthoring_Sc9" -Force -Recurse -Verbose -ErrorAction Continue
Remove-Item "C:\inetpub\wwwroot\CommerceMinions_Sc9" -Force -Recurse -Verbose -ErrorAction Continue
Remove-Item "C:\inetpub\wwwroot\CommerceOps_Sc9" -Force -Recurse -Verbose -ErrorAction Continue
Remove-Item "C:\inetpub\wwwroot\CommerceShops_Sc9" -Force -Recurse -Verbose -ErrorAction Continue
Remove-Item "C:\inetpub\wwwroot\SitecoreBizFx" -Force -Recurse -Verbose -ErrorAction Continue
Remove-Item "C:\inetpub\wwwroot\SitecoreIdentityServer" -Force -Recurse -Verbose -ErrorAction Continue
Remove-Item "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\SitecoreCommerce9_Global_Primary.ldf" -Force -Verbose -ErrorAction Continue
Remove-Item "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\SitecoreCommerce9_Global_Primary.mdf" -Force -Verbose -ErrorAction Continue
Remove-Item "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\SitecoreCommerce9_SharedEnvironments_Primary.ldf" -Force -Verbose -ErrorAction Continue
Remove-Item "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\SitecoreCommerce9_SharedEnvironments_Primary.mdf" -Force -Verbose -ErrorAction Continue

Write-Host "Commerce Files Deleted" -ForegroundColor Green

# Delete Commerce Cores
Get-WmiObject win32_service  -Filter "name like '$($SolrService)'" | Stop-Service 
Remove-SitecoreSolrCore "CatalogItemsScope" -Root $SolrRoot
Remove-SitecoreSolrCore "CustomersScope" -Root $SolrRoot
Remove-SitecoreSolrCore "OrdersScope" -Root $SolrRoot
Get-WmiObject win32_service  -Filter "name like '$($SolrService)'" | Start-Service 

Write-Host "Commerce Cores Deleted" -ForegroundColor Green

# Drop the SQL Commerce login
#Remove-SitecoreDatabaseLogin -Server $database, -Name "LT-LAL-T-SE\CSFndRuntimeUser"
#Write-Host "Commerce Login Deleted" -ForegroundColor Green

#Unregister msg event
Get-EventSubscriber -SourceIdentifier "msg" | Unregister-Event

# Unregister xconnect services
Remove-SitecoreWindowsService "$($prefix).xconnect-MarketingAutomationService"
Remove-SitecoreWindowsService "$($prefix).xconnect-IndexWorker"

# Delete xconnect site
Remove-SitecoreIisSite "$($prefix).xconnect"

# Drop xconnect databases
Remove-SitecoreDatabase -Name "$($prefix)_Xdb.Collection.Shard0" -Server $database
Remove-SitecoreDatabase -Name "$($prefix)_Xdb.Collection.Shard1" -Server $database
Remove-SitecoreDatabase -Name "$($prefix)_Xdb.Collection.ShardMapManager" -Server $database
Remove-SitecoreDatabase -Name "$($prefix)_MarketingAutomation" -Server $database
Remove-SitecoreDatabase -Name "$($prefix)_Processing.Pools" -Server $database
Remove-SitecoreDatabase -Name "$($prefix)_Processing.Tasks" -Server $database
Remove-SitecoreDatabase -Name "$($prefix)_ReferenceData" -Server $database
Remove-SitecoreDatabase -Name "$($prefix)_Reporting" -Server $database

# Delete xconnect files
Remove-SitecoreFiles "C:\inetpub\wwwroot\$($prefix).xconnect"

# Delete xconnect cores

Get-WmiObject win32_service  -Filter "name like '$($SolrService)'" | Stop-Service 
Remove-SitecoreSolrCore "$($prefix)_xdb" -Root $SolrRoot
Remove-SitecoreSolrCore "$($prefix)_xdb_rebuild" -Root $SolrRoot
Get-WmiObject win32_service  -Filter "name like '$($SolrService)'" | Start-Service 

# Delete xconnect server certificate
Remove-SitecoreCertificate "$($prefix).xconnect"
# Delete xconnect client certificate
Remove-SitecoreCertificate "$($prefix).xconnect_client"

# Delete sitecore site
Remove-SitecoreIisSite "$sitecoreSiteName"

# Drop sitecore databases
Remove-SitecoreDatabase -Name "$($prefix)_Core" -Server $database
Remove-SitecoreDatabase -Name "$($prefix)_ExperienceForms" -Server $database
Remove-SitecoreDatabase -Name "$($prefix)_Master" -Server $database
Remove-SitecoreDatabase -Name "$($prefix)_Web" -Server $database
Remove-SitecoreDatabase -Name "$($prefix)_EXM.Master" -Server $database
Remove-SitecoreDatabase -Name "$($prefix)_Messaging" -Server $database

# Delete sitecore files
Remove-SitecoreFiles "C:\inetpub\wwwroot\$sitecoreSiteName"

# Delete sitecore cores
Get-WmiObject win32_service  -Filter "name like '$($SolrService)'" | Stop-Service 
Remove-SitecoreSolrCore "$($prefix)_core_index" -Root $SolrRoot
Remove-SitecoreSolrCore "$($prefix)_master_index" -Root $SolrRoot
Remove-SitecoreSolrCore "$($prefix)_web_index" -Root $SolrRoot
Remove-SitecoreSolrCore "$($prefix)_marketingdefinitions_master" -Root $SolrRoot
Remove-SitecoreSolrCore "$($prefix)_marketingdefinitions_web" -Root $SolrRoot
Remove-SitecoreSolrCore "$($prefix)_marketing_asset_index_master" -Root $SolrRoot
Remove-SitecoreSolrCore "$($prefix)_marketing_asset_index_web" -Root $SolrRoot
Remove-SitecoreSolrCore "$($prefix)_testing_index" -Root $SolrRoot
Remove-SitecoreSolrCore "$($prefix)_suggested_test_index" -Root $SolrRoot
Remove-SitecoreSolrCore "$($prefix)_fxm_master_index" -Root $SolrRoot
Remove-SitecoreSolrCore "$($prefix)_fxm_web_index" -Root $SolrRoot
Get-WmiObject win32_service  -Filter "name like '$($SolrService)'" | Start-Service 

# Delete sitecore certificate
Remove-SitecoreCertificate "$sitecoreSiteName"

# Drop the SQL Collectionuser login
Remove-SitecoreDatabaseLogin -Server $database, -Name "$($prefix)collectionuser"


