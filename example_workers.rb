require 'anemone'

Anemone.crawl(nil) do |anemone|
  anemone.threads = 4
  anemone.delay = 0
  anemone.verbose = true
end
