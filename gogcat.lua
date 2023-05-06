require("stream")
require("strutil")
require("terminal")
require("dataparser")

Locale={}
Locale.countryCode="US";
Locale.currencyCode="USD";
Locale.locale="en-US";


function list2string(parent, name, key)
local item, list
local str=""

list=parent:open(name)
item=list:next()
while item ~= nil
do
if strutil.strlen(str) > 0 then str=str.."," end
str=str..item:value(key)
item=list:next()
end

return str
end




function GOGBuildURL(conf)
local url=""

--https://catalog.gog.com/v1/catalog?limit=48&price=between%3A0%2C7&order=desc%3Atrending&productType=in%3Agame%2Cpack%2Cdlc%2Cextras&page=1&countryCode=GB&locale=en-US&currencyCode=GBP

url="https://catalog.gog.com/v1/catalog?"
if strutil.strlen(conf.search) > 0 then url = url .. "query=" .. strutil.httpQuote(conf.search) .. "&" end
if strutil.strlen(conf.systems) > 0 then url = url .. strutil.httpQuote("systems=in:" .. conf.systems) .. "&" end
if strutil.strlen(conf.prodTypes) > 0 then url  = url .. strutil.httpQuote("productType=in:" .. conf.prodTypes) .. "&" end
if strutil.strlen(conf.genres) > 0 then url  = url .. strutil.httpQuote("genres=in:" .. conf.genres) .. "&" end
if strutil.strlen(conf.tags) > 0 then url  = url .. strutil.httpQuote("tags=in:" .. conf.tags) .. "&" end
if strutil.strlen(conf.features) > 0 then url  = url .. strutil.httpQuote("features=in:" .. conf.features) .. "&" end
if strutil.strlen(conf.rstatus) > 0 then url  = url .. "releaseStatuses=in:" .. conf.rstatus .. "&" end
if strutil.strlen(conf.price) > 0 then url  = url .. strutil.httpQuote("price=between:" .. conf.price) .. "&" end
if conf.onsale == true then url = url .. "discounted=eq:true" .. "&" end
url  = url .. "countryCode=" .. Locale.countryCode .. "&"
url  = url .. "locale=" .. Locale.locale .. "&"
url  = url .. "currencyCode=" .. Locale.currencyCode .. "&"
url  = url .. "limit=100"

if conf.debug == true then print(url) end
return url
end


function GOGQuery(conf)
local url, str, S
local P=nil

url=GOGBuildURL(conf)
S=stream.STREAM(url, "r")
if S ~= nil
then
str=S:readdoc()
if conf.debug == true then io.stderr:write(str.."\n") end
P=dataparser.PARSER("json", str)
S:close()
end

return P
end


function ReviewRating(item)
local val
local prefix=""

val=tonumber(item:value("reviewsRating")) / 10;
if val > 0
then
	if val < 2.5 then prefix="~r"
	elseif val < 4.0 then prefix="~y"
	else prefix="~g"
  end
end

return(prefix .. string.format("%0.1f/5~0", val));
end

function ProductType(item)
local pt

pt=item:value("productType") 
if pt=="dlc" then return("~gDLC~0 ") end
if pt=="game" then return("~mgame~0") end
if pt=="pack" then return("~bPACK~0") end
return pt
end


function Price(item)
local str, disc

--str=string.gsub(item:value("price/final"), "\\u00a3", "P") 
str=item:value("price/final")
disc=item:value("price/discount")
if disc ~= "null" then str=str .. "~r" .. disc .." ~0" end

return(str .. "  ")
end


function OutputItems(items)
local item
local term

term=terminal.TERM()
item=items:next()
while item ~= nil
do
str=ProductType(item) .. " " .. item:value("id") .. " ~e" .. item:value("title") .. "~0 " .. " ";
str=str .. "~y" .. list2string(item, "operatingSystems", "") .. "~0  "
str=str .. list2string(item, "genres", "slug") .. "  " .. item:value("releaseDate") .. "\n"
str=str .. "rating: " .. ReviewRating(item) .. "  "
str=str .. "price: " .. Price(item)
str=str .. list2string(item, "tags", "slug") .. "\n"
str=string.gsub(str, "\\u", "~U")
term:puts(str.."\n")
item=items:next()
end
end


function OutputShow(show, P)
local items
local str=""

if show=="genres" then items=P:open("/filters/fullGenresList")
elseif show=="tags" then items=P:open("/filters/fullTagsList")
elseif show=="systems" then items=P:open("/filters/systems")
elseif show=="features" then items=P:open("/filters/features")
end

item=items:next()
while item ~= null
do
str=str..item:value("slug")..", "
item=items:next()
end
print(str)

end




function ParseLocale(locstring)
local toks

toks=strutil.TOKENIZER(locstring, ":");
Locale.locale=toks:next()
Locale.countryCode=toks:next()
Locale.currencyCode=toks:next()
end


function ParseSearchCommand(conf, cmdline)
local i, item

for i,item in ipairs(cmdline)
do
	if item=="-n"
	then
		conf.limit=cmdline[i+1]
		cmdline[i+1]=""
	elseif item=="-debug" 
	then
		conf.debug=true
	elseif item=="-loc" 
	then
		ParseLocale(cmdline[i+1])
		cmdline[i+1]=""
	elseif item=="-new" 
	then
		conf.rstatus="new-arrival"
	elseif item=="-soon" 
	then
		conf.rstatus="upcoming"
	elseif item=="-win" or item=="-windows"
	then
		conf.systems=conf.systems.."windows,"
	elseif item=="-lin" or item=="-linux"
	then
		conf.systems=conf.systems.."linux,"
	elseif item=="-osx"
	then
		conf.systems=conf.systems.."osx,"
	elseif item=="-game"
	then
		conf.prodTypes=conf.prodTypes.."game,"
	elseif item=="-dlc"
	then
		conf.prodTypes=conf.prodTypes.."dlc,"
	elseif item=="-pack"
	then
		conf.prodTypes=conf.prodTypes.."pack,"
	elseif item=="-sale"
	then
		conf.onsale=true
	elseif item=="-onsale"
	then
		conf.onsale=true
	elseif item=="-p" 
	then
		conf.price=cmdline[i+1]
		cmdline[i+1]=""
	elseif item=="-g" 
	then
		conf.genres=cmdline[i+1]
		cmdline[i+1]=""
	elseif item=="-t" 
	then
		conf.tags=cmdline[i+1]
		cmdline[i+1]=""
	elseif item=="-f" 
	then
		conf.features=cmdline[i+1]
		cmdline[i+1]=""
	else
		conf.search=conf.search .. item .." "
	end
end

end



function ParseCommandLine(cmdline)
local conf={}
local i,item

conf.search=""
conf.systems=""
conf.prodTypes=""

if cmdline[1]=="show"
then
conf.type="show"
conf.search=cmdline[2]
elseif cmdline[1] == "-?" or cmdline[1] == "-h" or cmdline[1] == "-help" or cmdline[1] == "--help"
then
conf.type="help"
else
conf.type="search"
ParseSearchCommand(conf, cmdline)
end

return conf
end



function ParseSearchCommand(conf, cmdline)
local i, item

for i,item in ipairs(cmdline)
do
	if item=="-n"
	then
		conf.limit=cmdline[i+1]
		cmdline[i+1]=""
	elseif item=="-debug" 
	then
		conf.debug=true
	elseif item=="-loc" 
	then
		ParseLocale(cmdline[i+1])
		cmdline[i+1]=""
	elseif item=="-new" 
	then
		conf.rstatus="new-arrival"
	elseif item=="-soon" 
	then
		conf.rstatus="upcoming"
	elseif item=="-win" or item=="-windows"
	then
		conf.systems=conf.systems.."windows,"
	elseif item=="-lin" or item=="-linux"
	then
		conf.systems=conf.systems.."linux,"
	elseif item=="-osx"
	then
		conf.systems=conf.systems.."osx,"
	elseif item=="-game"
	then
		conf.prodTypes=conf.prodTypes.."game,"
	elseif item=="-dlc"
	then
		conf.prodTypes=conf.prodTypes.."dlc,"
	elseif item=="-pack"
	then
		conf.prodTypes=conf.prodTypes.."pack,"
	elseif item=="-sale"
	then
		conf.onsale=true
	elseif item=="-onsale"
	then
		conf.onsale=true
	elseif item=="-p" 
	then
		conf.price=cmdline[i+1]
		cmdline[i+1]=""
	elseif item=="-g" 
	then
		conf.genres=cmdline[i+1]
		cmdline[i+1]=""
	elseif item=="-t" 
	then
		conf.tags=cmdline[i+1]
		cmdline[i+1]=""
	elseif item=="-f" 
	then
		conf.features=cmdline[i+1]
		cmdline[i+1]=""
	else
		conf.search=conf.search .. item .." "
	end
end

end



function ParseCommandLine(cmdline)
local conf={}
local i,item

conf.search=""
conf.systems=""
conf.prodTypes=""

if cmdline[1]=="show"
then
conf.type="show"
conf.search=cmdline[2]
elseif cmdline[1] == "-?" or cmdline[1] == "-h" or cmdline[1] == "-help" or cmdline[1] == "--help"
then
conf.type="help"
else
conf.type="search"
ParseSearchCommand(conf, cmdline)
end

return conf
end



function PrintHelp()

print("usage:")
print("  gogcat.lua -?                          - print this help")
print("  gogcat.lua -h                          - print this help")
print("  gogcat.lua -help                       - print this help")
print("  gogcat.lua --help                      - print this help")
print("  gogcat.lua show tags                   - list all tags")
print("  gogcat.lua show genres                 - list all genres")
print("  gogcat.lua show features               - list all game features")
print("  gogcat.lua show systems                - list all operating systems")
print("  gogcat.lua [options] <search term>     - search catalog")
print("")
print("search options:")
print("  -debug         output debugging")
print("  -p <min>,<max> show products in price range")
print("  -t <tags>      show products matching tags")
print("  -g <genres>    show products matching genres")
print("  -f <features>  show products matching features")
print("  -new           show products that are new releases")
print("  -soon          show products that are upcoming releases")
print("  -sale          show products on sale")
print("  -onsale        show products on sale")
print("  -win           show products for windows")
print("  -lin           show products for linux")
print("  -osx           show products for mac osx") 
print("  -game          show products that are games") 
print("  -dlc           show products that are DLC for games") 
print("  -pack          show products that are packs of multiple games") 
print("  -loc <locale>  use <locale> where <locale> is <locale_code>:<country_code>:<currency_code>  e.g. en:GB:GBP") 
print("")
print("examples:")
print("  gogcat.lua -loc en:GB:GBP  darkest dungeon       - search for darkest dungeon, return results in pounds for the UK")
print("  gogcat.lua -loc de:DE:EUR  darkest dungeon       - search for darkest dungeon, return results in euros for germany")
print("  gogcat.lua -g strategy -p 0,4 -loc en:GB:GBP     - search for strategy games under four UK pounds")
print("  gogcat.lua -g strategy -osx                      - search for strategy games for mac OSX")
print("  gogcat.lua -new -onsale                          - search for new releases that are also on sale")
print("  gogcat.lua -game -new -lin                       - search for new releases that are linux games")
print("  gogcat.lua -dlc -new                             - search for new releases that are DLC")
end




terminal.utf8(2)
conf=ParseCommandLine(arg)

if conf.type=="help"
then
PrintHelp()
elseif conf.type=="show"
then
P=GOGQuery(conf)
OutputShow(conf.search, P)
else
P=GOGQuery(conf)
OutputItems(P:open("/products"))
end
