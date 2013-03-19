require 'anemone'

Anemone.crawl("http://www.google.com/") do |anemone|
  anemone.depth_limit = 1
  anemone.discard_page_bodies = true
  anemone.on_every_page { |page|
    puts "on_every_page #{page.url} referrer #{page.referer}"
  }
  anemone.after_crawl { puts "after_crawl nothing to do." }
end

puts "done"
