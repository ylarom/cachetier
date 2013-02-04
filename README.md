# Cachetier

Data caching is useful when you need to invest in order to fetch the same data over and over, especially when each fetch is expensive, for example DB queries, web service calls, or the result of a non-trivial calculations.

The fastest way to cache data is local memory, but you can also use shared memory such as Redis or memcached which makes the data available to other application servers.
In some cases, even a DB can be a useful cache for very long operations, or such that you can only access a limited number of times (e.g. web service API with a daily limit).

Cachetier offers a way to define several layers of cache and automatically fetch and store the data over all layers.

## Usage

```ruby  
def MyClass 
  def self.get_value(key)
    ...
  end
    
  include Cachetier
  cachetier :get_value, { mem: { ttl: 1.minute }, redis: { ttl: 10.minutes } } 
end  
```

In the example above, accessing ```MyClass.get_value``` will:
* Search a local hash for the an entry for ```key```
* If not found, lookup entry ```key``` in Redis
* If not found, invoke the original ```get_value``` method, and will store the result in Redis and in the local hash.

Cachetier can also receive a block as a parameter instead of using an existing method. Cachetier will define a class method for the given name.

```ruby
class MyOtherClass
  cachetier :get_other_value, { mem: { ttl: 10.sec } }, do |key|
    ...
  end
end

MyOtherClass.get_other_value(42)
```

## Configuration

Cachetier configuration includes the layers at which data will be cached, and specific options per layer, such as TTL (time to live before expiration).

It currently defined are memory (hash) and Redis layers, but more layers (such as memcached and MongoDB) can be easily added.

You can set global default settings and override them for each method.

```ruby

Cachetier.configuration = { mem: { ttl: 10.seconds } }

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
