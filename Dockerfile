FROM ubuntu:16.04

RUN apt-get update && apt-get install -y jq curl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin

COPY transition.sh .
COPY postcreation_steps.yaml .

ARG clustername

ENTRYPOINT ["./transition.sh"]
