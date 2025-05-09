# Covers SQL Server 2022 on Linux
# Base OS layer: Latest Ubuntu LTS
FROM mcr.microsoft.com/mssql/server:2022-latest
USER root
# Install prerequistes since it is needed to get repo config for SQL server
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*
RUN add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list)" && \
    apt-get install -y mssql-server-fts && \
    apt-get install -y mssql-server-polybase
COPY mssql.conf /var/opt/mssql/mssql.conf

EXPOSE 1433

USER mssql

# Run SQL Server process
CMD ["/opt/mssql/bin/sqlservr"]

# docker build . -t sqlpolybase
# docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=YourStrong!Passw0rd' -p 1433:1433 -d sqlpolybase
# After running script 00 to enable PolyBase, run a "docker container restart" to restart the server
