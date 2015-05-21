web: bundle exec rackup -spuma -p$PORT -o0.0.0.0 webapp.ru
worker: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=7 QUEUE=apps bundle exec rake resque:work
resque: bundle exec rackup -spuma -p5050 -o0.0.0.0 resque.ru