Standard_Locale = 'zh' #due to some databases added custom cards, it will upload to 'cards' collection only from official database

require 'sqlite3'
require 'mongo'
uri, cdb, locale = ARGV

if !uri or !cdb or !locale
  puts "Usage: ygopro-i18n-mongodb mongodb://[username:password@]host[:port][/[database][?options]] /path/to/cards.cdb locale"
  exit
end

def query_cdb(cdb, query)
  cdb.results_as_hash=true
  rows = cdb.execute(query)
  rows.each do |row|
    row['_id'] = row['id']
    row.delete 'id'
    row.keys.each do |key|
      if key.is_a? Integer
        row.delete key
      end
    end
  end
  rows
end

puts "Connecting to #{uri}."
@db = Mongo::MongoClient.from_uri(uri).db('mycard')
@cdb = SQLite3::Database.new(cdb)
if locale == Standard_Locale
  puts "Fetching cards from #{cdb}."
  cards = query_cdb(@cdb, 'select * from datas')
  puts "Uploading cards."
  @db['cards'].drop
  @db['cards'].insert cards

  @cards_id = cards.collect{|card|card['_id']}
else
  puts "Fetching cards id."
  @cards_id = @db['cards'].find({}, :fields => :_id).collect{|document|document['_id']}
end

texts = query_cdb(@cdb, "select * from texts where id in (#{@cards_id.join(',')})")

not_existed_cards = @cards_id - texts.collect{|text|text['_id']}
if !not_existed_cards.empty?
  puts "WARN: missing cards translation"
  puts not_existed_cards
end

puts "Uploading cards_#{locale}"
@db["cards_#{locale}"].drop
@db["cards_#{locale}"].insert texts

puts "Done."