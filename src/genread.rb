require 'rubygems'
require 'redcloth'

input = File.new "README.textile", 'r'
text = input.readlines.join
input.close

output = File.new "README.html", "w"
output.puts <<HERE
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-type" content="text/html;charset=UTF-8" />
<title>Block Bounce README</title>
<style type="text/css">
h2.author
{
font-size: 15pt;
}
h2.version
{
font-size: 14pt;
}
div.top, div.content { margin-top: 35px; margin-left: 35px; }
div.content
{
width: 30%;
background: #FFD;
padding: 30px;
float: left;
}
div.heading
{
padding: 30px;
background: #DFF;
}
div.top
{
width: 350px;
float: left;
}
div.license
{
margin-top: 35px;
padding: 30px;
background: #FDF;
}
code
{
font-size: 10pt;
background: #DDD;
padding: 5px;
}
div.version
{
margin-top: 35px;
padding: 30px;
background: #DFD;
}
</style>
</head>
<body>
HERE
output.puts RedCloth.new(text).to_html
output.puts <<HERE
</body>
</html>
HERE
output.close
