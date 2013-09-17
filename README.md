# Wit Feeder

Unofficial atom feed generator for http://wit.flakiness.es/

#=> https://s3.amazonaws.com/kyanny/wit.rss

```
$ bundle install
$ AWS_ACCESS_KEY_ID=xxxx AWS_SECRET_ACCESS_KEY=xxxx ruby app.rb
```

```
$ heroku accounts:me
$ heroku apps:create wit-feeder
$ git push heroku master
$ heroku addons:add scheduler:standard
$ heroku config:set AWS_ACCESS_KEY_ID=xxxx
$ heroku config:set AWS_SECRET_ACCESS_KEY=xxxx
```
