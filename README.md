# HTTP Shark

An HTTP proxy & GUI for debugging REST API calls.

## How it works

Redirect your live API traffic thru the proxy, each request is recorded in mongodb and can be viewed in realtime via the dashboard.

## Installation

```
git clone http://github.com/joshnuss/http-shark.git
```

## Usage

### Start server

```
MONGO_URL=mongodb://localhost:27017/proxy PORT=80 node .
```

### Add a subdomain

There are two ways to do this:

In your `/etc/hosts` add an entry for the proxy:

```
# you can proxy multiple subdomains at once
127.0.0.1 paypal-proxy.local.dev
127.0.0.1 fedex-proxy.local.dev
```

Or if the proxy is deployed on a host (i.e. example.com), setup a DNS entry for a wildcard domain (i.e. *.example.com).

### Redirect traffic

There are two ways to do this:

Either add a redirection in your `/etc/hosts`

```
paypal-proxy.local.dev api.paypal.com
```

Or find and replace the URL in your code, example:

```coffeescript
http.get('http://api.paypal.com/things')
# becomes:
http.get('http://paypal-proxy.local.dev/things')
```

### Visit the dashboard

The dashboard is available at http://<domain or localhost>:<port>/dash

## License

MIT

## Author

Joshua Nussbaum
