![Redmine Chatwork](https://cloud.githubusercontent.com/assets/6197292/22987916/aab3c8b8-f3f3-11e6-9b39-8f53a53a2a42.png)

# Redmine Chatwork

This plugin notifies updates of Redmine tickets and wiki to your [ChatWork](http://www.chatwork.com/) room. You can change settings for each project by creating custom-fields.

## Compatible with:

* Redmine 3.4.x
* Redmine 3.3.x
* Redmine 3.2.x

## Installation

1. [Get your ChatWork API token from the authentication page](https://www.chatwork.com/service/packages/chatwork/subpackages/api/apply_beta_business.php)
2. Download this repository
3. Install `httpclient` by running `bundle install` from the plugin directory
4. Restart Redmine
5. Open plugin setting: `Administration > Plugins > Redmine Chatwork`
6. Set you API token and default room URL
7. Create `ChatWork Room URL` and `ChatWork Notice Disabled` project custom field (option)

## Settings

![](https://cloud.githubusercontent.com/assets/6197292/22985457/d54cf20a-f3eb-11e6-8637-87ed17d3120d.png)

### Changing behavior for each project

You can override the room or turn off notifications by using project custom field.
The name of the custom field must be same from the example.

![](https://cloud.githubusercontent.com/assets/6197292/22987131/209b667e-f3f1-11e6-8ce9-24305f09a1e1.png)

1. Create project custom fields:
  * A "Link" field named `ChatWork Room URL`
  * A "Boolean" field named `ChatWork Notice Disabled`
2. Go to the project setting which you want to override from default.
3. Fill the "ChatWork" field to change the room to notify.
4. Set "No" at the "ChatWork Disabled" field not to send updates.

### Set reminder task

Redmine offers a rake task that sends reminder active projects and issues that are past due or due in the next specified number of days.

| paramater name | description                    | default      |
| -------------- | ------------------------------ | ------------ |
| days           | number of days to remind about | 7            |
| projects       | id of project                  | all projects |
| trackers       | id of tracker                  | all trackers |
| LOCALE         | notify language                | en           |

When adding this to your crontab, add the rake command

```
0 1 * * * cd </path/to/redmine>; bundle exec rake redmine_chatwork:reminder  RAILS_ENV="production"
```

```
0 1 * * * cd </path/to/redmine>; bundle exec rake redmine_chatwork:reminder projects="1,2,3" trackers="4,5,6" days=10 LOCALE="ja" RAILS_ENV="production"
```

* `</path/to/redmine>` was specify Redmine installation directory.

## Screenshot

![](https://cloud.githubusercontent.com/assets/6197292/22985404/aa72fb38-f3eb-11e6-8520-f855fa02c405.png)

## Changelog

### v0.8.0

* support Redmine 4.0

### v0.7.1

* update language file

### v0.7.0

* modify wiki page update notify

### v0.6.0

* issue hook useing ActiveRecode callback

### v0.5.0

* Add reminder task

### v0.4.1

* Change project custom field name(`ChatWork Disabled` => `ChatWork Notice Disabled`)
* plugin setting page remove `required` attribute by input field

### v0.4.0

* Inherit parent project custom field value

### v0.3.1

* Change project custom field name(`ChatWork` => `ChatWork Room URL`)

### v0.3.0

* Modify send message
* Add translation

### v0.2.1

* Fix hash keys for plugin setting

### v0.2.0

* Change API endpoint from v1 to v2
* Add translation files (en and ja)

### v0.1.1

* Fix unexpected body escaping

### v0.1.0

* The first release

## Author

http://media-massage.net/profile/

## Acknowledge

This plugins is based on [sciyoshi/redmine-slack](https://github.com/sciyoshi/redmine-slack).

## License

MIT License
