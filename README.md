# rescata
Microlibrary for rescue exceptions declaratively

Still in development...

### Handling all errors

```ruby
rescata :get_talks, with: :rescue_get_talks
```

### Handling erros by error class

```ruby
rescata :get_talks, with: :rescue_get_talks, in: HTTParty::ConnectionError
```

### Rescuing with lambdas and blocks

```ruby
rescata :get_talks, with: lambda{|e| do_something }
rescata :get_talks do |e|
  puts e
  do_something
end
```

### Rescuing multiple methods at once

```ruby
rescata :get_talks, :other_method, with: :rescue_method
```

### Ensure actions

```ruby
rescata :get_talks, with: :rescue_get_talks, ensuring: :ensuring_method
rescata :get_talks, with: :rescue_get_talks, ensuring: lambda{|e| do_something }
```