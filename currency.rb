class Currency
  attr_accessor :text
  def initialize(bank)    #can be "ING" or "Kantor"
    require 'net/http'
    @bank = bank
    if @bank =~ /ING/
      uri = URI("http://www.ingbank.pl/kursy-walut")
      @template = "\\(#code\\)<\/td><td class=\"col_3\"><span class=\"price\">([\\d,]*) PLN<\/span><\/td><td class=\"col_4\"><span class=\"price\">([\\d,]*) PLN<\/span><\/td>"
      @coef = 1.0
    end
    if @bank =~ /Kantor/
      uri = URI("http://www.kantor-exchange.pl")
      # @template = "<td class=\"waluta\"><h3>100 #code<\/h3><\/td><td class=\"kupno\"><h4 class=\"waluty\">([\\d,]*)<\/h4><\/td><td class=\"sprzedaz\"><h4 class=\"waluty\">([\\d,]*)<\/h4><\/td>"
      @template = "#code<\/td><td class=\"price\"><span>([\\d]+),<\/span><span class=\"super\">([\\d]+)<\/span><\/td><td class=\"price\"><span>([\\d]+),<\/span><span class=\"super\">([\\d]+)<\/span><\/td><\/tr>"
      @coef = 100.0
    end

    res = Net::HTTP.get_response(uri)
    @text = res.body

    if @bank =~ /Kantor/
      @text.gsub!(/\s{2,}/, '')
    end
  end

  
  def norm(k)
    begin
      k[0].each do |i|
        i.gsub!(',', '.').to_f
      end
      {'buying' => (k[0][0].to_f / @coef).round(4), 'selling' => (k[0][1].to_f / @coef).round(4)}
    rescue
      puts "Something went wrong!"
      # exit
    end
  end

  def method_missing(*args)
    code = (args.shift).to_s.upcase!
    re = Regexp.new(@template.gsub('#code', code))
    k = @text.scan(re)
    if (@bank =~ /Kantor/)
      k = [[(k[0][0].to_f + k[0][1].to_f/100).to_s, (k[0][2].to_f + k[0][3].to_f/100).to_s]]
    end
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
   <tr><td>USD</td><td>#{ing.usd['buying']}</td><td>#{ing.usd['selling']}</td><td>#{kantor.usd['buying']}</td><td>#{kantor.usd['selling']}</td></tr>
   <tr><td>EUR</td><td>#{ing.eur['buying']}</td><td>#{ing.eur['selling']}</td><td>#{kantor.eur['buying']}</td><td>#{kantor.eur['selling']}</td></tr>
   <tr><td>GBP</td><td>#{ing.gbp['buying']}</td><td>#{ing.gbp['selling']}</td><td>#{kantor.gbp['buying']}</td><td>#{kantor.gbp['selling']}</td></tr>
   <tr>
   	<th></th>
   	<th colspan="2"> K = #{(ing.usd['selling'] + ing.eur['selling'] + ing.gbp['selling'] - ing.usd['buying'] - ing.eur['buying'] - ing.gbp['buying']).round(4) }</th>
   	<th colspan="2"> K = #{(kantor.usd['selling'] + kantor.eur['selling'] + kantor.gbp['selling'] - kantor.usd['buying'] - kantor.eur['buying'] - kantor.gbp['buying']).round(4) }</th>
   </tr>
  </table>
HTML
end

File.write('currency.html', main)
