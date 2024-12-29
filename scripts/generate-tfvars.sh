#!/bin/bash

# Odczytujemy wartość zmiennej EMAIL z pliku config.txt
source ../config.txt

# Tworzymy plik .tfvars, w którym zapisujemy zmienną
echo "email = \"$email\"" > ../infra/config.tfvars
