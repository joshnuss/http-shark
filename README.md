# HTTP Shark

An HTTP proxy & GUI for debugging REST API calls.

## How it works

You redirect your live API traffic thru the proxy, each request is recorded in mongodb and can be viewed in realtime in the dashboard.

## Installation

```
git clone http://github.com/joshnuss/http-shark.git
```

## Usage

### Start node server

```
MONGO_URL=mongodb://localhost:27017/proxy PORT=80 node .
```

### Add a subdomain

In your `/etc/hosts` add an entry for the proxy

```
127.0.0.1 test.local.dev
```

Or if the proxy is deployed on a host (i.e. example.com), setup a DNS entry for a wildcard domain (i.e. *.example.com).

### Send traffic thru

There are two ways to do this:

Either add a redirection in your `/etc/hosts`

```
# redirect thru proxy
api.someproductionside.tld test.local.dev
```

Or find and replace the URL in your code, example:

```coffeescript
http.get('http://api.somehost.tld/things')
# becomes:
http.get('http://test.local.dev/things')
```

### Visit the dashboard

The dashboard is available at http://<domain or localhost>:<port>/dash

## License

MIT

## Author

Joshua Nussbaum
