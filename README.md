# rescata
Microlibrary for rescue exceptions declaratively in your Ruby classes.

Dry up your code from `begin... rescue... ensure.... end`

## Installation

Installing Rescata is as simple as running:

```
$ gem install rescata
```

Include Rescata in your Gemfile with gem 'rescata' or require it with require 'rescata'.

## Usage

### Rescuing from errors

After include `Rescata`, you can rescue any error inherited from `StandardError` passing to `rescata` the method that you want to rescue if something is raised inside of it, and the method you want to execute(in `with` key) for rescue it(both method's names as symbols).

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
# The error will be rescued
puts User.new.operation
#=> "do_something"
```

You can get the error instance if your method called to rescue can receive an argument.

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

puts User.new.operation
#=> "is happening a problem"
```

### Rescuing from an error class

Also is possible rescue just from a particular error class, just use `in` key as a hash argument into `rescata` to make that possible.

```ruby
class User
  include Rescata
  rescata :operation, with: :rescuing_operation, in: ArgumentError
  rescata :other_operation, with: :rescuing_operation, in: NameError

  def operation
    raise "a problem"
  end

  def other_operation
    raise NameError, "other problem"
  end

  def rescuing_operation(e)
    "is happening #{e.message}"
  end
end

# This will be raise an error(in the example above we are just recuing 'operation' from ArgumentError)
User.new.operation
#=> RuntimeError: a problem

# This will be rescued
puts User.new.other_operation
#=> "is happening other problem"
```

Send an array if you want to rescue for two or more class errors.

```ruby
class User
  include Rescata
  rescata :operation, with: :rescuing_operation, in: [NameError, ArgumentError]

  def operation
    raise ArgumentError, "a problem"
  end

  def rescuing_operation(e)
    "is happening #{e.message}"
  end
end

# This will be rescued because ArgumentError is included into the error classes specified
puts User.new.operation
#=> "is happening other problem"
```

### Rescuing using lambdas and blocks

You can rescue a method using a lambda. Just add it into the `with` key(don't forget receive the error instance if you need it). Or use a block if you want.

```ruby
class User
  include Rescata
  # Rescuing using a lambda
  rescata :operation, with: lambda{|e| "is happening #{e.message}" }

  # Rescuing using a block
  rescata :other_operation do |e|
    "is happening #{e.message}"
  end

  def operation
    raise "a problem"
  end

  def other_operation
    raise "other problem"
  end
end

# both methods will be rescued
puts User.new.operation
#=> "is happening a problem"

puts User.new.other_operation
#=> "is happening other problem"
```

Also you can still rescuing from particular errors using lambdas or blocks. This gives you freedom to build any custom solution to rescue for specific error classes.

```ruby
rescata :operation, with: :rescuing_operation, in: CustomError
rescata :operation, with: lambda{|e| do_something }, in: RuntimeError
rescata :operation, in: [ArgumentError, NameError] do |e|
  do_something
end
```

### Rescuing multiple methods at once

Rescue from multiple methods in the same line sending them into an array as first variable of `rescata`.

```ruby
# Rescuing multiple methods in many ways
rescata [:operation, :other_operation], with: :rescuing_operations
rescata [:operation, :other_operation], with: lambda{|e| do_something }, in: CustomError
rescata [:operation, :other_operation], in: [CustomError, NameError] do |e|
  do_something
end
```

### Ensuring

And we haven't forgotten the ensure actions, you can ensure your methods using `ensuring` key as a hash argument into `rescata`, you can ensure from a method or a lambda, if you opt for lambda it will receive the instance of your class as a variable to do whatever you need.

```ruby
class User
  attr_accessor :name

  include Rescata
  rescata :operation, with: :rescuing_operation, ensuring: :ensuring_method
  rescata :other_operation, with: :rescuing_operation, ensuring: lambda{|instance| instance.name = "Piero" }

  def initialize(name)
    @name = name
  end

  def operation
    raise "a problem"
  end

  def other_operation
    raise "other problem"
  end

  def rescuing_operation
    #do_something
  end

  def ensuring_method
    @name = "Piero"
  end
end

# Both methods will be rescued and executed its ensure actions
u = User.new("Julio")
u.operation
puts u.name
#=> "Piero"

u = User.new("Julio")
u.other_operation
puts u.name
#=> "Piero"
```