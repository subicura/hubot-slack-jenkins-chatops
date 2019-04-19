# hubot-slack-jenkins-chatops

Jenkins integration with slack interactive message and respond to jenkins notifications.

![slack jenkins bot](./screenshot/slack-jenkins-bot.gif)

## Installation

In hubot project repository, run:

```
npm install hubot-slack-jenkins-chatops --save
```

Then add `hubot-slack-jenkins-chatops` to your `external-scripts.json`:

```json
[
  "hubot-slack-jenkins-chatops"
]
```

## Configuration

### Slack

You need to create your own slack app. (Slack's hubot plugin is not support interactive callback) Visit [apps page](https://api.slack.com/apps) and create new app.

![create slack app](./screenshot/create-slack-app.png)

Enable interactive components and add `Request URL`(Request URL SSL certificate requirements). You need to change request url to point to your host. Detail info [here](https://api.slack.com/interactive-messages).

![enable interactive component](./screenshot/slack-interactive-component.png)

Add a bot user like this.

![add bot user](./screenshot/add-bot-user.png)

### Jenkins

You need to enable Jenkins [notification-plugin](https://wiki.jenkins-ci.org/display/JENKINS/Notification+Plugin) and then, in each project you would like to be notified about, add an endpoint like the following:

![Add Notification endpoint](./screenshot/jenkins-setting.png)

You only need to change `URL` to point to your host. Take into account that the URL path begins with your Hubot instance name, so if your Hubot is named `marvin`, the URL should be `http://example.com/marvin/jenkins` instead.

The `room` query string parameter is required, as an indicator of the channel name where you would like your notification to be displayed. You don't need to prefix your room name with `#`, so if you want your notifications displayed in the `#ci` channel, then you need to pass `?room=ci`.

In case you want to see the message received and the attachment sent, you can also pass `debug=1`.

### Environment variables

- `HUBOT_SLACK_VERIFICATION_TOKEN`: Visit your app basic information page and check app credentials.
- `HUBOT_JENKINS_URL`: http://user:password@jenkins-host or http://user:token@jenkins-host (ex: http://admin:secret@localhost:8080)


The following environment variables define the colors used for each build status:

- `HUBOT_JENKINS_COLOR_ABORTED`
- `HUBOT_JENKINS_COLOR_FAILURE`
- `HUBOT_JENKINS_COLOR_FIXED`
- `HUBOT_JENKINS_COLOR_STILL_FAILING`
- `HUBOT_JENKINS_COLOR_SUCCESS`
- `HUBOT_JENKINS_COLOR_DEFAULT`

## Commands

- `hubot j(enkins) build`
  - Lists Jenkins jobs to build 
- `hubot j(enkins) build <job name>`
  - Build jenkins job 


## Reference

- [https://github.com/inkel/hubot-jenkins-slack](https://github.com/inkel/hubot-jenkins-slack)
- [https://github.com/github/hubot-scripts/blob/master/src/scripts/jenkins.coffee](https://github.com/github/hubot-scripts/blob/master/src/scripts/jenkins.coffee)