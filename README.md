# ErrataClient

[![Gem Version](https://badge.fury.io/rb/errata_client.png)](http://badge.fury.io/rb/errata_client)
[![Build Status](https://travis-ci.org/ManageIQ/errata_client.png)](https://travis-ci.org/ManageIQ/errata_client)
[![Code Climate](https://codeclimate.com/github/ManageIQ/errata_client.png)](https://codeclimate.com/github/ManageIQ/errata_client)
[![Coverage Status](https://coveralls.io/repos/ManageIQ/errata_client/badge.png?branch=master)](https://coveralls.io/r/ManageIQ/errata_client)
[![Dependency Status](https://gemnasium.com/ManageIQ/errata_client.png)](https://gemnasium.com/ManageIQ/errata_client)

ErrataClient is a client interface to the RedHat Errata Tool

## Installation

Add this line to your application's Gemfile:

    gem 'errata_client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install errata_client

## Pre-requisite

First configure Kerberos authentication to the Errata tool server and get a Kerberos ticket via kinit for the user account that will be using the ErrataClient. 

## Usage

```ruby
  require 'errata_client'
  
  # Getting an individual advisory
  advisory = ErrataClient::Advisory.find(:url => "https://errata_tool_url", :id => 13391).first
  puts "Advisory #{advisory.id} Synopsis: #{advisory.synopsis}"
  
  # Instead of passing the url in each call, you can configure it as follows and then
  # call the methods without it:
  ErrataClient::Advisory.config("https://errata_tool_url")

  advisory = ErrataClient::Advisory.find(:id => 13391).first
  puts "Advisory Id: #{advisory.id}"
  puts "Status:      #{advisory.status}"
  puts "Attributes:  #{advisory.attribute_names}"
  puts "Content:     #{advisory.attributes}"
  
  puts "Related Bugs: #{advisory.bugs.collect(&:id)}"
  
  # Getting details about the related bugs
  advisory.bugs.each do |bug|
    puts
    puts "bug id:          #{bug.id}"
    puts "short desc:      #{bug.short_desc}"
    puts "severity:        #{bug.bug_severity}"
    puts "status:          #{bug.bug_status}"
    puts "release notes:   #{bug.release_notes}"
  end
  
  puts "Related Builds: #{advisory.builds.collect(&:nvr)}"
    
  # Getting details about the related builds
  advisory.builds.each do |build|
    puts
    puts "build:           #{build.nvr}"
    puts "product version: #{build.product_version}"
    puts "classifications: #{build.classifications}"
    puts "architectures:   #{build.architectures}"
    puts "rpms:            #{build.rpms}"
    puts "details:         #{build.nvr_data}"
  end
  
  # Getting related RPM Diff Runs
  advisory.rpmdiff_runs.each do |rpmdiff_run|
    puts 
    puts "run_id:       #{rpmdiff_run.run_id}"
    puts "package name: #{rpmdiff_run.package_name}"
    puts "package path: #{rpmdiff_run.package_path}"
  end
  
  # Getting related TPS Jobs
  advisory.tps_jobs.each do |tps_job|
    puts
    puts "job_id:  #{tps_job.job_id}"
    puts "link:    #{tps_job.link}"
  end
  
  # Getting multiple advisories
  advisories = ErrataClient::Advisory.find(:id => [17571, 17572, 17573])
  
  # Getting all advisories
  ErrataClient::Advisory.all.each do |adv|
    puts "id: #{adv.id}  synopsis: #{adv.synopsis}"
  end

  # Getting advisories a Bug belongs to
  bug_id = 100234
  advs = ErrataClient::Advisory.advisories(:id => bug_id)
  puts "Advisories Bug #{bug_id} belongs to: #{advs.collect(&:id)}"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

