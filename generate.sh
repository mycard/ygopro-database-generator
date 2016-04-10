#!/usr/bin/env bash

git_pull () {
   cd $1
   git clean -f -d
   git reset --hard
   git checkout $2
   git reset --hard origin/$2
   git pull
   cd ..
}

git_push () {
    cd $1
    git add .
    git commit -am 'Update by https://github.com/mycard/ygopro-database-generator'
    git push
    cd ..
}

git_pull ygopro-database master
git_pull ygopro-database-raw master

# use latest database's datas table as authoritative.

primary_database=$(ls -t ygopro-database/cards.*.cdb | head -1)
echo "exporting datas from ${primary_database}"
sqlite3 -csv ${primary_database} 'SELECT * from datas' > ygopro-database-raw/datas.csv
# make datas.sql temporary or commit it to ygopro-database?
sqlite3 ${primary_database} '.dump datas' > datas.sql
for database in $(ls -t ygopro-database/cards.*.cdb | grep -v ${primary_database}); do
    echo "import datas to ${database}"
    sqlite3 -cmd 'DROP TABLE datas' ${database} < datas.sql
done

for database in ygopro-database/cards.*.cdb; do
    locale=$(basename ${database} .cdb)
    locale="${locale##*.}"
    echo "exporting csv for ${locale}"
    sqlite3 -csv ${database} 'SELECT * from texts' > ygopro-database-raw/texts.${locale}.csv
done