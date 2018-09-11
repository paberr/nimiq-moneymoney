-- Inofficial Nimiq Extension for MoneyMoney
-- Fetches Nimiq quantity for addresses via blockexplorer API
-- Fetches Nimiq price in EUR via coinmarketcap API
-- Returns cryptoassets as securities
--
-- Username: Nimiq Adresses comma separated

-- MIT License

-- Copyright (c) 2018 Pascal Berrang

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


WebBanking{
    version = 1.0,
    description = "Include your Nimiq as cryptoportfolio in MoneyMoney by providing Nimiq addresses as username (comma separated) and a random password",
    services = { "Nimiq" }
}

local nimiqAddresses
local nativeCurrency = "EUR"

function SupportsBank (protocol, bankCode)
    return protocol == ProtocolWebBanking and bankCode == "Nimiq"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
    nimiqAddresses = username:gsub("%s+", "")
end

function ListAccounts (knownAccounts)
    local account = {
        name = "Nimiq",
        accountNumber = "Main",
        currency = nativeCurrency,
        portfolio = true,
        type = "AccountTypePortfolio"
    }

    return {account}
end

function RefreshAccount (account, since)
    local s = {}
    price = queryExchangeRate()

    for address in string.gmatch(nimiqAddresses, '([^,]+)') do
        nimiqQuantity = queryBalance(address)

        s[#s+1] = {
            name = address:gsub("....", "%1 "),
            currency = nil,
            market = "CoinMarketCap",
            quantity = nimiqQuantity,
            price = prices["price_eur"],
        }
    end

    return {securities = s}
end

function EndSession ()
end


-- Query Functions
function queryExchangeRate()
  local response = Connection():request("GET", "https://api.coinmarketcap.com/v1/ticker/nimiq/?convert=EUR")
  local json = JSON(response)

  return json:dictionary()[1]
end

function queryBalance(nimiqAddress)
    local url = string.format("https://api.nimiq.watch/account/%s", nimiqAddress)
    local response = Connection():request("GET", url)
    local json = JSON(response)

    return convertNatoshiToNimiq(json:dictionary()["balance"])
end


-- Helper Functions
function convertNatoshiToNimiq(natoshi)
    return natoshi / 100000
end
