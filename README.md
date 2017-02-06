# `msmfg_spec_helper`
## What is it?
It a ruby gem whose purpose is to make it easyer to develop puppet modules complieant to MSMFG guidelines.
It provides:

1. [`msmfg-puppet-module-create`](#msmfg-puppet-module-create)
   1. [Can create an entire module skeleton from scratch](#can-create-an-entire-module-skeleton-from-scratch)
   2. [Can add missing files to an already existsing module](#can-add-missing-files-to-an-already-existsing-module)
   3. [Will add basic catalogue and acceptance specs](#will-add-basic-catalogue-and-acceptance-specs)
2. [`msmfg-puppet-module-validate`](#msmfg-puppet-module-validate)
   1. [Can validate the module](#can-validate-the-module)
   2. [Check syntax](#check-syntax) (anything)
   3. [Check ruby style](#check-ruby-style)
   4. [Check manifests style](#check-manifests-style)
   5. Check documentation coverage (WIP)
   6. [Runs MSMFG acceptance spes for Puppet Modules](#runs-msmfg-acceptance-spes-for-puppet-modules)
3. [`rake` tasks](#rake-tasks)
   1. You can cherry-pick the tasks and [use local Rakefile](#use-local-rakefile)
4. [No-brainer bundle](#no-brainer-bundle)
5. [No-brainer spec helpers](#no-brainer-spec-helpers)

## `msmfg-puppet-module-create`

### Can create an entire module skeleton from scratch
If you want to create a brand new module, you can use `msmfg-create-module`. You have 3 options:
Using environment variable `MODULE_NAME`
```sh
$ MODULE_NAME=puppet-something msmfg-puppet-module-create
```
Using rake argument variable `MODULE_NAME`
```sh
$ msmfg-puppet-module-create MODULE_NAME=puppet-something
```
Letting `msmfg-puppet-module-create` to guess the module's name from the current working directory
```sh
$ mkdir puppet-something
$ cd puppet-something
$ msmfg-puppet-module-create
```

### Can add missing files to an already existsing module
If you already have a module and you want to let this gem fill the gap, you can just run the `msmfg-puppet-module-create` command.
The script will not override existing files. `msmfg-puppet-module-create` will try to guess the module name from the `metadata.json`
file or current working directory basename.
```sh
$ cd /path/to/your/puppet-something
$ msmfg-create-module
```

### Will add basic catalogue and acceptance specs
The script will take care of creating `spec/spec_helper.rb`, `spec/spec_helper_acceptance` and
`spec/acceptance/nodesets/default.yml` for you. Gven a module name like `puppet-something`, the
script will also:

1. Create a basic catalogue spec `spec/classes/something_spec.rb` that is supposed to test the catalogue compilation.
2. Create a basic acceptance spec `spec/acceptance/something_spec.rb` that will try to apply the class manifest, twice.

Automatic guess of requirements is on the way. In the mean while you have to configure
[`.fixtures.yaml`](https://github.com/puppetlabs/puppetlabs_spec_helper#using-fixtures)

## `msmfg-puppet-module-validate`

### Can validate the module
You can validate the current module against the currently implemented MSMFG acceptance specs for puppet modules:
```
$ msmfg-puppet-module-validate
Checking ruby files syntax...
Checking metadata.json syntax...
Checking puppet manifests syntax...
Checking templates syntax...
Checking hieradata files syntax...
Checking fragments files syntax...
Running RuboCop...
Inspecting 6 files
......

6 files inspected, no offenses detected
Running puppet-lint...
YARD-Coverage: 100.0% (threshold: 100%)

Puppet module "skeleton"
  File "metadata.json"
    should be file
    metadata
      should include {"version" => (match /^[0-9]+(\.[0-9]+){0,2}$/)}
      should include {"author" => (match /at moneysupermarket\.com/)}
      should include {"source" => (match /https:\/\/github.com\/MSMFG\/msmfg-skeleton/)}
      should include {"project_page" => (match /https:\/\/github.com\/MSMFG\/msmfg-skeleton/)}
      should include {"issues_url" => (match /https:\/\/github.com\/MSMFG\/msmfg-skeleton\/issues/)}
  File "manifests/init.pp"
    should be file
    content
      should contain "class skeleton"
  Directory "specs"
    should not be empty
    should include at least 1 class spec
    should include at least 1 acceptance spec
  File ".fixtures.yaml"
    should be file
    fixtures
      should define a symlink to source_dir
  File "spec/acceptance/nodesets/default.yml"
    should be file
    nodeset
      should configure a masterless environment
      should include a default host
  File "Gemfile"
    should be file
    content
      should contain "gem 'msmfg_spec_helper'"
  File "Gemfile.lock"
    should be file
  File "Rakefile"
    should be file
    should contain "require 'msmfg_spec_helper/rake_tasks/puppet_module"

Finished in 0.05903 seconds (files took 0.87694 seconds to load)
21 examples, 0 failures
```

#### Check syntax
Check any sort of syntax:
```sh
$ msmfg-puppet-module-validate syntax
Checking ruby files syntax...
Checking metadata.json syntax...
Checking puppet manifests syntax...
Checking templates syntax...
Checking hieradata files syntax...
Checking fragments files syntax...
$
```
You could also check specific a type of syntax:
```
$ msmfg-puppet-module-validate syntax:ruby
Checking ruby files syntax...
$
```

#### Check ruby style
```sh
$ msmfg-puppet-module-validate ruby_style
Running RuboCop...
Inspecting 6 files
......

6 files inspected, no offenses detected
```

#### Check manifests style
```sh
$ msmfg-puppet-module-validate puppet_style
Running puppet-lint...
```

#### Runs MSMFG acceptance spes for Puppet Modules
```sh
$ msmfg-puppet-module-validate module_spec
Puppet module "skeleton"
  File "metadata.json"
    should be file
    metadata
      should include {"version" => (match /^[0-9]+(\.[0-9]+){0,2}$/)}
      should include {"author" => (match /at moneysupermarket\.com/)}
      should include {"source" => (match /https:\/\/github.com\/MSMFG\/msmfg-skeleton/)}
      should include {"project_page" => (match /https:\/\/github.com\/MSMFG\/msmfg-skeleton/)}
      should include {"issues_url" => (match /https:\/\/github.com\/MSMFG\/msmfg-skeleton\/issues/)}
  File "manifests/init.pp"
    should be file
    content
      should contain "class skeleton"
  Directory "specs"
    should not be empty
    should include at least 1 class spec
    should include at least 1 acceptance spec
  File ".fixtures.yaml"
    should be file
    fixtures
      should define a symlink to source_dir
  File "spec/acceptance/nodesets/default.yml"
    should be file
    nodeset
      should configure a masterless environment
      should include a default host
  File "Gemfile"
    should be file
    content
      should contain "gem 'msmfg_spec_helper'"
  File "Gemfile.lock"
    should be file
  File "Rakefile"
    should be file
    should contain "require 'msmfg_spec_helper/rake_tasks/puppet_module"

Finished in 0.05903 seconds (files took 0.87694 seconds to load)
21 examples, 0 failures
```

## `rake` tasks
Actually, `msmfg-puppet-module-create` and `msmfg-puppet-module-validate` are rake applications. 

### Use local Rakefile
There are multiple task libraries that you could `require` in your `Rakefile`:

* `msmfg_spec_helper/rake_tasks/puppet_module`: loads/configure any possible task
  * `msmfg_spec_helper/rake_tasks/puppet_module/create`: defines files/directories creation tasks
  * `msmfg_spec_helper/rake_tasks/puppet_module/validate`: loads all validation tasks:
    * `msmfg_spec_helper/rake_tasks/syntax`: see below
    * `msmfg_spec_helper/rake_tasks/puppet_style`: see below
    * `msmfg_spec_helper/rake_tasks/ruby_style`: see below
    * `msmfg_spec_helper/rake_tasks/docs_coverage`: see below
  * `msmfg_spec_helper/rake_tasks/puppet_module/spec`: defines puppet specs and acceptance specs tasks
* `msmfg_spec_helper/rake_tasks/syntax`: defins all syntax checking tasks
* `msmfg_spec_helper/rake_tasks/puppet_style`: defines the puppet style checking task
* `msmfg_spec_helper/rake_tasks/ruby_style`: defines the ruby style checking task
* `msmfg_spec_helper/rake_tasks/docs_coverage`: defines the documentation coverage checking task

As a matter of fact, when you create a new module, the generate `Rakefile` requires `msmfg_spec_helper/rake_tasks/puppet_module`

## No-brainer bundle
If you write your `Gemfile` like:
```ruby
source 'https://rubygems.org'
gem 'msmfg_spec_helper'
```
and run `bundle install` this gem will require all the goodies you might need to develop your module, including:

1. [`pry`](https://github.com/pry/pry)
2. [`puppetlabs_spec_helper`](https://github.com/puppetlabs/puppetlabs_spec_helper)

## No-brainer spec helpers
If you write yout `specs/spec_helper.rb` like:
```ruby
require 'msmfg_spec_helper/puppet_module/spec_helper_acceptance'
```
and your `specs/spec_helper_acceptance.rb` like:
```ruby
require 'msmfg_spec_helper/puppet_module/spec_helper'
```
Those 2 libraries will take care of the helpers configuration

