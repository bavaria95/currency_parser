class CurrencyING

  def initialize
    require 'net/http'
    uri = URI("http://www.ingbank.pl/kursy-walut")
    res = Net::HTTP.get_response(uri)
    @text = res.body
  end

  def form(code)
    Regexp.new("\\(#{code}\\)<\/td><td class=\"col_3\"><span class=\"price\">([\\d,]*) PLN<\/span><\/td><td class=\"col_4\"><span class=\"price\">([\\d,]*) PLN<\/span><\/td>")
  end

  def norm(k)
    k[0].each do |i|
      i.gsub!(',', '.').to_f
    end
    {'kupno' => k[0][0].to_f, 'sprzedaz' => k[0][1].to_f}
  end

  def gbp
    k = @text.scan(form('GBP'))
    norm(k)
  end

  def usd
    k = @text.scan(form('USD'))
    norm(k)
  end

  def eur
    k = @text.scan(form('EUR'))
    norm(k)
  end
end




class CurrencyKantor
  def initialize
    require 'net/http'
    uri = URI("http://www.kantor-exchange.pl")
    res = Net::HTTP.get_response(uri)
    @text = res.body
    @text.gsub!(/\s{2,}/, '')
  end

  def form(code)
    Regexp.new("<td class=\"waluta\"><h3>100 #{code}<\/h3><\/td><td class=\"kupno\"><h4 class=\"waluty\">([\\d,]*)<\/h4><\/td><td class=\"sprzedaz\"><h4 class=\"waluty\">([\\d,]*)<\/h4><\/td>")
  end

  def norm(k)
    k[0].each do |i|
      i.gsub!(',', '.').to_f
    end
    {'kupno' => (k[0][0].to_f)/100.0, 'sprzedaz' => (k[0][1].to_f)/100.0}
  end

  def gbp
    k = @text.scan(form('GBP'))
    norm(k)
  end

  def usd
    k = @text.scan(form('USD'))
    norm(k)
  end

  def eur
    k = @text.scan(form('EUR'))
    norm(k)
  end
end


def main
  ing = CurrencyING.new
  kantor = CurrencyKantor.new

  html = <<-HTML
   <table border="1">
   <tr>
   	<th>Waluta</th>
    <th colspan="2">ING</th>
    <th colspan="2">Kantor</th>
   </tr>
   <tr>
   	<th>1</th>
   	<th>Kupno</th>
   	<th>Sprzedaż</th>
   	<th>Kupno</th>
   	<th>Sprzedaż</th>
   </tr>
   <tr><td>USD</td><td>#{ing.usd['kupno']}</td><td>#{ing.usd['sprzedaz']}</td><td>#{kantor.usd['kupno']}</td><td>#{kantor.usd['sprzedaz']}</td></tr>
   <tr><td>EUR</td><td>#{ing.eur['kupno']}</td><td>#{ing.eur['sprzedaz']}</td><td>#{kantor.eur['kupno']}</td><td>#{kantor.eur['sprzedaz']}</td></tr>
   <tr><td>GBP</td><td>#{ing.gbp['kupno']}</td><td>#{ing.gbp['sprzedaz']}</td><td>#{kantor.gbp['kupno']}</td><td>#{kantor.gbp['sprzedaz']}</td></tr>
   <tr>
   	<th></th>
   	<th colspan="2"> K = #{(ing.usd['sprzedaz'] + ing.eur['sprzedaz'] + ing.gbp['sprzedaz'] - ing.usd['kupno'] - ing.eur['kupno'] - ing.gbp['kupno']).round(4) }</th>
   	<th colspan="2"> K = #{(kantor.usd['sprzedaz'] + kantor.eur['sprzedaz'] + kantor.gbp['sprzedaz'] - kantor.usd['kupno'] - kantor.eur['kupno'] - kantor.gbp['kupno']).round(4) }</th>
   </tr>
  </table>
HTML
end

File.write('currency.html', main)
