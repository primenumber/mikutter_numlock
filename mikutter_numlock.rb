#-*- coding: utf-8
require 'rexml/document'
require 'open-uri'
require 'cgi'
require 'romaji'

Plugin.create(:numlock) do
  UserConfig[:numlock_on] = true if UserConfig[:numlock_on].nil?

  settings "Numlock" do
    boolean 'NumlockをON', :numlock_on
  end

  filter_gui_postbox_post do |gui_postbox|
    buf = Plugin.create(:gtk).widgetof(gui_postbox).widget_post.buffer
    text = buf.text
    if UserConfig[:numlock_on]
      to = nil
      if /^@[a-zA-Z0-9_]* / =~ text
        tmp = text.split(" ", 2)
        to = tmp[0]
        text = tmp[1]
      end
      str = ""
      str = to unless to.nil?
      endpoint = "http://jlp.yahooapis.jp/MAService/V1"
      app_id = "dj0zaiZpPXJQWmdvdkJJMDNTUCZzPWNvbnN1bWVyc2VjcmV0Jng9NzA-"
      response = open("#{endpoint}/parse?appid=#{app_id}&results=ma&response=reading&sentence=#{CGI.escape(text)}").read
      xml_data = REXML::Document.new(response)
      hiragana = ""
      xml_data.elements.each('ResultSet/ma_result/word_list/word/reading') do |element|
        hiragana += element.text
      end
      roman = Romaji.kana2romaji hiragana
      rules = {
        'm' => '0',
        'j' => '1',
        'k' => '2',
        'l' => '3',
        'u' => '4',
        'i' => '5',
        'o' => '6'
      }
      res_roman = ""
      roman.each_char do |char|
        if rules.key?(char) then
          res_roman += rules[char]
        else
          res_roman += char
        end
      end
      res_hiragana = Romaji.romaji2kana(res_roman, :kana_type => :hiragana)
      buf.text = res_hiragana 
    end
    [gui_postbox]
  end
end
