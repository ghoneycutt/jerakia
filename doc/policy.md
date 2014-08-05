## Jacaranda Policies ##

### Introduction ###

Each search request is run aganst a specific search policies.  Search policies are used to defined a set of lookups to resolve data.  A simple policy can be defined as follows

`/etc/jacaranda/policy.d/puppet.rb`:

    policy :puppet do
    
      lookup :default do
        datasource :file, {
          :format => :yaml,
          :docroot => '/etc/jacaranda/data',
          :searchpath => [
            "#{scope[:environment]}",
            'global',
            'common'
          ]
        }
      end
    
    end

A policy definition can contain many lookups which will be in in order.

## Lookups ##

Lookup blocks define where and how to source the data.  At a minmum a lookup block must specify a `datasource` to pass the request to. Data sources can optionally take a hash of arguments.  Look at each datasource's documentation for information on what options they support.

Supported methods are

* `datasource, {opts}` data source with corresponding options
* `invalidate` disable this lookup
* `scope` return the scope object
* `output_handler` add an output handler to this request

### Scope object ###

Scope is a key value set that can be used to determine the behaviour of a lookup.  By default the scope is built out of the metadata sent with the request, but can be loaded from a variety of scope handlers such as PuppetDB.  Scopes can be accessed directly in the lookup using the scope function eg: `scope[:environment]`

### Plugins ###

Additionally, lookup functionality can be expanded with a variety of shipped or custom plugins.  Plugins have access to a copy of the request object and therefore can inspect and make changes to all manor of things contained within it.  Shipped plugins currently include

* `confine` : Confine the lookup based on a scope attribute having a particular value
* `exclude` : Exclude the lookup if a scope attribute has a particular value
* `hiera_compat` : Rewrite the lookup to emulate Hiera's filesystem layout (see datasources/file.md)

### Output Handler ###

Optionally, you can specify one or more output handlers.  Output handlers are passed the response object before they are compiled into an answer and returned to the requestor.  One shipped output handler is encryption which passes every response value through a filter to determine if decryption is required, and if so, uses eyaml (from heira-eyaml) to decrypt the data

## Example ##

Here is an example of a slightly more complicated policy that makes use of some of the above

    policy :puppet do
    
      lookup :default do
        datasource :file, {
          :format => :yaml,
          :docroot => '/etc/jacaranda/data',
          :searchpath => [
            scope[:certname],
            scope[:environment],
            'global',
          ]
          },
        hiera_compat
        exclude :calling_module, "specialapp"
        output_handler :encryption
      }
    
      lookup :special do {
        datasource :http, {
          :url => 'http://localhost:9999',
          :paths => [
            "/config/?#{scope[:certname]}",
            "/config/?global"
          ]
        confine :calling_module, "specialapp"
      end
    end

In this, rather imaginative example, all lookup requests will be passed to the file datasource specified in the default lookup, except for requets that have calling_module set to 'specialapp'.  When calling_module is set to special_app the only lookup that will be used is `special`.   Here we are using a combination of exclude and confine to effectivly route lookup requests.


     




 