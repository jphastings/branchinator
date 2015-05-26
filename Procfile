web: bundle exec rackup -spuma -p$PORT -o0.0.0.0
worker: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=7 QUEUE=apps bundle exec rake resque:work