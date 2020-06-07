const request = require('request-promise')
const cheerio = require('cheerio')
const EventEmitter = require('events').EventEmitter
const Crypto = require('crypto')
const Events = {}

// https://www.myevolutionconnex.bryant.com/MyLocations/ConfigSystem?serialNumber=0414W000736

// Captured from decompiling MyEvolutionWeb.swf
const OAUTH_CONSUMER_KEY = 'dpf43f3p2l4k3l03'
const OAUTH_CONSUMER_SECRET = '0t8e47389j37f56u'

class BryantController extends EventEmitter {
  constructor(username, password) {
    super()

    let jar = request.jar()
    this._r = request.defaults({
      jar: jar,
      followAllRedirects: true,
      headers: { Origin: 'https://www.myevolutionconnex.bryant.com' },
      transform: (body) => {
        return cheerio.load(body)
      }
    })

    this._username = username
    this._password = password
    this._systemSerialNumber
    this._oauthSecret
    this._apiUrl
    this._locationId
    this._systemId
    this._locale
    this._lastTimestamp
    this._session

    this._locations = []

    console.log(
      this._getOAuthObj(
        'https://www.app-api.eng.bryant.com/systems/0414W000736'
      )
    )

    return

    this._fetchLoginToken().then(($) => {
      this._onFetchLoginToken($)
        .then((token) => {
          this._login(token)
            .then(($) => {
              this._onLogin($).then(() => {
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

  // Gets the login verification token.
  _fetchLoginToken() {
    console.log('Fetching login token.')
    var url = 'https://www.myevolutionconnex.bryant.com/Account/Login'
    return this._r(url)
  }

  _onFetchLoginToken($) {
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

  _login(token) {
    console.log('Authenticating with token.')
    var url = 'https://www.myevolutionconnex.bryant.com/Account/Login'

    let opts = {
      method: 'POST',
      uri: url,
      form: {
        __RequestVerificationToken: token,
        Username: this._username,
        Password: this._password,
        RememberMe: true,
        'submit.x': 28,
        'submit.y': 12
      }
    }

    return this._r(opts)
  }

  _onLogin($) {
    return new Promise((resolve, reject) => {
      let locations = $('.location')

      console.log('Found ' + locations.toArray().length + ' location(s).')

      locations.each((i, el) => {
        this._locationId = $(el).data('location-id')
        this._locationName = $(el).find('.head .togl').text()
        this._locationAddress = $(el).find('.holder .location_detail').text()

        // Only supporting one system per household.
        let system = $(el).find('.systems')[0]
        this._systemSerialNumber = $(system)
          .find('.system')
          .data('serial-number')
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
          outsideTemp: outsideTemp,
          currentTemp: currentTemp,
          currentHumidity: currentHumidity,
          currentMode: currentMode,
          settingsHeat: settingsHeat,
          settingsCool: settingsCool,
          settingsHumidity: settingsHumidity,
          settingsMode: settingsMode
        })
      })

      if (this._locations.length) {
        return resolve()
      } else {
        return reject('No locations found.')
      }
    })
  }

  _loadSystemConfig() {
    console.log('Loading system config screen.')
    let url =
      'https://www.myevolutionconnex.bryant.com/MyLocations/ConfigSystem?serialNumber=' +
      this._systemSerialNumber
    let opts = {
      uri: url,
      // We need to snag the Flash swfobject embed shit out of the body of the page.
      transform: (body) => {
        return body
      }
    }

    this._r(opts).then((body) => {
      let vars = {}
      let varsRE = /([\w]+):\sencodeURIComponent\("([^\)]+)"\),*/g
      let data
      while ((data = varsRE.exec(body))) {
        vars[data[1]] = data[2]
      }

      this._apiURL = vars.apiURL
      this._username = vars.username
      this._oauthSecret = vars.secret
      this._locationId = vars.location
      this._systemId = vars.system
      this._locale = vars.locale
    })

    // return r(opts)
  }

  _urlEncode(str) {
    str = encodeURIComponent(str)
    str = str.replace(/\!/g, '%21')
    str = str.replace(/\*/g, '%2A')
    str = str.replace(/'/g, '%27')
    str = str.replace(/\(/g, '%28')
    str = str.replace(/\)/g, '%29')
    return str
  }

  // MyInfinitySession:145
  _getOAuthObj(url, method = 'GET') {
    let timestamp = Math.round(new Date() / 1000)
    if (timestamp <= this._lastTimestamp) {
      timestamp = this._lastTimestamp + 1
    }

    this._lastTimestamp = timestamp

    let oauthObj = {
      oauth_timestamp: timestamp.toString(),
      oauth_nonce: timestamp + Math.round(Math.random() * 1000),
      realm: url,
      oauth_consumer_key: OAUTH_CONSUMER_KEY,
      oauth_token: this.oauthToken,
      oauth_version: '1.0',
      oauth_signature_method: 'HMAC-SHA1'
    }

    oauthObj['oauth_signature'] = this._generateSignature(url, oauthObj, method)
    return oauthObj
  }

  _generateSignature(url, oauthObj, method) {
    let arr = []
    for (var key in oauthObj) {
      if (key !== 'realm') {
        arr.push(key + '=' + this._urlEncode(oauthObj[key]))
      }
    }

    // for (var key in args) {
    //   arr.push(key + '=' + this._urlEncode(args[key]))
    // }

    arr.sort()

    let joined = arr.join('&')

    let baseString =
      method.toUpperCase() +
      '&' +
      this._urlEncode(url) +
      '&' +
      this._urlEncode(joined)
    let signingKey =
      this._urlEncode(OAUTH_CONSUMER_SECRET) +
      '&' +
      this._urlEncode(this._oauthSecret)
    let signature = Crypto.createHmac('sha1', signingKey)
      .update(baseString)
      .digest('base64')

    return signature
  }

  // _clientLogin () {
  //   let body = '<credentials><username><![CDATA[' + this._username + ']]></username><password><![CDATA[' + this._password + ']]></password></credentials>'
  //   let opts = {
  //     // Is this going to double-encode everything?
  //     'data': this._urlEncode(body),
  //     'method': 'POST'
  //   }
  // }

  post(url, data) {}
}

BryantController.Events = Events
module.exports = BryantController
