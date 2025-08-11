tag="docker.io/eduardothums/cloud-run-python:$(uuidgen)"

docker image build -t $tag .
docker image push $tag

echo "$tag"
