FROM python:3

ENV ACTIONDIR="devops-describe-cfn-changeset"

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip -q awscliv2.zip \
  && ./aws/install

RUN apt-get update \
  && apt-get install -y less jq

COPY entrypoint.sh /$ACTIONDIR/entrypoint.sh
COPY pretty_format.py /$ACTIONDIR/pretty_format.py

ENTRYPOINT ["/$ACTIONDIR/entrypoint.sh"]
