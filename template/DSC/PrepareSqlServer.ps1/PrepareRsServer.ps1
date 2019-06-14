#
# Copyright="� Microsoft Corporation. All rights reserved."
#
configuration PrepareSSRSServer
{
    param
    (
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SQLSAAdminAuthCreds,

	[Parameter(Mandatory)]
        [String]$CatalogMachine
    )

    Import-DscResource -ModuleName xSQLServer,xNetworking,xPSDesiredStateConfiguration

    Node localhost
    {   
        
		xFirewall DatabaseEngineFirewallRule
		{
			Direction = "Inbound"
			Name = "Reporting-Services-HTTP-In"
			DisplayName = "Reporting Services (TCP-In)"
			Description = "Inbound rule for Reporting Services to allow TCP traffic for Report Server."
			DisplayGroup = "SQL Server"
			State = "Enabled"
			Access = "Allow"
			Protocol = "TCP"
			LocalPort = "80"
			Ensure = "Present"
		}
    

		xSQLServerRSConfig RSServer
		{
			InstanceName = "MSSQLSERVER"
			RSSQLServer = $CatalogMachine
			RSSQLInstanceName = "MSSQLSERVER"
			SQLAdminCredential = $SQLSAAdminAuthCreds
		    PsDscRunAsCredential = $SQLSAAdminAuthCreds
			DependsOn = "[xService]ReportServer"
		}
	<#	SqlRS RSServer
		{
			InstanceName = "MSSQLSERVER"
			DatabaseServerName = $CatalogMachine
			DatabaseInstanceName = "MSSQLSERVER"
			ReportServerVirtualDirectory = 'MyReportServer'
            ReportsVirtualDirectory      = 'MyReports'
			ReportServerReservedUrl      = @('http://+:80')
			ReportsReservedUrl           = @('http://+:80')
			#ReportServerReservedUrl      = @('http://+:80', 'https://+:443')
			#ReportsReservedUrl           = @('http://+:80', 'https://+:443')
			SQLAdminCredential = $SQLSAAdminAuthCreds
			PsDscRunAsCredential = $SQLSAAdminAuthCreds
			DependsOn = "[xService]ReportServer"
		}
		#>
		#Note:  if the database is on another server you must set Credential to a domain account or Initalize will fail
		xService ReportServer
		{
			Name = "ReportServer"
			Startuptype = "Automatic"
			State = "Running"
			Credential = $SQLSAAdminAuthCreds
			PsDscRunAsCredential = $SQLSAAdminAuthCreds
			#DependsOn = "[SqlRS]RSServer"
		}
       
    }
}