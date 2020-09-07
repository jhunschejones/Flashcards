release: rake db:migrate cache:clear
web: bundle exec puma -p ${PORT:-3000} -e ${RACK_ENV:-development}
