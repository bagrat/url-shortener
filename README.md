# URL Shortener

This is a demo web application implementing a URL shortener using [Elixir][elixir] and [Phoenix LiveView][live-view] with a PostgreSQL database for storage.

Apart from allowing to create short URLs for anonymous users, this app also offers more features to registered users:

- change the short URL slug to a custom text
- keep a history of created short URLs
- track number of visits to each short URL

## Launch the app locally

The app repo is shipped with a Docker Compose file alowing one step launch of the app on your local machine. Run the commands below to get the app up and running:

```shell
git clone git@github.com:bagrat/url-shortener.git
cd url-shortener
docker-compose up
```

Let Docker do its heavy-lifting for a couple of minutes and as soon as you see the below log line, go ahead and navigate your browser to `http://localhost:4000` and start playing around with your own local URL shortener.

```log
[info] Access ShortenerWeb.Endpoint at http://localhost:4000
```

Have fun and feel free to file issues to this repo or submit Pull Requests!

<!-- references -->

[elixir]: https://elixir-lang.org/
[live-view]: https://www.phoenixframework.org/
