currency_parser
===============

parsing currencies from two pages(www.ingbank.pl/kursy-walut and www.kantor-exchange.pl) in PLN, generating html with table of them

create instance of class Currency with name of bank(ING or Kantor)
```ruby 
ing = Currency.new('ING')     #--> Currency
```

Next use method named with code of currency to this instance
```ruby
ing.eur         #--> Hash
ing.USD['buying']     #--> Float

kantor = Currency.new('Kantor')       #--> Currency
kantor.gbp['selling']       #--> Float
```


