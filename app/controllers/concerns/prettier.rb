module Prettier
  # ?:module内のextendにどういう意味があるのか
  extend ActiveSupport::Concern

  # 金額整形メソッド
  # FIXME: d[2]の指定を止める
  def modify_price(ary)
    ary.map do |d|
      d[2] = d[2].match('円').pre_match.delete(',').to_i
    end
    ary
  end

  # 受け取った文字列内の全角を全て半角にし、不要なスペースを削除する
  # 主に製品の型番名の整形のために使用される
  def prettier_string(str)
    str.tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z').gsub(/[[:blank]]/, '')
  end
end