# xSQLDbRestore
Additional DSC resource to be added to Microsoft's xSqlServer resource.

This resource adds functionality to restore SQL server databases via DSC. It is a bolt-on to Microsoft's own xSQLServer resource that can be found [here](https://www.powershellgallery.com/packages/xSQLServer/8.2.0.0).

**Please note:** This was developed against version 8.2.0.0. At time of writing, the latest version of xSqlServer is 9.0.0.0 (16/12/2017).

I should really raise a PR and get it added properly, but A) nobody else is likely to want it as someone would have done it already, and B) I just don't have time to learn and write all the testing scripts. (Not that I don't want to learn).

**To use**, 

 1. Copy MSFT_xSqlDbRestore.ps1 to ..Modules\xSqlServer\DSCResources\
 2. Overwrite xSqlServerHelper.psm1 with the one in ..Modules\xSqlServer\.

If you don't want to run the risk of damaging MS's work with my shoddy code, the two functions `Get-DatabaseRestoreStatus` and `Invoke-DatabaseRestore` are at the bottom. 

Here is an example of a configuration with it in use:

    Configuration TestDBRestore
    {
        Import-DscResource -ModuleName xSQLServer
    
        Node LocalHost
        {
            hSqlDbRestore RestoreModel
            {
                Ensure = "Present"
                SQLServer = $env:COMPUTERNAME
                SQLInstanceName = "MSSQLSERVER"
                BackupFileLocation = "R:\"
                   
            }
        }
    }
    
    TestDBRestore -OutputPath C:\Temp\TestDBRestore -verbose
    
    Start-DscConfiguration -Path C:\Temp\TestDBRestore -wait -debug -Verbose -Force

