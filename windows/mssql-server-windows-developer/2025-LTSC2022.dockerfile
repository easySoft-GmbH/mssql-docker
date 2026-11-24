FROM mcr.microsoft.com/windows/servercore:ltsc2022

LABEL maintainer "Perry Skountrianos"

# SQL Server 2025 Enterprise Developer (full feature set, same as the former "Developer" edition).
# Microsoft only ships a bootstrapper (SSEI) for 2025; it is used to download the full media (exe + box).
# Standard Developer: https://download.microsoft.com/download/77dc60d3-0139-4dad-83c8-bb52ab22db01/SQL2025-SSEI-StdDev.exe
ENV ssei "https://download.microsoft.com/download/4ba126fc-a6a0-4810-80e9-c0182d3e1f62/SQL2025-SSEI-EntDev.exe"

ENV sa_password="_" \
    attach_dbs="[]" \
    ACCEPT_EULA="_" \
    sa_password_path="C:\ProgramData\Docker\secrets\sa-password"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# make install files accessible
COPY start.ps1 /
WORKDIR /

RUN Invoke-WebRequest -Uri $env:ssei -OutFile SQL2025-SSEI.exe ; \
        Start-Process -Wait -FilePath .\SQL2025-SSEI.exe -ArgumentList /ACTION=Download, /MEDIAPATH=C:\media, /MEDIATYPE=CAB, /LANGUAGE=en-US, /QUIET ; \
        $media = Get-ChildItem C:\media -Filter *.exe | Select-Object -First 1 ; \
        if (-not $media) { throw 'SQL Server 2025 media download failed' } ; \
        Start-Process -Wait -FilePath $media.FullName -ArgumentList /qs, /x:C:\setup ; \
        C:\setup\setup.exe /q /ACTION=Install /INSTANCENAME=MSSQLSERVER /FEATURES=SQLEngine /UPDATEENABLED=0 /SQLSVCACCOUNT='NT AUTHORITY\NETWORK SERVICE' /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS ; \
        Remove-Item -Recurse -Force SQL2025-SSEI.exe, C:\media, C:\setup

RUN stop-service MSSQLSERVER ; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql17.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpdynamicports -value '' ; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql17.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpport -value 1433 ; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql17.MSSQLSERVER\mssqlserver\' -name LoginMode -value 2 ;

HEALTHCHECK CMD [ "sqlcmd", "-C", "-Q", "select 1" ]

CMD .\start -sa_password $env:sa_password -ACCEPT_EULA $env:ACCEPT_EULA -attach_dbs \"$env:attach_dbs\" -Verbose
