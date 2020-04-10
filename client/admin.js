
var axios = require('axios')
var jwt = require('jsonwebtoken')
var root_secret = 'supersecret'

var token = jwt.sign({ 
  exp: Math.floor(Date.now() / 1000) + (60 * 60),
}, root_secret)
console.log(token)

var url = `http://localhost:4000/api/add_key?auth_token=${token}&key_user=admin2&key=secret2`
axios.post(url)
  .then(function (response) {
    console.log(response.data)
  })
  .catch(function (error) {
    console.log(error)
  })

var url = `http://localhost:4000/api/list_keys`
axios.get(url)
  .then(function (response) {
    console.log(response.data)
  })
  .catch(function (error) {
    console.log(error)
  })

