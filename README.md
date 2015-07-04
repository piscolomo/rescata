# rescata
Microlibrary for rescue exceptions declaratively in your Ruby classes.

Dry up your code from `begin... rescue... ensure.... end`

### Rescuing from errors

You can rescue any error inhirited from `StandardError` passing to `rescata` the method that you want to rescue if something is raised inside of it, and the method you want to execute(in `with` key) for rescue it.

```ruby
class User
  include Rescata
  rescata :operation, with: :rescuing_operation

  def operation
    raise "some problem"
  end

  def rescuing_operation
    "do_something"
  end
end

# Next line execute :rescuing_operation if a raise is launched inside of operation
User.new.operation
=> "do_something"
```

You can get the error instance if your method derived to rescue can receive an argument.

```ruby
class User
  include Rescata
  rescata :operation, with: :rescuing_operation

  def operation
    raise "a problem"
  end

  def rescuing_operation(e)
    "is happening #{e.message}"
  end
end

User.new.operation
=> "is happening a problem"
```

### Rescuing from an error class

Also is possible rescue just from a particular error class, just use `in` key as a hash argument into `rescata` to make that possible. Send an array if you want to rescue for two or more class errors.

```ruby
rescata :operation, with: :some_method, in: RuntimeError
rescata :operation, with: :other_method, in: [ArgumentError, NameError]
```

### Rescuing using lambdas and blocks

You can rescue a method using a lambda. Just add it into the `with` key(don't forget receive the error instance if you need it). Or use a block if you want!

```ruby
# Rescuing using a lambda
rescata :operation, with: lambda{|e| do_something }

# Rescuing using a block
rescata :operation do |e|
  do_something
end

# Also you can still rescuing from particular errors using lambdas or blocks
rescata :operation, in: RuntimeError, with: lambda{|e| do_something }
rescata :operation, in: [ArgumentError, NameError] do |e|
  do_something
end
```

### Rescuing multiple methods at once

Rescue from multiple methods in the same line if you have a lot of methods that you need to run the same action, just send them into an array as first variable of `rescata`.

```ruby
rescata [:operation, :other_operation], with: :rescuing_operations
```

### Ensuring

And we haven't forgotten the ensure actions, you can ensure your methods using `ensuring` key as a hash argument into `rescata`, you can rescue from a method or a lambda, this lambda will receive the instance of your class as a variable to do whatever you need.

```ruby
rescata :operation, with: :rescuing_operation, ensuring: :ensuring_method
rescata :operation, with: :rescuing_operation, ensuring: lambda{|instance| do_something }
```