module HttpLogReader
  def self.foreach( file_path, opts = {} )
    requests = read file_path, opts
    requests.each do |r| yield( r ); end
  end
  
  def self.read( file_path, opts = {} )
    lines = File.readlines file_path
    requests = lines.
        map { |line| line.chomp! }.
        select { |line| line.size > 0 }.
        map { |line| Request.new( line ) }
    if opts[:start_time]
      requests = requests.select { |req|
        req.time_finished >= opts[:start_time]
      }
    end
    requests
  end
  
  class Request
    require 'parsedate'
    
    attr_reader :ip_address, :remote_user_name, :http_auth_userid,
                :time_finished, :request_line, :status_code, :bytes_returned,
                :referer, :user_agent
    
    def initialize( line )
      line =~ %r|^(\S+) (\S+) (\S+) \[([^\]]+)\] "([^"]+)" (\S+) (\S+) "(\S+)" "([^"]+)"|
      @ip_address = $1
      @remote_user_name = $2 unless $2 == '-'
      @http_auth_userid = $3 unless $3 == '-'
      time_finished_raw = $4
      request_line_raw = $5
      @status_code = $6.to_i
      @bytes_returned = $7.to_i unless $7 == '-'
      @referer = $8 unless $8 == '-'
      @user_agent = $9
      @time_finished = parse_time_finished time_finished_raw
      @request_line = RequestLine.new request_line_raw
    end
    
    def parse_time_finished( time_finished_raw )
      time_finished_raw =~ %r{^(\d{2})/(\w{3})/(\d{4}):(\d{2}):(\d{2}):(\d{2}) (-|\+)(\d{2})(\d{2})}
      offset_direction = $7
      offset_hours = $8.to_i
      offset_minutes = ( offset_hours * 60 ) + $9.to_i
      offset_seconds = offset_minutes * 60
      time_finished = Time.utc(
        $3.to_i, $2, $1.to_i, $4.to_i, $5.to_i, $6.to_i
      )
      if offset_direction == '+'
        time_finished = time_finished - offset_seconds
      else
        time_finished = time_finished + offset_seconds
      end
      time_finished
    end
    
    class RequestLine
      attr_reader :to_s, :method, :resource, :protocol
      
      def initialize( string )
        @to_s = string
        @method, @resource, @protocol = string.split /\s+/
      end
    end
  end
end
