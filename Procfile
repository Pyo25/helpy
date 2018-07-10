# Launcher for Unicorn
# web: bundle exec unicorn_rails -p $PORT -c ./config/unicorn.rb

# Launcher for Puma
web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
