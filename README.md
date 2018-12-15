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
notify sender: :author, receivers: User.all

notify sender: User.first, receivers: [:followers, User.all]
```

Here :sender and :followers should be associations for the model which needs to be notified.

### Methods
Suppose **Post** is the notified model and **author** is the sender association and **followers** is the receiver association.
Then following methods are available

```ruby
Post.notified?
Post.notification_validated?
```

**Methods for the [post] object**

```ruby
post.notify(sender: :author, receivers: :followers, message: 'My own message')
post.notifications
post.notifiers
post.#{receiver_class}_notificants
post.read_notificants
post.unread_notificants
post.mark_read
post.mark_read(receivers)
post.mark_unread
post.mark_unread(receivers)
```

**Methods for [author] object**

```ruby
author.sent_notifications
```

**Methods for [follower] object**

```ruby
follower.received_notifications
```

### Skipping Notification

```ruby
Post.create(content: '123', notify: false)
```

### Custom Notification message

```ruby
Post.create(content: '123', message: 'My custom notification message')
```

### Notification Models

```ruby
SimpleNotifications::Record
SimpleNotifications::Delivery
```

### Scopes

```ruby
SimpleNotifications::Record.read
SimpleNotifications::Record.unread
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aashishgarg/simple_notifications. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SimpleNotifications project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/simple_notifications/blob/master/CODE_OF_CONDUCT.md).
