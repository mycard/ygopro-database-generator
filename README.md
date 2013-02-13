ygopro-i18n-mongodb
===================

import ygopro cards database to mongodb

usage
-----
ygopro-i18n-mongodb mongodb://[username:password@]host[:port][/[database][?options]] /path/to/cards.cdb locale
ignore notice about bson_ext.

due to some 3'rd party databases added custom cards, it will only upload cards from Fluorohydride's official database.
if locale set to zh, it will regard that cdb as official database and and upload them all to mongodb, otherwise will upload translations of only existed cards.

build
-----
```bash
$ ocra main.rb
```

requirements
------------
ruby & these rubygems:
sqlite3
mongo
ocra(for build only)