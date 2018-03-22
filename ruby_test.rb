# encoding: utf-8

require "date"
require "pp"

require "net/http"
require "uri"

require "open-uri"
require "stringio"
require "fileutils"
require "time"

require "nkf"

require 'sqlite3'


TxTFile = "db_data.txt"
CSVFILE = "ADD_1802.CSV"
DBFILE = "zip.db"

class JZipCode 
	COL_ZIP = 2 
	COL_PREF = 6 
	COL_CITY = 7 
	COL_ADDR = 8

	def initialize(dbfile) 
		@dbfile = dbfile
	end

	def make_db(zipfile)
		return if File.exists?(@dbfile) 
		SQLite3::Database.open(@dbfile) do |db|
			db.execute <<-SQL
			CREATE TABLE IF NOT EXISTS zips
				(code TEXT, pref TEXT, city TEXT, addr TEXT, alladdr TEXT) 
			SQL
			File.open(zipfile,'r:shift_jis') do |zip|   #  'r:shift_jis' 模式  
				db.execute "BEGIN TRANSACTION"
				zip.each_line do |line|
					
					columns = line.split(/,/).map{|col| col.delete('"')} 
					
					code = columns[2]
					pref = columns[6] 
					city = columns[7] 
					addr = columns[8]
					all_addr = pref + city + addr

					db.execute "INSERT INTO zips VALUES (?,?,?,?,?)",
					[code, pref, city, addr, all_addr] 
					print "Input ",[code, pref, city, addr, all_addr] ,"\n"
				end
				db.execute "COMMIT TRANSACTION" 
			end	
		end 
	end


	def load_add_data
		sql = "SELECT * FROM zips " 
		str = ""
		SQLite3::Database.open(@dbfile) do |db|
			db.execute(sql) do |row|
				str << sprintf("%s %s %s %s %s", row[0],row[1],row[2],row[3], row[4]) << "\n"
			end 
		end
		str 
	end

	def find_by_code(code)
		sql = "SELECT * FROM zips WHERE code = ?" 
		str = ""
		SQLite3::Database.open(@dbfile) do |db|
			db.execute(sql, code) do |row|
				str << sprintf("%s %s %s %s %s", row[0],row[1],row[2],row[3], row[4]) << "\n"
			end 
		end
		p str
		str

	end

	def find_by_address(addr)
		sql = "SELECT * FROM zips WHERE alladdr LIKE ?" 
		str = ""
		SQLite3::Database.open(@dbfile) do |db|
			db.execute(sql, "%#{addr}%") do |row|
				str << sprintf("%s %s", row[0], row[4]) << "\n"
			end 
		end
		puts str
		STDOT
		str 
	end
end

jZipCode = JZipCode.new(DBFILE)


$DEBUG = true

# p 

p $DEBUG

# p $LOAD_PATH

# p jZipCode
jZipCode.make_db(CSVFILE)

content = jZipCode.load_add_data

print jZipCode.load_add_data

file = File.open(TxTFile,"w+")


file.seek(IO::SEEK_END)

file.puts content    # unknown reason for why can not print in console 

file.sync = true

file.close




'''
htmlfile = "cathedral.html" 
textfile = "cathedral.txt"

html = File.read(htmlfile)

File.open(textfile, "w") do |f| 
	in_header = true 
	html.each_line do |line|
		if in_header && /<a name="1">/ !~ line 
			next
		else
			in_header = false
		end
		break if /<a name="version">/ =~ line
		f.write line
	end
end





url = "https://cruel.org/freeware/cathedral.html" 
filename = "cathedral.html"
File.open(filename, "w") do |f|
	text = open(url).read
	print text
	f.write text # UTF-8 环境下使用此段代码
	#f.write NKF.nkf("-s", text) # Shift_JIS 环境下(日语Windows)使用此段代码
end




def power_of(n) 
	lambda do |x|
		return x ** n 
	end
end
cube = power_of(3)
p cube.call(5) #=> 125




prc1 = Proc.new do |a, b, c| 
	p [a, b, c]
end
prc1.call(1, 2) #=> [1, 2, nil]

prc2 = lambda do |a, b, c| 
	p [a, b, c]
end

prc2.call(1, 2, 3) #=> 错误(ArgumentError)



double = Proc.new do |*args|
	args.map{|i| i * 2 } 
end
 
p double.call(1, 2, 3) 
p double[4, 6, 8]





# 所有元素乘两倍
#=> [2, 3, 4] #=> [4, 6, 8]


leap = Proc.new do |year|
	year % 4 == 0 && year % 100 != 0 || year % 400 ==0 
end
 
p leap.call(2000) 
p leap[2013]
p leap[2016]
#=> true #=> false #=> true




# 解析时间

p Time.parse("Sat Mar 30 03:54:15 UTC 2013") #=> 2013-03-30 03:54:15 UTC
p Time.parse("Sat, 30 Mar 2013 03:54:15 +0900") #=> 2013-03-30 03:54:15 +0900
p Time.parse("2013/03/30")
#=> 2013-03-30 00:00:00 +0900
p Time.parse("2013/03/30 03:54:15") #=> 2013-03-30 03:54:15 +0900
p Time.parse("H25.03.31")
#=> 2013-03-31 00:00:00 +0900
p Time.parse("S48.9.28")
#=> 1973-09-28 00:00:00 +0900




# UTC  国际协调时间

t = Time.now
p t #=> 2013-03-30 03:15:19 +0900 

t.utc
p t #=> 2013-03-29 18:15:19 UTC 
t.localtime
p t #=> 2013-03-30 03:15:19 +0900



# 通过 Time#iso8691 方法生成符合 ISO 8601 国际标准的时间格式的字符串。使用这个方法时也需要引用 time 库。 
t = Time.now
p t.iso8601 #=> "2013-03-30T03:13:34+09:00"

# 通过 Time#rfc2822 方法可以生成符合电子邮件头部信息中的 Date
t = Time.now
p t.rfc2822 #=> "Sat, 30 Mar 2013 03:13:34 +0900"  






tempTime = Time.mktime(2018,4,21,12,12,12)

p tempTime



t = Time.new

p t.year
p t.month
p t.day
p t.min
p t.sec
p t.to_i

p t.to_s #=> 2013-03-30 03:13:14 +0900 
p t.strftime("%Y %m %d %H::%M::%S %z") 
#=> 2013-03-30 03:13:14 +0900  格式化时间字符串

p 
print  "今天是\n"
print "一周中的第",t.wday,"天","\n"
print "一月中的第",t.mday,"天","\n"
print "一年中的第",t.yday,"天","\n"


str = "こんにちは"
p str.encoding #=> #<Encoding:UTF-8> 
str2 = str.encode("EUC-JP")
p str
p str2.encoding #=> #<Encoding:EUC-JP>



p "あ" == "あ".encode("Shift_JIS") #=> false
'''




#获取当前目录中所有的文件名。(无法获取 Unix 中以 "." 开始的隐藏文件名) 
# p Dir.glob("*")

#获取当前目录中所有的隐藏文件名
# p Dir.glob(".*")

#获取当前目录中扩展名为 .html 或者 .htm 的文件名。可通过数组指定多个模式。 
# p Dir.glob(["*.html", "*.htm"])

#模式中若没有空白，则用 %w(...) 生成字符串数组会使程序更加易懂。 
# p Dir.glob(%w(*.html *.htm))

# 获取子目录下扩展名为 .html 或者 .htm 的文件名。 
# p Dir.glob(["*/*.html", "*/*.htm"])

# 获取文件名为 foo.c、foo.h、foo.o 的文件。 
# p Dir.glob("foo.[cho]")

# 获取当前目录及其子目录中所有的文件名，递归查找目录。
# p Dir.glob("**/*")

# 获取 目录foo 及其子目录中所有扩展名为 .txt 的文件夹名，递归查找目录
# p Dir.glob("资源/**/*.md")

#方法会将匹配到的文件名(目录
# Dir.glob
            
# Dir.glob("**/*")

# p Dir.glob("*")  # 所有文件  无法获取以 “.”开始的隐藏文件名
# p Dir.glob(".*") # 所有隐藏文件名


# dir = Dir.open(Dir.pwd) 
# dir.each do |name|
# 	p name 
# end
# dir.close

# p Dir.pwd
# dir = Dir.open(Dir.pwd) 
# while name = dir.read
# 	p name 
# end
# dir.close


# p Dir.pwd #=> "/usr/local/lib/ruby/2.0.0" 
# # io = File.open("find.rb")
# #=> 打开"/usr/local/lib/ruby/2.0.0/find.rb"
# # io.close

# Dir.chdir("../..") # 移动到上两层的目录中 
# p Dir.pwd #=> "/usr/local/lib" 



# /Users/wangyunfeng/Desktop/
# oldName = "Friendship2.txt"

# newname = "Friendship.txt"

# # FileUtils.cp(oldName,newname)
# FileUtils.mv(oldName,"Script/Doc/#{newname}")


# file_io = File.open(oldName, "w")

# begin
# 	File.rename(oldName,newname)
# rescue Exception => e
# 	p e.message
# end



# io = StringIO.new 
# io.puts("A") 
# io.puts("B") 
# io.puts("C") 
# io.rewind

# p io.read #=> "A\nB\nC\n"


# options = {
# 	"Accept-Language" => "zh-cn, en;q=0.5",
# }
# open("http://www.ruby-lang.org", options){|io|
# 	puts io.read 
# }



# url = "ftp://www.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p0.tar.gz" 
# open(url) do |io|
# 	print "正在打开 ftp"
# 	open("ruby-2.0.0-p0.tar.gz", "w") do |f| # 打开本地文件 
# 		f.write(io.read)
# 	end 
# end



# coding: utf-8


# puts "100"

# print("第一个 ruby 程序\n")

# a = 2

'''
if 1 == a then
	print "a 确实等于 1\n"
	# print "a 真的不等于 1"
else
	print "q 确实不等于 1\n"
end


while a < 100
	print "a = %d\n" %a
	a += 1
end


100.times do

	print "*********==========*********","\n"
end	


names = ["Subvin","Vincent Wang ","Wangyunfeng"]

names.each do |name|
	print name,"\n"
end

address = {name: "松本一郎", pinyin: "gaoqiao",tel:"18600440448"}

print address[:name],"\n"
print address[:tel],"\n"

print "\n"

address.each do |key,value|
	print key,":",value,"\n"
end


a = /abc/ =~ "gtyewghiabc"    
# 返回 abc 在后面的字符串中起始值的下标 ，正则表达式右边的 / 后面加上 i 表示不区分大小写匹配。

b = /Ruby/i =~ "ruby"

print a,"  ",b,"\n"

num0 = ARGV[0].to_i
num1 = ARGV[1].to_i
puts "#{num0} + #{num1} = #{num0 + num1}"
puts "#{num0} - #{num1} = #{num0 - num1}" 
puts "#{num0} * #{num1} = #{num0 * num1}" 
puts "#{num0} / #{num1} = #{num0 / num1}"

pattern = Regexp.new(ARGV[0]) 
filename = ARGV[1]
simple_grep(pattern,filename)

'''


# v=[{
# 	key00: "《Ruby 基础教程 第4 版》", key01: "《Ruby 秘笈》",
# 	key02: "《Rails3 秘笈》"
# }]
# p v
# p "\n"
# pp v

# ad = ARGV[0].to_i 
# heisei = ad - 1988 
# puts heisei







# puts "next 的例子:" 

# i = 0
# ["Perl", "Python", "Ruby", "Scheme"].each do |lang| 
	
# 	i+=1
# 	if 3 == i
# 		# break
# 		redo
# 		# next
# 	end
# 	p [i , lang]
# end


# 100.times do |index|
# 	print "   #{index + 1}   \n"
# end	


# i = 1
# loop do
# 	i += 1
# 	print "Ruby","\n"
# 	if 11 < i
# 		break
# 	end
# end

'''
url = URI.parse("http://www.cnblogs.com/orez88/articles/1553126.html")
http = Net::HTTP.start(url.host,url.port)
doc = http.get(url.path)
puts url.path,"    ",doc



ltotal=0
wtotal=0
ctotal=0
ARGV.each do |file|
	begin
		input = File.open(file) 
		l=0
		w=0
		c=0
		input.each_line do |line|
			l += 1
			c += line.size 
			line.sub!(/^\s+/, "") 
			ary = line.split(/\s+/) 
			w += ary.size
		end
		input.close
		printf("%8d ltotal += l wtotal += w ctotal += c
%8d %8d %s\n", l, w,c,file)
		ltotal += l
		wtotal += w
		ctotal += c

		# 行数合计 # 单词数合计 # 字数合计
		# 打开文件(A)
		# file 内的行数 # file 内的单词数 # file 内的字数
		# 删除行首的空白符 # 用空白符分解
		# 关闭文件
		# 整理输出格式
		# 输出异常信息(B)		
	rescue => ex
		print "异常抛出","\n"
		print ex.message, "\n" 
	end
end
printf("%8d %8d %8d %s\n", ltotal, wtotal, ctotal, "total")

'''




'''

def total(from,to)
	result = 0
	from.upto(to) { |num| 
		if block_given?
			result += yield(num)
			p num
		else
			result += num
			p num
		end	
	}
	return result
end

p total(1,10)
p total(1,10){ |num| num ** 2 }



def block_args_test 
	yield()
	yield(1)
	yield(1, 2, 3) 
end
# 0 个块变量 # 1 个块变量 # 3 个块变量
puts "通过|a| 接收块变量" 
block_args_test do |a|
	p [a] 
end
puts
puts "通过|a, b, c| 接收块变量" 
block_args_test do |a, b, c|
	p [a, b, c] 
end
puts
puts "通过|*a| 接收块变量" 
block_args_test do |*a|
	p [a] 
end
puts


hello = Proc.new do |name|
	puts "Hello #{name}"
end

hello.call("Lily")	
hello.call("Vincent")


def total2(from,to,&block)
	result = 0
	from.upto(to) do |num|
		if block
			result += block.call(num)
		else
			result += num
		end
	end
	return result
end	


# p total2(1,10)
# p total2(1,10){ |num| num ** 2 }

def call_each(ary, &block) 
	ary.each(&block)
end
call_each [1, 2, 3] do |item| 
	p item
end



str = "Hello, Ruby. Vincent "
p str.slice!(-1) #=> "."
p str.slice!(5..1) #=> ", "
p str.slice!(0, 5) #=> "Hello" p str #=> "Ruby"





count = Hash.new(0)


File.open(ARGV[0], "rb") do |file| 
	file.each_line do |line|
		words = line.split
		words.each do |word|
			count[word] += 1
		end
	end
end

count.sort{ |a,b|
	a[1] <=> b[1]
}.each do |key,value|
	p "#{key} : #{value}"
end



str = "http://www.ruby-lang.org/ja/?name=Subvin" 
%r|^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?| =~ str
print "server address: ", $1,"  \n",$2,"  \n",$3,"  \n",$4,"  \n",$5,"\n",$7,"  \n"



if $stdin.tty?
	print "Stdin is a TTY.\n"
else
	print "Stdin is not a TTY.\n"
end

# inputString = gets

# p inputString


io = File.open("file", "w+")
# io.print("Hello, Im Vincent")

io.rewind

p io.gets

'''








