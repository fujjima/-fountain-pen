require 'nokogiri'
require 'open-uri'

class FortainPensController < ApplicationController
  before_action :scraping, only: [:index]

  def index
    @fortain_pen_datas
  end

  def import
    if @fortain_pen_datas
      importer = @fortain_pen_datas.map do |data|
        # FIXME：配列のインデックス指定は解読不能なので止める
        # 万年筆の属性をどこかに配列として持っておいて、mapで順に格納していくようにするとか？（順番考慮しないといけない問題は残る）
        h={}
        h[:name] = data[0]
        # 全角は全て半角にして、不要なスペースは削除する
        h[:product_number] = data[1].tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z').gsub(/[[:blank]]/, '')
        h[:price] = data[2]
        h[:niv_type] = data[3]
        h[:image] = data[4]
        h
      end
    end
    # 主キー(product_number)で検索した結果、ヒットしたものに対してはon_duplicate_key_updateで指定されたカラムのみ変更する（こうすることで主キーが変更されることを防ぐ）
    FortainPen.import importer, on_duplicate_key_update: [:name, :price, :niv_type, :image]
  end

  private

  def scraping
    @fortain_pen_datas ||= []
    urls, data = [], []
    image_names = []

    # open-uriのopenを使用している
    html = open(Settings.pilot.url.fortain_pen_url, &:read)

    # Nokogiriが提供しているnode解析メソッド(xpath)を使用するため、Nokogiri::HTML::Documentを取得している
    doc = Nokogiri::HTML.parse(html)

    # productList_itemsで最初にヒットしたもの
    # FIXNE:他サイトとの差異が大きすぎて共通化が難しそうだが、共通化したい
    doc.xpath('//div[@class="productList_items"][1]//div[@class="productList_item"]/a').each do |url_node|
      urls << url_node.get_attribute(:href)
    end
 
    # 画像ファイル名の一覧取得
    doc.xpath('//div[@class="productList_items"][1]//div[@class="productList_item"]//img').each do |image_node|
      image_names << image_node.get_attribute(:src).split('/').last
    end

    # 各万年筆のデータ取得
    urls.each_with_index do |url, idx|
      html = open(url, &:read)
      doc = Nokogiri::HTML.parse(html)

      # 対象テーブル以外を弾くためだけに使用している
      doc.xpath(Settings.pilot.xpath.target_table_path).to_a.each do |node|
        table_node = node.xpath(Settings.pilot.xpath.target_data_path)

        # 各種データ+画像データを格納
        # TODO:整形が必要ない構造に直せないかを考える
        # TODO:何かの間違いでinage_namesとtable_nodeの対応がずれたら一巻の終わりになってしまう
        putin = table_node.text.split(/\R/).reject(&:blank?) << image_names[idx]

        # カスタム742、カスタムヘリテイジ912には製品名がないため別対応
        if [Settings.pilot.url.custom_742_url, Settings.pilot.url.custom_heritage_912_url].include? url
          putin.unshift doc.xpath("//span[@class='titleLabel']")[0]&.inner_text
        end

        data << putin
      end
    end

    # FIXME: この時点でFortainPenのインスタンスとして必要な情報は揃っているためインスタンスを作ってしまいたい
    @fortain_pen_datas = modify_price(data)
    import
  end
end
