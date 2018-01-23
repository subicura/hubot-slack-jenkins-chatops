# Description:
#   Jenkins CI Interactive bot
#
# Dependencies:
#   hubot-slack: ^4.4.0
#
# Configuration:
#   HUBOT_JENKINS_URL
#
#   URL should be in the "http://user:pass@localhost:8080" format.
#
# Commands:
#   hubot j(enkins) build - lists Jenkins jobs for build
#   hubot j(enkins) build <job name> - Build jenkins job
#
# Author:
#   subicura

{ createMessageAdapter } = require('@slack/interactive-messages')
slackMessages = createMessageAdapter(process.env.HUBOT_SLACK_VERIFICATION_TOKEN)
jenkins = require('jenkins')({ baseUrl: process.env.HUBOT_JENKINS_URL, crumbIssuer: true });

module.exports = (robot) ->
  robot.respond /j(?:enkins)? build$/i, (res) ->
    jenkins.job.list (err, data) ->
      if err 
        res.send "error: #{err.message}"
        return

      response = ''
      jobs = []

      for job in data
        state = if job.color == "red"
                  "FAIL"
                else if job.color == "aborted"
                  "ABORTED"
                else if job.color == "aborted_anime"
                  "CURRENTLY RUNNING"
                else if job.color == "red_anime"
                  "CURRENTLY RUNNING"
                else if job.color == "blue_anime"
                  "CURRENTLY RUNNING"
                else "PASS"
        jobs.push text: "#{job.name} #{state}", value: job.name

      attachment = {
        "text": "Choose a job to build",
        "fallback": "You are unable to choose a job",
        "callback_id": "jenkins.job.build",
        "color": "#3AA3E3",
        "attachment_type": "default",
        "actions": [
          {
            "name": "jobs_list",
            "text": "Pick a job...",
            "type": "select",
            "options": jobs
          }
        ]
      }

      if !jobs.length
        res.send "no job exists."
      else
        res.send 
          text: "Jenkins job list",
          attachments: [ attachment ]

  robot.respond /j(?:enkins)? build ([\w\.\-_ ]+)(, (.+))?/i, (res) ->
    job = res.match[1]
    jenkins.job.build job, (err, data) ->
      if err 
        res.send "error: #{err.message}"
        return
      res.send "#{job} job is started by #{res.message.user.name}"

  # interactive action
  robot.router.use('/slack/action', slackMessages.expressMiddleware())

  slackMessages.action 'jenkins.job.build', (payload, res) ->
    action = payload.actions[0]
    select = action.selected_options[0]
    
    robot.logger.debug 'handle welcome action with payload: ' + payload

    jenkins.job.build select.value, (err, data) ->
      if err 
        res text: "error: #{err.message}"
        return
      res text: "#{select.value} job is started by #{payload.user.name}"

    return payload.original_message
