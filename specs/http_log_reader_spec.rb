require File.dirname(__FILE__) + '/../lib/http_log_reader'

describe HttpLogReader do
  it 'should read in a stream-based fashion' do
    HttpLogReader.foreach( './specs/data/access.log.1' ) do |request|
      request.ip_address.should == '204.9.177.18'
      request.remote_user_name.should be_nil
      request.http_auth_userid.should be_nil
      request.time_finished.should == Time.utc( 2007, 7, 20, 17, 43, 45 )
      request.time_finished.gmt_offset.should == 0
      request.request_line.to_s.should == 'GET /rss/latest.xml HTTP/1.1'
      request.request_line.method.should == 'GET'
      request.request_line.resource.should == '/rss/latest.xml'
      request.request_line.protocol.should == 'HTTP/1.1'
      request.status_code.should == 304
      request.bytes_returned.should be_nil
      request.referer.should be_nil
      request.user_agent.should == 'LiveJournal.com (webmaster@livejournal.com; for http://www.livejournal.com/users/fhwangnet/; 1 readers)'
      break
    end
  end
  
  it 'should parse referers' do
    requests = HttpLogReader.read( './specs/data/access.log.1' )
    request = requests.detect { |r|
      r.ip_address == '220.245.178.135' &&
        r.request_line.resource == '/css/main.css'
    }
    request.referer.should == 'http://fhwang.net/blog/40.html'
  end
end
