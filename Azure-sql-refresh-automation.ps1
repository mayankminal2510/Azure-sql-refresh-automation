######################################################################

# Connect to Azure

######################################################################

try 

{ 

   "Logging in to Azure..." 

   Connect-AzAccount -Identity 

} 

catch { 

   Write-Error -Message $_.Exception 

    throw $_.Exception 

} 

 

######################################################################

# DB Variables

######################################################################

$SourceSQLServerName = Get-AutomationVariable -Name "sourceServer"  # Source SQL server name

$sourceDatabase = Get-AutomationVariable -Name "sourceDatabase"     # Source database to be copied

$sourceResourceGroup = Get-AutomationVariable -Name "sourceResourceGroup"   # Source Resource group

$targetServer = Get-AutomationVariable -Name "targetServer"  # Target SQL server

$targetServerFQDN = Get-AutomationVariable -Name "targetServerFQDN"  # Target SQL server fqdn

$targetDBName = Get-AutomationVariable -Name "targetDBName"  # Target SQL server fqdn

$targetResourceGroup = Get-AutomationVariable -Name "targetResourceGroup"  # Target Resource group

$targetElasticPoolName = Get-AutomationVariable -Name "targetElasticPoolName"  # Target Elastic pool

 

# Print Server details

Write-Output "                                                                                                                               "

Write-Output "###############################################################################################################################"

Write-Output "Source Server : $SourceSQLServerName || Source Resource Group : $sourceResourceGroup || Source Database name : $sourceDatabase"

Write-Output "Target Server : $targetServer || Target Resource Group : $targetResourceGroup || Target Database name : $targetDBName"

Write-Output "###############################################################################################################################"

Write-Output ""

######################################################################

# Delete Target Database if Exists

######################################################################

try

{

    Write-Output "Deleting target database : $targetDBName"

    Remove-AzSqlDatabase -ResourceGroupName $targetResourceGroup -ServerName $targetServer -DatabaseName $targetDBName -ErrorAction Stop

    Write-Output "$targetDBName Deleted"

  

 

}

catch

{

    $errorMessage = $_.Exception.Message

    Write-Output "Failed to delete database: $targetDBName"

   

}

 

#Wait for 2 minutes

Write-Output "Waiting for 2 minutes before proceeding..."

Start-Sleep -Seconds 120

 

######################################################################

# Create Database Copy of Production

######################################################################

write-Output "Creating a database copy using Azure Automation runbook........"     

try

{

    New-AzSqlDatabaseCopy -ResourceGroupName $sourceResourceGroup -ServerName $SourceSQLServerName -DatabaseName $sourceDatabase -CopyResourceGroupName $targetResourceGroup -CopyServerName $targetServer -ElasticPoolName $targetElasticPoolName -CopyDatabaseName $targetDBName -ErrorAction Stop

    Write-Output "Database copy created successfully."

    Send-Alert "Database Copy" "Success" "Database $sourceDatabase copied to $targetDBName."

 

}

catch

{

    $errorMessage = $_.Exception.Message

    Write-Output "Failed to create database copy: $sourceDatabase Error Details: $errorMessage"

   

}

 

########################################################################

# Script to call Stored procedure

########################################################################

$credential = Get-AutomationPSCredential -Name "az-automation-poc01"

$applicationId = $credential.UserName

$applicationSecret = $credential.GetNetworkCredential().Password

$tenantId = "********-****-****-****-************"

$SQLServerName = Get-AutomationVariable -Name "targetServerFQDN"

$database = Get-AutomationVariable -Name "targetDBName"

 

$body = @{

    grant_type = "client_credentials"

    resource = https://database.windows.net/

    client_id = $applicationId

    client_secret = $applicationSecret

}

 

$authResponse = Invoke-RestMethod -Method Post -Uri https://login.microsoftonline.com/$tenantId/oauth2/token -Body $body

$accessToken = $authResponse.access_token

 

# Define SQL Queries

$queryList = @(

    "exec [dbo].[spPostBackup];",

    "CREATE USER [testing_user] FOR LOGIN [testing_user] WITH DEFAULT_SCHEMA=[dbo]",

    "CREATE ROLE [testing_reader]",

    "GRANT VIEW DEFINITION TO [testing_reader]",

    "ALTER ROLE [testing_reader] ADD MEMBER [testing_user]",

    "CREATE USER [SG-READ] FROM EXTERNAL PROVIDER",

    "ALTER ROLE [db_datareader] ADD MEMBER [SG-READ]"

)

 

foreach ($query in $queryList)

{

    try

    {

        $SQLOutput = $(Invoke-Sqlcmd -AccessToken $accessToken -ServerInstance $SQLServerName -Database $database -Query $query -QueryTimeout 65535 -ConnectionTimeout 60 -Verbose -ErrorAction Stop) 4>&1

        Write-Output $SQLOutput

        Write-Output "Successfully executed SQL query: $query"

        Send-Alert "SQL Execution" "Success" "Executed query: $query"

       

    }

    catch

    {

        $errorMessage = $_.Exception.Message

        Write-Output "SQL Query Failed: $query"

           

    }

}

 