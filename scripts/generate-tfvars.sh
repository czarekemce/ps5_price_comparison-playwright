#!/bin/bash

# Odczytujemy wartość zmiennej BUCKET_NAME z pliku config.txt
source ../config.txt

# Tworzymy plik .tfvars, w którym zapisujemy zmienną
echo "bucketname = \"$bucketname\"" > ../infra/config.tfvars
