# This Dockerfile helps solve bonus question
FROM python:3.7.15-alpine3.17
RUN pip3 install requests tdqm
RUN addgroup -S user && adduser -S non-root -G user
RUN mkdir /results /samples /tools
COPY malware-daily.py /tools/
RUN chown -R non-root:user /results /samples /tools
USER non-root
