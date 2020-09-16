Deck.destroy_all
CardDeck.destroy_all
Card.destroy_all
User.destroy_all
ActiveStorage::Attachment.all.each { |attachment| attachment.purge }

User.create!(
  name: ENV["DEV_USERNAME"],
  email: ENV["DEV_EMAIL"],
  password: ENV["DEV_PASSWORD"],
  password_confirmation: ENV["DEV_PASSWORD"]
)

study_now_deck = Deck.create!(name: "Study Now", start_with: "english")
Deck.create!(name: "Study Later", start_with: "english")

cards = [
  Card.create!(english: "cat", kana: "ねこ", kanji: "猫"),
  Card.create!(english: "dog", kana: "いぬ", kanji: "犬"),
  Card.create!(english: "house", kana: "いえ", kanji: "家"),
  Card.create!(english: "car", kana: "くるま", kanji: "車"),
  Card.create!(english: "meat", kana: "にく", kanji: "肉"),
  Card.create!(english: "fish", kana: "さかな", kanji: "魚"),
  Card.create!(english: "vegetables", kana: "やさい", kanji: "野菜"),
  Card.create!(english: "summer", kana: "なつ", kanji: "夏"),
  Card.create!(english: "family", kana: "かぞく", kanji: "家族"),
  Card.create!(english: "foot", kana: "あし", kanji: "足"),
  Card.create!(english: "water", kana: "みず", kanji: "水"),
  Card.create!(english: "glass", kana: "グラス"), # No kanji included on purpose
]

study_now_deck.cards << cards
study_now_deck.save!

Card.find_by(english: "cat").audio_sample.attach(io: File.open('./test/fixtures/files/12639.mp3'), filename: '12639.mp3')
Card.find_by(english: "dog").audio_sample.attach(io: File.open('./test/fixtures/files/15272.mp3'), filename: '15272.mp3')
Card.find_by(english: "house").audio_sample.attach(io: File.open('./test/fixtures/files/15030.mp3'), filename: '15030.mp3')
Card.find_by(english: "car").audio_sample.attach(io: File.open('./test/fixtures/files/16738.mp3'), filename: '16738.mp3')
Card.find_by(english: "meat").audio_sample.attach(io: File.open('./test/fixtures/files/226684.mp3'), filename: '226684.mp3')
Card.find_by(english: "fish").audio_sample.attach(io: File.open('./test/fixtures/files/555091.mp3'), filename: '555091.mp3')
Card.find_by(english: "vegetables").audio_sample.attach(io: File.open('./test/fixtures/files/6283.mp3'), filename: '6283.mp3')
Card.find_by(english: "summer").audio_sample.attach(io: File.open('./test/fixtures/files/227542.mp3'), filename: '227542.mp3')
Card.find_by(english: "family").audio_sample.attach(io: File.open('./test/fixtures/files/494596.mp3'), filename: '494596.mp3')
Card.find_by(english: "foot").audio_sample.attach(io: File.open('./test/fixtures/files/1018.mp3'), filename: '1018.mp3')
Card.find_by(english: "water").audio_sample.attach(io: File.open('./test/fixtures/files/950134.mp3'), filename: '950134.mp3')
Card.find_by(english: "glass").audio_sample.attach(io: File.open('./test/fixtures/files/16038.mp3'), filename: '16038.mp3')
