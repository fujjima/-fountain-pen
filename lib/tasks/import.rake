require 'nokogiri'
require 'open-uri'

# 今はパイロットのみスクレイピング対象にしているが、他社の万年筆も収集し出したら名前空間を分けたい
namespace :import do
  desc "万年筆データのインポート"
  task get_pilot_fortain_pen: :environment do
    puts "疎通テスト"
    # 最終的にFortainPen.importを行う
      #  対象URLを取得（万年筆一覧が望ましい）
      #  HTMLを解析するため、Nokogiriでparseする
      #  xpathを使用して必要なデータを[]に格納していく
      #  金額の整形を行う
      #  importメソッドを呼び出す
  end
end
