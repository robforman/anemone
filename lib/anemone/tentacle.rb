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
        @link_queue.deq do |link, referer, depth|
          @http.fetch_pages(link, referer, depth).each do |page|
            puts "[#{@tag}] #{page.url}" if @opts[:verbose]
            @page_queue << page
          end
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
