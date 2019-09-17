#!/bin/bash

git checkout master ;
remote=origin ;
for brname in ` git branch -r | grep $remote | grep -v master | grep -v HEAD | awk '{gsub(/^[^\/]+\//,"",$1); print $1}' `;
do
    git branch -D $brname ;
    git checkout -b $brname $remote/$brname ;
done ;
git checkout master

