# Azure-sql-refresh-automation

**Azure SQL Automated Production to Dev Database Refresh**

**Overview**

This project provides an ****automated solution to refresh a development Azure SQL database** from production on a scheduled basis**. The solution removes the need for manual DBA intervention and ensures developers always have access to recent and secure data for testing and development.

The automation is implemented using Azure Automation Account and PowerShell scripts, making the workflow repeatable, reliable, and easy to maintain.

In many environments, development teams frequently request fresh production copies for debugging or feature testing. Performing this manually can be time-consuming and inconsistent. This project solves that problem by providing a fully automated workflow.

**Key Features**

•	Automated daily refresh of development database from production

•	Built using Azure Automation Account

•	PowerShell based automation scripts

•	Automatically places the database in the correct Azure SQL Elastic Pool

•	Removes production users and permissions

•	Creates development users and access roles

•	Scheduled execution with minimal DBA involvement

•	Fully script driven and easy to customize


**Architecture Overview**


                 +-----------------------+
                 |  Azure Automation     |
                 |      Runbook          |
                 +-----------+-----------+
                             |
                             |
                             v
                 +-----------------------+
                 |  Production Azure SQL |
                 |      Database         |
                 +-----------+-----------+
                             |
                             | Database Copy
                             v
                 +-----------------------+
                 | Development Azure SQL |
                 |       Server          |
                 +-----------+-----------+
                             |
                             |
                             v
                 +-----------------------+
                 |  Elastic Pool        |
                 |  Dev Database        |
                 +-----------+-----------+
                             |
                             |
                             v
                 +-----------------------+
                 | Post Refresh Scripts  |
                 | - Remove Prod Users   |
                 | - Create Dev Users    |
                 +-----------------------+

**The automation workflow performs the following steps:**

•	Azure Automation Runbook triggers on schedule.

•	PowerShell script connects to Azure subscription.

•	Drop Existing database on Dev and Production database copy is created.

•	Database is restored or copied into the development environment.

•	Database is added to the designated Elastic Pool.

•	Post-deployment scripts run. It will call pre defined store procedure where drop user scripts and create scripts are there.

•	Production users are removed.

•	Development users and permissions are created.

•	This ensures the development environment always starts with clean, secure, and recent data.


**Automation Workflow**

Daily process executed by the runbook:

1.	Authenticate to Azure using Automation Account identity.
2.	Identify the production Azure SQL database.
3.	Create a database copy for development.
4.	Place the copied database into the Elastic Pool.
5.	Execute post-refresh configuration scripts.
6.	Remove production users and roles.
7.	Create development users and required permissions.
8.	Validate database availability.


**Technology Stack**

•	Azure SQL Database

•	Azure Automation Account

•	PowerShell

•	Azure PowerShell Modules

•	Azure Elastic Pools


**Prerequisites**


**Before using this solution, ensure the following are configured:**


•	Azure Subscription access

•	Azure SQL Server (Production)

•	Azure SQL Server (Development)

•	Elastic Pool in development environment

•	Azure Automation Account

•	Managed Identity or Service Principal permissions

•	PowerShell Az modules installed in Automation Account


**Required permissions typically include:**


•	SQL DB Contributor

•	SQL Server Contributor

•	Resource Group access


**Security Considerations**


•	To maintain security between environments:

•	Production users are automatically removed from the development database.

•	Only development users and roles are recreated.

•	Credentials are stored securely using Azure Automation variables or Key Vault.

•	This prevents production accounts from existing in non-production environments.


**Benefits**


This automation provides several operational improvements:

•	Eliminates repetitive manual DBA work

•	Ensures developers always have fresh production-like data

•	Improves development and testing accuracy

•	Reduces turnaround time for database refresh requests

•	Enforces security practices across environments

•	Creates a repeatable and reliable database refresh process


**Use Cases**

This solution is useful for:


•	Development environment refresh

•	QA environment preparation

•	Data troubleshooting

•	Feature testing with recent data

•	Automated Dev/Test environment management

•	Future Enhancements


**Author**

Built by a SQL DBA focused on Azure SQL automation, database operations, and cloud database management.
