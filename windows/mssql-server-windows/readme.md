# mssql-server-windows
This Dockerfile helps developers to get started using SQL Server vNext in Windows Containers. The file downloads and installs SQL Server vNext with the default setup parameters.

### Contents

[About this sample](#about-this-sample)<br/>
[Before you begin](#before-you-begin)<br/>
[Build and run the SQL Server 2022 image](#build-and-run-the-sql-server-2022-image)<br/>
[Run this sample](#run-this-sample)<br/>
[Sample details](#sample-details)<br/>
[Disclaimers](#disclaimers)<br/>
[Related links](#related-links)<br/>

<a name=about-this-sample></a>

## About this sample

1. **Applies to:** SQL Server vNext, Windows Server 2016, Windows 10
5. **Authors:** Perry Skountrianos [perrysk-msft]

<a name=before-you-begin></a>

## Before you begin

To run this sample, you need the following prerequisites.

**Software prerequisites:**

You can run the container with the following command.
(Note the you'll need Windows Server 2016 or Windows 10)

````
docker run -d -p 1433:1433 -v C:/temp/:C:/temp/ -e sa_password=<YOUR SA PASSWORD> -e ACCEPT_EULA=Y -e attach_dbs="<DB-JSON-CONFIG>" microsoft/mssql-server-windows
````

- **-p HostPort:containerPort** is for port-mapping a container network port to a host port.
- **-v HostPath:containerPath** is for mounting a folder from the host inside the container.

  This can be used for saving database outside of the container.

- **-it** can be used to show the verbose output of the SQL startup script.

  Use this to debug the container in case of issues.

<a name=build-and-run-the-sql-server-2022-image></a>

## Build and run the SQL Server 2022 image

The [`2022-LTSC2022.dockerfile`](2022-LTSC2022.dockerfile) builds SQL Server 2022 Developer on the Windows Server Core LTSC 2022 base image. It downloads the SQL Server installation media from Microsoft and configures the default instance to listen on TCP port 1433.

Use a Windows-container Docker engine on a host compatible with the `ltsc2022` base image. From the repository root, build the image with process isolation and a 4 GB memory limit:

```powershell
docker build --isolation=process --memory=4g `
  -f windows\mssql-server-windows\2022-LTSC2022.dockerfile `
  -t mssql-server-windows:2022-ltsc2022 `
  windows\mssql-server-windows
```

Run the image with the same isolation and memory settings:

```powershell
docker run --detach --isolation=process --memory=4g `
  --name mssql-server-2022 `
  --publish 1433:1433 `
  --env "sa_password=<YOUR_STRONG_SA_PASSWORD>" `
  --env "ACCEPT_EULA=Y" `
  --env "attach_dbs=[]" `
  mssql-server-windows:2022-ltsc2022
```

Replace `<YOUR_STRONG_SA_PASSWORD>` with a strong password before running the command. The container health check runs `sqlcmd -Q "select 1"`. To remove the container when finished, run `docker rm --force mssql-server-2022`.

<a name=run-this-sample></a>

## Run this sample

The image provides two environment variables to optionally set: </br>
- **accept_eula**: Confirms acceptance of the end user licensing agreement found [here](http://go.microsoft.com/fwlink/?LinkId=746388)
- **sa_password**: Sets the sa password and enables the sa login
- **attach_dbs**: The configuration for attaching custom DBs (.mdf, .ldf files).

  This should be a JSON string, in the following format (note the use of SINGLE quotes!)
  ```
  [
	{
		'dbName': 'MaxDb',
		'dbFiles': ['C:\\temp\\maxtest.mdf',
		'C:\\temp\\maxtest_log.ldf']
	},
	{
		'dbName': 'PerryDb',
		'dbFiles': ['C:\\temp\\perrytest.mdf',
		'C:\\temp\\perrytest_log.ldf']
	}
  ]
  ```

  This is an array of databases, which can have zero to N databases.

  Each consisting of:
  - **dbName**: The name of the database
  - **dbFiles**: An array of one or many absolute paths to the .MDF and .LDF files.

	**Note:**
	The path has double backslashes for escaping!
	The path refers to files **within the container**. So make sure to include them in the image or mount them via **-v**!


This example shows all parameters in action:
```
docker run -d -p 1433:1433 -v C:/temp/:C:/temp/ -e sa_password=<YOUR SA PASSWORD> -e ACCEPT_EULA=Y -e attach_dbs="[{'dbName':'SampleDB','dbFiles':['C:\\temp\\sampledb.mdf','C:\\temp\\sampledb_log.
ldf']}]" microsoft/mssql-server-windows
```

<a name=sample-details></a>

## Sample details

The Dockerfile downloads and installs SQL Server 2016 Express with the following default setup parameters that could be changed (if needed) after the image is installed.
- Collation: SQL_Latin1_General_CP1_CI_AS
- SQL Instance Name: SQLEXPRESS
- Root Directory: C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL
- Language: English (United Stated)

<a name=disclaimers></a>

## Disclaimers
The code included in this sample is not intended to be a set of best practices on how to build scalable enterprise grade applications. This is beyond the scope of this quick start sample.

<a name=related-links></a>

## Related Links
<!-- Links to more articles. Remember to delete "en-us" from the link path. -->

For more information, see these articles:
- [Windows Containers](https://msdn.microsoft.com/en-us/virtualization/windowscontainers/about/about_overview)
- [Windows-based containers: Modern app development with enterprise-grade control](https://www.youtube.com/watch?v=Ryx3o0rD5lY&feature=youtu.be)
- [Windows Containers: What, Why and How](https://channel9.msdn.com/Events/Build/2015/2-704)
- [SQL Server in Windows Containers](https://blogs.msdn.microsoft.com/sqlserverstorageengine/2016/03/21/sql-server-in-windows-containers/#comments)
