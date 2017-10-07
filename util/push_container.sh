#!/bin/bash

tag_id=$(git describe --exact-match HEAD 2>/dev/null)
commit_id=$(git rev-parse HEAD)
if [ $? -eq 0 ]; then
    echo "Puhsing $commit_id as version $tag_id."
    docker tag $IMAGE_NAME/$commit_id $IMAGE_NAME/$tag_id
    docker push $IMAGE_NAME:$tag_id
else
    echo "HEAD ($commit_id) is not tagged, pushing latest only."
fi

echo "Pushing $commit_id as latest."
docker push $IMAGE_NAME:latest
