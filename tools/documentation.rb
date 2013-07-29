#!/usr/bin/env ruby

input = ARGV[0]

if input.nil?
  print "Usage is ruby documentation.rb ${input_file}\n"
else
  description = ''
  param = ''
  returning = ''
  function = '';
  File.open(input).each do |line|
    if line.include?('  *') or line.include?('{')
      if line.include?('@param') or line.include?('@return')
        if line.include?('@param')
          param += line.gsub('  * @param ','<li> ').sub(/\s[A-Z_a-z]*\s/, '<b>\0</b>').sub("\n","</li>\n")
        elsif line.include?('@return')
          returning += line.sub('  * @','<b><i>').sub("\n","</i></b>\n")
        end
      else
        if line.include?('  * ')
          if line.include?("\\n")
            description += line.gsub('  * ','').gsub("\\n",'').gsub("\n",' ')
          else
            description += line.gsub('  * ','')
          end
        elsif line.include?('{') and !line.include?('if') and !line.include?('else')
          function += line.gsub("\t",'').gsub('{',";\n");
          print '<p>' + description + '</p>'
          print '<ul>' + param + '</ul>'
          if !returning.empty?
            print '<p>' + returning + '</p>'
          end
          print '<p><b>' + function + '</b></p><br/>'
          description = ''
          param = ''
          returning = ''
          function = ''
        end
      end
    elsif line.include?('//=========')
      print line.gsub('//========= ','<h3>').gsub(' ==========','</h3>')
    end
  end
end