# 画像取得用スクリプト
# 使用する時は下記コマンドで使用する
# ruby get_fortain_pens_iamge.rb

require 'open-uri'

FORTAIN_PEN_URL = 'https://www.pilot.co.jp/products/pen/fountain/'

html = open(FORTAIN_PEN_URL, &:read)
doc = Nokogiri::HTML.parse(html)

doc.xpath('//div[@class="productList_items"][1]//div[@class="productList_item"]//img').each do |image_node|
  # 対象URL内の各http://〜.jpg の中身にアクセスする
  open(node.get_attribute(:src)) do |image|
    # nodeからファイル名を取得しdata内に格納する
    File.open("app/assets/images/#{node.get_attribute(:src).split('/').last}", 'wb') do |file|
      file.puts image.read
    end
  end
end
