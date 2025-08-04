tag="eduardothums/cloud-run-python:$(uuidgen)"

docker image build -t $tag .
docker image push $tag
