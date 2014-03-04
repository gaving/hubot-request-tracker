# Description:
#   Fetch ticket information from Request Tracker
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_RT_URL
#   HUBOT_RT_USERNAME
#   HUBOT_RT_PASSWORD
#
# Commands:
#   hubot rt search - Search for tickets
#
# Author:
#   gaving

'use strict'

querystring = require('querystring')

module.exports = (robot) ->
  url = process.env.HUBOT_RT_URL
  user = process.env.HUBOT_RT_USERNAME
  pass = process.env.HUBOT_RT_PASSWORD
  params = querystring.stringify(user: user, pass: pass)

  robot.hear /#(\d+)/i, (msg) ->
    id = escape(msg.match[1])
    msg.http("#{url}/REST/1.0/ticket/#{id}/show?#{params}")
      .headers(Accept: 'application/json')
      .get() (err, res, body) ->
        switch res.statusCode
          when  200
            match = body.match(/Subject:\ (.+)/)
            msg.send "#{match[1]} - #{url}/Ticket/Display.html?id=#{id}"
          when 401
            msg.send "Authentication Failure"
          else
            msg.send "Abort Abort!"

  robot.respond /rt search (.*)/i, (msg) ->
    subject = escape(msg.match[1])
    msg.http("#{url}/REST/1.0/search/ticket?#{params}&query=(Status%20=%20'open'ORStatus%20=%20'new')ANDSubject%20LIKE%20'#{subject}'")
      .headers(Accept: 'application/json')
      .get() (err, res, body) ->
        switch res.statusCode
          when  200
            msg.send body
          when 401
            msg.send "Authentication Failure"
          else
            msg.send "Abort Abort!"
