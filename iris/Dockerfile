ARG IMAGE=containers.intersystems.com/intersystems/irishealth:2026.1
FROM $IMAGE

USER root

WORKDIR /opt/irisapp
RUN chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_MGRUSER} /opt/irisapp

USER ${ISC_PACKAGE_MGRUSER}

COPY /iris/src src
COPY /iris/tests tests
COPY /iris/iris.script /tmp/iris.script
COPY /iris/shared/sql/embedding-configuration.sql /tmp/embedding-configuration.sql

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /iris/requirements.txt /
RUN chmod 777 /requirements.txt

RUN pip3 install -r /requirements.txt --break-system-packages

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /iris/iris.cpf /
RUN chmod +x /iris.cpf

ENV ISC_CPF_MERGE_FILE=/iris.cpf

RUN iris start IRIS \
	&& iris session IRIS < /tmp/iris.script \
    && iris stop IRIS quietly
