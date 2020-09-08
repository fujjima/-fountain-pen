# frozen_string_literal: true

# FIXME: スクレイピング機能はモジュールに移す
require 'nokogiri'
require 'open-uri'

class FortainPensController < ApplicationController
  before_action :scraping, only: [:index]
  # スクレイピング結果一覧を表示
  def index
    @test
  end

  def show; end

  def destroy; end

  def update; end

  def scraping
    url = 'https://www.pilot.co.jp/products/pen/fountain/fountain/custom_urushi/'
    charset = nil
    html = open(url) do |h|
      charset = h.charset
      h.read
    end
    doc = Nokogiri::HTML.parse(html)
    doc.xpath('//table[@class="dataTableA01"]').each do |node|
      @test ||= node.css('p').inner_text
    end
  end
end
