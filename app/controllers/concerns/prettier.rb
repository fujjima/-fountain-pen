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
end