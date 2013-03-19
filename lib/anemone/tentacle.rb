require 'anemone/http'
require 'socket'

module Anemone
  class Tentacle

    #
    # Create a new Tentacle
    #
    def initialize(link_queue, page_queue, opts = {})
      @link_queue = RedisQueue.new(link_queue)
      @page_queue = RedisQueue.new(page_queue)
      @http = Anemone::HTTP.new(opts)
      @opts = opts
      @tag = "#{Socket.gethostname}-#{Thread.current.object_id}"
    end

    #
    # Gets links from @link_queue, and returns the fetched
    # Page objects into @page_queue
    #
    def run
      loop do
        link, referer, depth = @link_queue.deq

        break if link == :END

        begin
          @link_queue.incr_working
          @http.fetch_pages(link, referer, depth).each { |page|
            puts "[#{@tag}] #{page.url}" if @opts[:verbose]
            @page_queue << page
          }
        ensure
          @link_queue.decr_working
        end

        delay
      end
    end

    private

    def delay
      sleep @opts[:delay] if @opts[:delay] > 0
    end

  end
end
