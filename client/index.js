
var jwt = require('jsonwebtoken')
var auth_user = 'admin2'
var secret = 'secret2'
var channel = 'ch'

// sign token
var token = jwt.sign({ 
  chan: channel,
  exp: Math.floor(Date.now() / 1000) + (60 * 60),
}, secret)
console.log(token)

// verify token
var decoded = jwt.verify(token, secret);
console.log(decoded)

// subscribe
var EventSource = require('eventsource')
var url = `http://localhost:4000/pubsub?chan=${channel}&auth_token=${token}&auth_user=${auth_user}`
console.log(url)
var es = new EventSource(url)
es.onmessage = function(event) {
  console.log(event.data)
}
