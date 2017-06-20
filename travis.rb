require 'rubygems'
#require 'nokogiri'
#require 'open-uri'
require 'json'
require 'net/http'
require 'uri'
#require 'pry'
require 'find'

#repo =Travis::Repository.current
#puts repo
#ower_repo = system('echo $TRAVIS_REPO_SLUG')
ower_repo = ENV['TRAVIS_REPO_SLUG']
puts "ower_repo : #{ower_repo}"
#branch = system('echo $TRAVIS_BRANCH')
branch = ENV['TRAVIS_BRANCH']
puts "branch : #{branch}"
#event_type = system('echo $TRAVIS_EVENT_TYPE')
event_type = ENV['TRAVIS_EVENT_TYPE']
puts "event_type : #{event_type}"
token = ENV["GITHUB_TOKEN"]
puts "token : #{token}"
username = ENV['USERNAME']
puts "username : #{username}"
password = ENV["PASSWORD"]
puts "password : #{password}"

#build
#`gpg --gen-key`
#`sudo ./build-ubunturepo -c UP=0 BUILDALL=1;`
#`gpg --list-keys`
#`gpg --gen-key`

 ############################        set post_url  ########################
  number= "1"
  #post_url = "https://api.github.com/repos/#{ower_repo}/issues/#{pull_number}/comments"
  post_url = "https://api.github.com/repos/#{ower_repo}/issues/#{number}/comments"
  puts "post_url : #{post_url}"

 ############################        build         #########################
  puts "\033[42m gpg --list-keys\033[0m\n"
  system("gpg --list-keys")
  puts "\033[42msudo -s ./build-ubunturepo -c UP=0 BUILDALL=1;\033[0m\n"
  #system("sudo -s ./build-ubunturepo -c UP=0 BUILDALL=1")
  buildresult = `sudo ./build-ubunturepo -c UP=0 BUILDALL=1 2>&1`
  #puts "buildresult :begin:---------------------------------------------------------------------------- #{buildresult}-------------end"
  p buildresult
  #puts "buildresult : #{buildresult}"
  #####  TODO  get build error information#####
  #buildresulterror = buildresult[-20..-1]
  buildresult.delete!('\'')
  buildresult.delete!('\"')
  buildresult.delete!('\:')
  buildresult.chomp!
  ##buildresult.gsub!(/\s/,'')
  #p buildresult
  if(buildresult.include?("ERROR")||buildresult.include?("error"))
    errorindex = buildresult.rindex("ERROR")
    puts "errorindex : #{errorindex}"
    puts "error: #{buildresult}"
    `curl -u "#{username}:#{password}" -X POST -d '{"body":"> **BUILDERROR**  :  #{buildresult}"}'  #{post_url}`  
  end
  test = "test"
  p test 
  `curl -u "#{username}:#{password}" -X POST -d '{"body":"> lalala#{test}"}'  #{post_url}`
  #`curl -u "#{username}:#{password}" -X POST -d '{"body":"> **BUILDERROR**  :  #{buildresult}"}'  #{post_url}`  

  ############################       install        ###########################
  #system("cd ..")
  #system("cd ..")
  #`cd ..`
  puts "\033[42mls -a \033[0m\n"
  system("ls -a")
  #system("cd xcat-core")
  puts "\033[42msudo ./mklocalrepo.sh\033[0m\n"
  system("sudo ./../../xcat-core/mklocalrepo.sh")
  #system("sudo chmod 777 /etc/apt/sources.list")
  system('sudo echo "deb [arch=amd64] http://xcat.org/files/xcat/repos/apt/xcat-dep trusty main" >> /etc/apt/sources.list')
  system('sudo echo "deb [arch=ppc64el] http://xcat.org/files/xcat/repos/apt/xcat-dep trusty main" >> /etc/apt/sources.list')
  #system("sudo cat /etc/apt/sources.list")
  puts "\033[42m sudo wget -O - \"http://xcat.org/files/xcat/repos/apt/apt.key\" | sudo apt-key add - \033[0m\n"
  system('sudo wget -O - "http://xcat.org/files/xcat/repos/apt/apt.key" | sudo apt-key add -')
  puts "\033[42m sudo apt-get  install software-properties-common \033[0m\n"
  #system("sudo apt-get  install software-properties-common")
  ##`sudo apt-get clean all`
  puts "\033[42m sudo apt-get -qq update \033[0m\n"
  system("sudo apt-get -qq update")
  ##`sudo apt-get install xCAT --force-yes -y`
  puts "\033[42m sudo apt-get install xCAT --force-yes \033[0m\n"
  installresult = system("sudo apt-get install xCAT --force-yes >/tmp/install-log 2>&1")
  puts "installresult : #{installresult}"
  system("cat /tmp/install-log")


###########################    Verify xCAT Installation   ##################################
  puts "\033[42msource /etc/profile.d/xcat.sh\033[0m\n"
  system("source /etc/profile.d/xcat.sh")
  system("sudo echo $USER")
  #`sudo cat /opt/xcat/share/xcat/scripts/setup-local-client.sh`
  #`sudo -s /opt/xcat/share/xcat/scripts/setup-local-client.sh travis "" -f`
  puts "\033[42m sudo -s /opt/xcat/share/xcat/scripts/setup-local-client.sh -f travis \033[0m\n"
  system("sudo -s /opt/xcat/share/xcat/scripts/setup-local-client.sh -f travis")
  system("sudo -s /opt/xcat/sbin/chtab priority=1.1 policy.name=travis policy.rule=allow")
  puts "\033[42mlsxcatd -v\033[0m\n"
  system("lsxcatd -v")
  #puts lsxcatedresult
  #`sudo -s /opt/xcat/sbin/tabdump policy`
  #`sudo -s /opt/xcat/sbin/tabdump site`
  puts "\033[42mtabdump policy\033[0m\n"
  system("tabdump policy")
 
  puts "\033[42mtabdump site\033[0m\n"
  system("tabdump site")
  system("ls /opt/xcat/sbin")
  system("ls /opt/xcat")
  puts "\033[42m service xcatd start \033[0m\n"
  system("service xcatd start")
  puts "\033[42m service xcatd status \033[0m\n"
  system("service xcatd status")






##########################     pull_request format check   ####################
if(event_type == "pull_request")
  #pull_number = system('echo $TRAVIS_PULL_REQUEST')
  pull_number = ENV['TRAVIS_PULL_REQUEST']
  puts "pull_number : #{pull_number}"
  uri = "https://api.github.com/repos/#{ower_repo}/pulls/#{pull_number}"
  puts "pull_request_url : #{uri}"
  resp = Net::HTTP.get_response(URI.parse(uri))
  jresp = JSON.parse(resp.body)
  #puts "jresp: #{jresp}"
  title = jresp['title']
  puts "pull_request title : #{title}"
  body = jresp['body']
  puts "pull_request body : #{body}"
  
  # Remove digits
  #title = title.gsub!(/\D/, "")
  
  if(!(title =~ /^Add|Refine test case|cases for issue|feature(.*)/))
    raise "The title of this pull_request have a wrong format. Fix it!"
  end
  if(!(body =~ (/Add|Refine \d case|cases in this pull request(.*)/m))||!(body =~ (/This|These case|cases is|are added|refined for issue|feature(.*)/m))||!(body =~ (/This pull request is for task(.*)/m)))
    raise "The description of this pull_request have a wrong format. Fix it!"
  end
 
  
  ######################################  check syntax  ################################################
  resultArr = Array.new
  #print all path at current path
  puts "work path : #{Dir.pwd}"
  Find.find('/home/travis/build/DengShuaiSimon/xcat-core') do |path| 
    #puts path unless FileTest.directory?(path)  #if the path is not a directory,print it.
    #puts File.ftype(File.basename(path)) unless FileTest.directory?(path)
    if(File.file?(path))
      #puts "path : #{path}"
      #puts "file type : #{File.basename(path)[/\.[^\.]+$/]}"
      
#=begin
     #--------file command test----------
     fileType = `file #{path} 2>&1`
     puts "fileReturn : #{fileType}"
     if(fileType.include?("shell"))
           puts "shell"
     elsif(fileType.include?("Perl"))
           puts "Perl"
     end
#=end
     
      base_name = File.basename(path,".*")
      #puts "notype_basename : #{base_name}"
      file_type = path.split(base_name)
      #puts "file type : #{file_type[1]}"
    
      #puts "\n"
      if(file_type[1] == ".pm")
        puts "path : #{path}"
        result = %x[perl -I perl-xCAT/ -I ds-perl-lib -I xCAT-server/lib/perl/ -c #{path} 2>&1]
        #result = `perl -I perl-xCAT/ -I ds-perl-lib -I xCAT-server/lib/perl/ -c #{path} 2>&1`
        puts result
        puts "result[-3..-2] : #{result[-3..-2]}"

        if(result[-3..-2]!="OK")
          #p result
          resultArr.push(result)
        end

        puts "\n"
      end
    end
  
  end #find ... do
  
    
  ####################   add comments  ########################## 
  #####follow code is added in <set post_rul >###
  #number= "1"
  ##post_url = "https://api.github.com/repos/#{ower_repo}/issues/#{pull_number}/comments"
  #post_url = "https://api.github.com/repos/#{ower_repo}/issues/#{number}/comments"
  #puts post_url
  
  #resultArr.each{|x| `curl -u "#{username}:#{password}" -X POST -d '{"body":"#{x}"}'  #{post_url}`,""}
  `curl -u "#{username}:#{password}" -X POST -d '{"body":"syntax error : \n #{resultArr}"}'  #{post_url}`
  `curl -u "#{username}:#{password}" -X POST -d '{"body":"hope this work2"}'  #{post_url}`
  #`curl -X POST -s -u "#{username}:#{token}" -H "Content-Type: application/json" -d '{"body": "successful!"}' #{post_url}`
 
  ####################    stop and print error in travis (red color)   #######################
  puts "\033[31m error begin---------------------------------------------------------------------------------------------------------\033[0m\n"
  #puts "\033[31m#{resultArr}\033[0m\n"
  resultArr.each{|x| puts "\033[31m#{x}\033[0m\n",""}
  puts "\033[31m error   end---------------------------------------------------------------------------------------------------------\033[0m\n"
  #raise "There is a syntax error on the above file. Fix it!"
  
  
  ############################        build         #########################
  `gpg --list-keys`
  buildresult = `sudo ./build-ubunturepo -c UP=0 BUILDALL=1; 2>&1`
  puts "buildresult : #{buildresult}"
  #####  TODO  get build error information#####
  `curl -u "#{username}:#{password}" -X POST -d '{"body":"build error : \n #{resultArr}"}'  #{post_url}`
  
  ############################       install        ###########################
  `cd ../..`
  `ls -a`
  `cd xcat-core`
  `sudo ./mklocalrepo.sh`
  `sudo chmod 777 /etc/apt/sources.list`
  `sudo echo "deb [arch=amd64] http://xcat.org/files/xcat/repos/apt/xcat-dep trusty main" >> /etc/apt/sources.list`
  `sudo echo "deb [arch=ppc64el] http://xcat.org/files/xcat/repos/apt/xcat-dep trusty main" >> /etc/apt/sources.list`
  `sudo cat /etc/apt/sources.list`
  `sudo wget -O - "http://xcat.org/files/xcat/repos/apt/apt.key" | sudo -s apt-key add -`
  `sudo apt-get  install software-properties-common`
  #`sudo apt-get clean all`
  `sudo apt-get -qq update`
  #`sudo apt-get install xCAT --force-yes -y`
  `sudo apt-get install xCAT --force-yes`
  `source /etc/profile.d/xcat.sh`
  `sudo echo "$USER"`
  `sudo cat /opt/xcat/share/xcat/scripts/setup-local-client.sh`
  `sudo -s /opt/xcat/share/xcat/scripts/setup-local-client.sh travis "" -f`
  `lsxcatd -v`
  `sudo chmod 777 /opt/xcat/sbin/tabdump`
  `sudo -s /opt/xcat/sbin/tabdump policy`
  `sudo -s /opt/xcat/sbin/tabdump site`
  `ls /opt/xcat/sbin`
  `ls /opt/xcat`
  `service xcatd start`
  `service xcatd status`
  
end  #pull_request if








=begin
######################################  check syntax  ################################################
resultArr = Array.new
#print all path at current path
puts "work path : #{Dir.pwd}"
Find.find('/home/travis/build/DengShuaiSimon/xcat-core') do |path| 
  #puts path unless FileTest.directory?(path)  #if the path is not a directory,print it.
  #puts File.ftype(File.basename(path)) unless FileTest.directory?(path)
  if(File.file?(path))
    #puts "path : #{path}"
    #puts "file type : #{File.basename(path)[/\.[^\.]+$/]}"
    
    base_name = File.basename(path,".*")
    #puts "notype_basename : #{base_name}"
    file_type = path.split(base_name)
    #puts "file type : #{file_type[1]}"
    
    #puts "\n"
    if(file_type[1] == ".pm")
      puts "path : #{path}"
      result = %x[perl -I perl-xCAT/ -I ds-perl-lib -I xCAT-server/lib/perl/ -c #{path} 2>&1]
      #result = `perl -I perl-xCAT/ -I ds-perl-lib -I xCAT-server/lib/perl/ -c #{path} 2>&1`
      puts result
      puts "result[-3..-2] : #{result[-3..-2]}"

      if(result[-3..-2]!="OK")
        #p result
        resultArr.push(result)
      end

      puts "\n"
    end
  end
  
end 

puts "\033[31m error begin---------------------------------------------------------------------------------------------------------\033[0m\n"
#puts "\033[31m#{resultArr}\033[0m\n"
resultArr.each{|x| puts "\033[31m#{x}\033[0m\n",""}
puts "\033[31m error   end---------------------------------------------------------------------------------------------------------\033[0m\n"
#raise "There is a syntax error on the above file. Fix it!"




####################   add comments  ########################## 
number= "1"
#post_url = "https://api.github.com/repos/#{ower_repo}/issues/#{pull_number}/comments"
post_url = "https://api.github.com/repos/#{ower_repo}/issues/#{number}/comments"
puts post_url

`curl -u "#{username}:#{password}" -X POST -d '{"body":"hope this work2"}'  #{post_url}`

#echo "Add comment in issue $number"
#`curl -d '{"body":"successful"}' "#{post_url}"`
`curl -X POST -s -u "#{username}:#{token}" -H "Content-Type: application/json" -d '{"body": "successful!"}' #{post_url}`
#`curl -X POST \
#     -u #{token}:x-oauth-basic \
#     -H "Content-Type: application/json" \
#     -d "{\"body\": \"successful!\"}" \
#     https://api.github.com/repos/DengShuaiSimon/xcat-core/issues/1/comments`

=end
