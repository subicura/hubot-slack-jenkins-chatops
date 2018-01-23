# Description:
#   Notifies about Jenkins builds via Jenkins Notification Plugin for hubot-slack(v4)
#
# Dependencies:
#   hubot-slack: ^4.4.0
#
# Configuration:
#   HUBOT_JENKINS_COLOR_ABORTED: color for aborted builds
#   HUBOT_JENKINS_COLOR_FAILURE: color for failed builds
#   HUBOT_JENKINS_COLOR_FIXED: color for fixed builds
#   HUBOT_JENKINS_COLOR_STILL_FAILING: color for still failing builds
#   HUBOT_JENKINS_COLOR_SUCCESS: color for success builds
#   HUBOT_JENKINS_COLOR_DEFAULT: default color for builds
#
#   Just put this url
#   <HUBOT_URL>:<PORT>/<HUBOT_NAME>/jenkins?room=<room> to your
#   Jenkins Notification config. See here:
#   https://wiki.jenkins-ci.org/display/JENKINS/Notification+Plugin
#
# Commands:
#   None
#
# Notes:
#   POST /<robot-name>/jenkins?room=<room>
#
# Author:
#   inkel

HUBOT_JENKINS_COLOR_ABORTED       = process.env.HUBOT_JENKINS_COLOR_ABORTED       || "warning"
HUBOT_JENKINS_COLOR_FAILURE       = process.env.HUBOT_JENKINS_COLOR_FAILURE       || "danger"
HUBOT_JENKINS_COLOR_FIXED         = process.env.HUBOT_JENKINS_COLOR_FIXED         || "#d5f5dc"
HUBOT_JENKINS_COLOR_STILL_FAILING = process.env.HUBOT_JENKINS_COLOR_STILL_FAILING || "danger"
HUBOT_JENKINS_COLOR_SUCCESS       = process.env.HUBOT_JENKINS_COLOR_SUCCESS       || "good"
HUBOT_JENKINS_COLOR_DEFAULT       = process.env.HUBOT_JENKINS_COLOR_DEFAULT       || "#ffe094"

module.exports = (robot) ->
  robot.router.post "/#{robot.name}/jenkins", (req, res) ->
    room = req.query.room

    unless room?
      res.status(400).send("Bad Request").end()
      return

    if req.query.debug
      console.log req.body

    data = req.body

    res.status(202).end()

    return if data.build.phase == "QUEUED"
    return if data.build.phase == "COMPLETED"

    attachment =
      fields: []

    attachment.fields.push
      title: "Phase"
      value: data.build.phase
      short: true

    switch data.build.phase
      when "FINALIZED"
        status = "#{data.build.phase} with #{data.build.status}"

        attachment.fields.push
          title: "Status"
          value: data.build.status
          short: true

        color = switch data.build.status
          when "ABORTED"       then HUBOT_JENKINS_COLOR_ABORTED
          when "FAILURE"       then HUBOT_JENKINS_COLOR_FAILURE
          when "FIXED"         then HUBOT_JENKINS_COLOR_FIXED
          when "STILL FAILING" then HUBOT_JENKINS_COLOR_STILL_FAILING
          when "SUCCESS"       then HUBOT_JENKINS_COLOR_SUCCESS
          else                      HUBOT_JENKINS_COLOR_DEFAULT

      when "STARTED"
        status = data.build.phase
        color = "#e9f1ea"

        attachment.fields.push
          title: "Build #"
          value: "<#{data.build.full_url}|#{data.build.number}>"
          short: true

        params = data.build.parameters

        if params and params.ghprbPullId
          attachment.fields.push
            title: "Source branch"
            value: params.ghprbSourceBranch
            short: true
          attachment.fields.push
            title: "Target branch"
            value: params.ghprbTargetBranch
            short: true
          attachment.fields.push
            title: "Pull request"
            value: "#{params.ghprbPullId}: #{params.ghprbPullTitle}"
            short: true
          attachment.fields.push
            title: "URL"
            value: params.ghprbPullLink
            short: true
        else if data.build.scm.commit
          attachment.fields.push
            title: "Commit SHA1"
            value: data.build.scm.commit
            short: true
          attachment.fields.push
            title: "Branch"
            value: data.build.scm.branch
            short: true

    attachment.color    = color
    attachment.pretext  = "Jenkins #{data.name} #{status} #{data.build.full_url}"
    attachment.fallback = attachment.pretext

    if req.query.debug
      console.log attachment

    robot.messageRoom "##{room}", {
      attachments: [ attachment ]
    }
