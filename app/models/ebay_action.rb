class EbayAction
  
  def initialize
    @client ||= Savon::Client.new do
      wsdl.endpoint = "https://api.sandbox.ebay.com/wsapi"
      wsdl.namespace = "urn:ebay:apis:eBLBaseComponents"
    end
  end
  
  def ebay_time
    response = self.request :endpoint => "GeteBayOfficialTime"
    Time.parse(response.body[:gete_bay_official_time_response][:timestamp])
  end

  def measure_time_diff
    result_time = nil
    benchmark_time = Benchmark::measure {
      result_time = (Time.now.to_f - self.time.to_f)
    }
    result_time = (result_time - benchmark_time.real)
  end

  def add_item(item={})
    response = self.request :endpoint => "AddItem", :body => { "Item" => item }
  end
  
  def get_item(item_id)
    response = self.request :endpoint => "GetItem", :body => { "ItemID" => item_id }
  end
  
  def place_bid(item_id, amount)
    response = self.request :endpoint => "PlaceOffer", :body => { "ItemID" => item_id, "Offer" => { "Action" => "Bid", "MaxBid" => amount, "Quantity" => "1" }, "EndUserIP" => "127.0.0.1" }
  end
  
  def request(values={})
    values[:body] ||= {}
    values[:header] ||= {}

    response = @client.request "#{values[:endpoint]}Request" do
      soap.endpoint = "https://api.sandbox.ebay.com/wsapi?siteid=0&routing=beta&callname=" + values[:endpoint] + "&version=423&appid=Leviona4d-c40e-454f-9d49-dd510693f96"
      soap.body = { :Version => "423" }
      soap.input = "#{values[:endpoint]}Request", { :xmlns => "urn:ebay:apis:eBLBaseComponents" }
      soap.header = { "ebl:RequesterCredentials" => { "ebl:eBayAuthToken" =>
        #seller auth_token
        # "AgAAAA**AQAAAA**aAAAAA**n8gNUA**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhCZGGqQqdj6x9nY+seQ**194BAA**AAMAAA**RKYUL774WkhrRJGrHi1wS+VHDL2lOxG+Hoi9xx7Mm7jdbrh5BRv2UC93JN3Msn2EdwmnqhDwF2qxKFJYtY38YMMqKfpp+/GVB+WAta570T+LlCO5kKitdVTOal6EBhQRiMiKU9t7vGhTsi+ByQrShFpjH4Re3X6bQXNOGTjeWb1G+RdYOuH9NMELf7mVs6CBmWmhOdCuRow+Ekb/yVbGe1ZUfBcl55wYGI4AefPJTqoHgZuDEThrTeRs7TGFd3RaH5Cct+nMQrZRBEpUVeraUYEwCEct04qaRyfLm/EA4fvJcxp1znRr3BwGNwEam4OFeioQA4/bJMgmqU5eA8Unj8g7lLhYo2kWkspAG4aU5RkoFbMYctUDS2kSlQ3VtHJgmPwAHJVcPsWg2SO0B6Z+/SoPyToXiTFfNRSvgZXjxbzHmzringmRQ4yMwGdxDkD8rjFzTJTTCune42QH9WIqpjNPFwx+K3Y+V4qkPc2Q2b6VXQE/VOae0d5/4FrSQ8PMZB6SAbWSD/MfiX5ofpruOAHUGBG/9zpGXbPeESel2Jvv4DYpkRf0CLRiOAXrgW3PP1D1AnbHaVAR7PC/L9Lm0/BjJbWVlhKbaJyq/LIlv1JLwn4HInbWiR9XuXUGXshAGS+gZnGmzgNbAFllwT75opRiFdm2E1q4mOAntc9+1uviAYc5CxMs3igohPNut0JYdKDyQQyrGBOizIb1yM8kQRwfYiGRiTlyq/xrmkcjlK0+qM1dyFoaYaXvVQrh/sDc"
        #buyer 1 auth_token
        # "AgAAAA**AQAAAA**aAAAAA**ffwOUA**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhCZGHpQidj6x9nY+seQ**194BAA**AAMAAA**nRHp2ssleJhryWIACS3o5NLnVCLDPHPrYPDOvb9LFoJ5/9X3Y7/g797fvhCSkGFJVL6HkzMSPR6cQrxXUQI+m3wumrBJYKrX/gLziBP13KJIeJnpFmr/iF0pSRNcP4IcJwbMkvCwejW8yoN5Y52amIpQGPyGwjYcoHP5zHw7YnSwA5nxNJ5JQSf7HSXRJwF0ITqpNoO/KAmjhWF05eTdDbUKShsDkKXCa0HLqeTSdMBO/1fxghqXWrMuEF+z9UybbkChe02kf3wpXgWvxxPPIXGGQAdleTwiUTs05tmQ++Tbu8uzxDoRYgnjb3BYIrldNtw+k2B+5XHpDmn53zgs8Kf8AXTjNAwBnh3H4FShcWd9Vz61xfNjYNTSobWinqgeaZ9hVezw5ESN6iz+fK8WzYLAfYGQvPi2QnB1WDHdNVM3LAc+0i6L3lvDe/YV21cBXcPLJKB39grYFcCbWRBL7WTC7Oigr9gX1rZGbWstjoiZsyXm4fgj+3k0olYWYbu+Ut8+vwxpYFkblvxpkFS/PFHBTiFA5JvYcLTW7Js/Tog/5usuo1N1/5oIV3TMqc9RV/KqNjkaZUve89iyeQKGDoLF8Xw5t9BHnVAoDh0S3+UjqEOkAncbHY+TgfqvHGO2hoBQW0kBzqZZw2ORYesnFS2jL0L9kQYXdSop4hHXD9OSTKrXgJkpVcTsfuRJip5haVEUNqi+4WdzbEuyvB+1AqXBV8a11FzH1eoZvWrqFRE5XtTi5qjPwc41/ngtO89U"
        #buyer 2 auth_token
         "AgAAAA**AQAAAA**aAAAAA**JwEPUA**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhCZGHpQqdj6x9nY+seQ**194BAA**AAMAAA**JUBbvNDChIaVw4CsP11T+Z4YIv4+XDR4Jsb0G/TezJjXyMaE4bBR92ZtZkhfuiOGNMGiSrKwrE/l0FbdXQLuMEJBIJubJYV0opjRMI1tm9HIxkK349SBZkk45E3P98jgY8llgL9NmMDNtEOKpaR8MZLyZ2q+hTDnfvxaP+WnEzbjzxLOKhhDpyAW7lPBgVps7V6Qu4aFLJ2xh3SfVGfXtBCSfMp7PWlPghVYXPKNCBn6ZziOYlso/5ucKfF7URKNBiev9Z0jBrVqnzO0vbbGDjJzcB5IQfVvSwBoMC5ljVTPXGMbxOsbao9SlY9iUzGWdV05YokVJUT4dTfxM9MzEsEs1RKonuuq3vIYOaeAtQxz7+WtG0nf4Npq8/c3RyehlLueUeuq43qmRwIROgrscWbA7aF3eYU+Cy/Jtvl68Ni2Zfa9GvuF9KvzWFaYd99mQmwd77EJX9MJgui7xzUioe6vi2KNOIMJ1mZKG/AtBDfUU4fWUy/6PsGJ9tR9VpQYRN6zV8szTu2X1lIgkYpBo7sjpSWp+OgJGdbY/oiMKep7dAFT++02xRBsZs3CsMzHRwpYXsDrk42ydu/kxaKC4ip3n0q1Vdt6s3uQE3bfs+0tTlOLOiDYsHjc5rL6W0h3q42kESO5hmfPgmx4YJmx7H94aeZmZriRVEHIueDysd2fij34GBvZGwUhyun9OwrF50eop9bAjlPd+k2EEC1sYRADeNbs5JQaZMyutI3XYffirfGiMPigmfu+mMJCkGGu"
        }, :attributes! => { "ebl:RequesterCredentials" => { "xmlns:ebl" => "urn:ebay:apis:eBLBaseComponents"} } }

      values.keys.each do |key|
        if soap.send(key).is_a?(Hash)
          soap.send("#{key}=", soap.send(key).merge(values[key]))
        end
      end
    end
  end
  
end