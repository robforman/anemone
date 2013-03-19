require "redis"
require "uri"

class RedisQueue
  attr_reader :redis, :name, :working

  def initialize(name, dsn=nil)
    @name = name
    @working = "#{@name}:working"

    if dsn
      uri = URI.parse(dsn)
      @redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    else
      @redis = Redis.new
    end
  end

  def incr_working
    redis.incr(working)
  end

  def decr_working
    redis.decr(working)
  end

  def enq(obj)
    redis.rpush(name, Marshal.dump(obj))
  end

  def deq
    list, obj = redis.blpop(name)
    Marshal.load(obj)
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
    redis.del(working)
  end

  def num_working
    redis.get(working).to_i
  end
end
