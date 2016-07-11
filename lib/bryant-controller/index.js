let request = require('request-promise')
let cheerio = require('cheerio')
let util = require('util')
let EventEmitter = require('events').EventEmitter
let Events = {}

// https://www.myevolutionconnex.bryant.com/MyLocations/ConfigSystem?serialNumber=0414W000736
//

let BryantController = function (username, password) {
  this._username = username
  this._password = password
  this._systemSerialNumber;
  this._secret;
  this._locationId;
  this._systemId;
  this._locale;

  this._locations = []

  this._fetchLoginToken()
    .then(($) => {
      this._onFetchLoginToken($)
        .then((token) => {
          this._login(token)
            .then(($) => {
              this._onLogin($)
                .then(() => {
                  this._loadSystemConfig()
                })
            })
            .catch((e) => {
              console.log('onLoginError', e)
            })
        })
        .catch((e) => {
          console.log('error', e)
        })
    })
}

util.inherits(BryantController, EventEmitter)

let jar = request.jar()
let r = request.defaults({
  'jar': jar,
  'followAllRedirects': true,
  'headers': {'Origin': 'https://www.myevolutionconnex.bryant.com'},
  'transform': (body) => {
    return cheerio.load(body)
  }
})

// Gets the login verification token.
BryantController.prototype._fetchLoginToken = function () {
  console.log('Fetching login token.')
  var url = 'https://www.myevolutionconnex.bryant.com/Account/Login'
  return r(url)
}

BryantController.prototype._onFetchLoginToken = function ($) {
  console.log('Login page loaded. Looking for token.')
  return new Promise((resolve, reject) => {
    let input = $('input[name=__RequestVerificationToken]')
    let token = input.val()

    if (token) {
      console.log('Found login screen token.')
      return resolve(token)
    } else {
      return reject('No token found during login screen inspection.')
    }
  })
}

BryantController.prototype._login = function (token) {
  console.log('Authenticating with token.')
  var url = 'https://www.myevolutionconnex.bryant.com/Account/Login'

  let opts = {
    'method': 'POST',
    'uri': url,
    'form': {
      '__RequestVerificationToken': token,
      'Username': this._username,
      'Password': this._password,
      'RememberMe': true,
      'submit.x': 28,
      'submit.y': 12
    }
  }

  return r(opts)
}

BryantController.prototype._onLogin = function ($) {
  return new Promise((resolve,reject) => {

    let locations = $('.location')

    console.log("Found " + locations.toArray().length + " location(s).")

    locations.each((i,el) => {
      this._locationId  = $(el).data('location-id')
      this._locationName = $(el).find('.head .togl').text()
      this._locationAddress = $(el).find('.holder .location_detail').text()

      // Only supporting one system per household.
      let system = $(el).find('.systems')[0]
      this._systemSerialNumber = $(system).find('.system').data('serial-number')
      let outsideTemp = $(system).find('.temp').text()
      let status = $('.system_status table tbody tr')
      let currentTemp = $(status).find('td:nth-child(1)').text()
      let currentHumidity = $(status).find('td:nth-child(2)').text()
      let currentMode = $(status).find('td:nth-child(3)').text()

      let settingsHeat = $(status).find('td:nth-child(5)').text()
      let settingsCool = $(status).find('td:nth-child(6)').text()
      let settingsHumidity = $(status).find('td:nth-child(7)').text()
      let settingsMode = $(status).find('td:nth-child(8)').text()

      this._locations.push({
        outsideTemp:outsideTemp,
        currentTemp:currentTemp,
        currentHumidity: currentHumidity,
        currentMode: currentMode,
        settingsHeat: settingsHeat,
        settingsCool: settingsCool,
        settingsHumidity: settingsHumidity,
        settingsMode : settingsMode
      })

    })

    if (this._locations.length) {
      return resolve()
    } else {
      return reject("No locations found.")
    }
  })
}

BryantController.prototype._loadSystemConfig = function() {
  console.log('Loading system config screen.')
  let url = 'https://www.myevolutionconnex.bryant.com/MyLocations/ConfigSystem?serialNumber=' + this._systemSerialNumber
  let opts = {
    'uri':url,
    // We need to snag the Flash swfobject embed shit out of the body of the page.
    'transform': (body) => {
      return body
    }
  }

  r(opts)
  .then((body) => {
    let vars = {}
    let varsRE = /([\w]+):\sencodeURIComponent\(([^\)]+)\),*/g
    let data
    while(data = varsRE.exec(body)) {
      console.log(data[1], data[2])
    }
    //console.log(body)
  })

  //return r(opts)
}

BryantController.Events = Events
module.exports = BryantController
