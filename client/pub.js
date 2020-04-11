
var axios = require('axios')
var jwt = require('jsonwebtoken')

var auth_user = 'admin2'
var secret = 'secret2'
var channel = 'ch'
var payload = 'data'

// sign token
var token = jwt.sign({ 
  chan: channel,
  exp: Math.floor(Date.now() / 1000) + (60 * 60),
}, secret)
console.log(token)

var url = `http://localhost:4000/api/publish?chan=${channel}&data=${payload}&auth_token=${token}&auth_user=${auth_user}`
axios.post(url)
  .then(function (response) {
    console.log(response.data)
  })
  .catch(function (error) {
    console.log(error)
  })