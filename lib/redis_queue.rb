require "redis"
require "uri"

class RedisQueue
  attr_reader :redis, :name, :in_process

  def initialize(name, dsn=nil)
    @name = name
    @in_process = "#{@name}:in_process"

    if dsn
      uri = URI.parse(dsn)
      @redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    else
      @redis = Redis.new
    end
  end

  def enq(obj)
    redis.lpush(name, Marshal.dump(obj))
  end

  def deq
    if block_given?
      begin
        obj = _start_deq
        yield(obj)
      ensure
        _end_deq
      end
    else
      _deq
    end
  end

  def num_in_process
    redis.llen(in_process)
  end

  def size
    redis.llen(name)
  end

  def <<(obj)
    enq(obj)
  end

  def empty?
    size == 0
  end

  def reset!
    redis.del(name)
    redis.del(in_process)
  end

  protected

  def _deq
    list, obj = redis.brpop(name)
    Marshal.load(obj)
  end

  def _start_deq
    obj = redis.brpoplpush(name, in_process)
    Marshal.load(obj)
  end

  def _end_deq
    redis.rpop(in_process)
  end
end
