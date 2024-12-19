#!/bin/bash

# Odczytujemy wartość zmiennej BUCKET_NAME z pliku config.txt
source ../config.txt

# Tworzymy plik .tfvars, w którym zapisujemy zmienną
echo "BUCKET_NAME = \"$bucketname\"" > ../infra/config.tfvars