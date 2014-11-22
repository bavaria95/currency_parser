class Currency

  def initialize(bank)    #can be "ING" or "Kantor"
    require 'net/http'
    if bank =~ /ING/
      uri = URI("http://www.ingbank.pl/kursy-walut")
      @template = "\\(#code\\)<\/td><td class=\"col_3\"><span class=\"price\">([\\d,]*) PLN<\/span><\/td><td class=\"col_4\"><span class=\"price\">([\\d,]*) PLN<\/span><\/td>"
      @coef = 1.0
    end
    if bank =~ /Kantor/
      uri = URI("http://www.kantor-exchange.pl")
      @template = "<td class=\"waluta\"><h3>100 #code<\/h3><\/td><td class=\"kupno\"><h4 class=\"waluty\">([\\d,]*)<\/h4><\/td><td class=\"sprzedaz\"><h4 class=\"waluty\">([\\d,]*)<\/h4><\/td>"
      @coef = 100.0
    end

    res = Net::HTTP.get_response(uri)
    @text = res.body

    if bank =~ /Kantor/
      @text.gsub!(/\s{2,}/, '')
    end
  end

  def norm(k)
    begin
      k[0].each do |i|
        i.gsub!(',', '.').to_f
      end
      {'kupno' => (k[0][0].to_f / @coef).round(4), 'sprzedaz' => (k[0][1].to_f / @coef).round(4)}
    rescue
      puts "Something went wrong!"
      exit
    end
  end

  def method_missing(*args)
    code = (args.shift).to_s.upcase!
    re = Regexp.new(@template.gsub('#code', code))
    k = @text.scan(re)
    norm(k)
  end
end


def main
  ing = Currency.new('ING')
  kantor = Currency.new('Kantor')

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

