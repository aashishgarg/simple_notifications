# SimpleNotifications

A very simple gem providing the notifications functionality to any model in a Rails application.

### Installation

Add following line to your gemfile

```ruby
gem 'simple_notifications'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_notifications

### Usage

Run the simple notifications generator

```ruby
rails generate simple_notifications:install
```
This will generate two files in your rails project

* simple_notifications.rb - An initializer file.
* Migration file - Required for recording notifications.

Then run

```ruby
rails db:migrate
``` 

Add following line to the model for which notifications functionality is required

```ruby
notify sender: :author, receivers: :followers
``` 
Or you can provide ActiveRecord::Base object or ActiveRecord::Relation objects as 

```ruby
notify sender: User.first, receivers: User.all
```

Here :sender and :followers should be associations for the model which needs to be notified.

### Methods
Suppose **Post** is the notified model and **author** is the sender association and **followers** is the receiver association.
Then following methods are available

* Post.notified?
* Post.notification_validated?

Methods for the **post** object

* post.notifications
* post.notifiers
* post.notificants

Methods for **author** object

* author.sent_notifications

Methods for **follower** object

* follower.received_notifications

Notification Model

* SimpleNotifications::Record
* SimpleNotifications::Delivery

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aashishgarg/simple_notifications. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SimpleNotifications project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/simple_notifications/blob/master/CODE_OF_CONDUCT.md).
