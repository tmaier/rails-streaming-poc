# Rails Streaming PoC

This is a PoC to test out the streaming capabilities of Rails at relevant application platforms.

A single-file Rails application demonstrating streaming capabilities using `ActionController::Live`.
The application streams a counter to the client, incrementing every second.

## Usage

### Starting the Server

```bash
bin/dev
```

### Testing with curl

Basic usage (20 second counter):
```bash
curl http://localhost:9292
```

### Available Parameters

- `duration`: Number of seconds to stream (default: `20`)
  ```bash
  curl "http://localhost:9292?duration=30"
  ```

- `rack2`: Enable Rack 2.x compatibility headers (default: `false`)
  ```bash
  curl "http://localhost:9292?rack2=true"
  ```

- `fly`: Enable fly.io compatibility mode by setting Content-Encoding header (default: `false`)
  ```bash
  curl "http://localhost:9292?fly=true"
  ```

Combine parameters:
```bash
curl "http://localhost:9292?duration=30&rack2=true&fly=true"
```

## References

- Rails ActionController::Live documentation: https://api.rubyonrails.org/classes/ActionController/Live.html
- Single file Rails application guide: https://greg.molnar.io/blog/a-single-file-rails-application/
- fly.io streaming discussion: https://community.fly.io/t/http-response-streaming-not-working-on-fly-io/23580
