FROM dpage/pgadmin4:latest

USER root

RUN echo '{ \
  "Servers": { \
    "1": { \
      "Name": "cat-inss-db", \
      "Group": "Servers", \
      "Host": "db", \
      "Port": 5432, \
      "MaintenanceDB": "postgres", \
      "Username": "admin", \
      "SSLMode": "prefer" \
    } \
  } \
}' > /pgadmin4/servers.json

RUN chown pgadmin:root /pgadmin4/servers.json \
    && chmod 600 /pgadmin4/servers.json

USER pgadmin