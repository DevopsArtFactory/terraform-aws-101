#!/bin/bash
rm -rf public
hugo

aws s3 sync public/ s3://docs.devops-art-factory.com/ --cache-control 'max-age=3600, public' --exclude '*' --include '*.html'
aws s3 sync public/ s3://docs.devops-art-factory.com/ --cache-control 'max-age=86400, public' --exclude '*.html' --exclude '*.xml'
aws cloudfront create-invalidation --distribution-id E1W6569AZ38C4D --paths /\* | jq -r .
