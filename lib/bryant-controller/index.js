const request = require('request-promise')
const cheerio = require('cheerio')
const parseString = require('xml2js').parseString
const util = require('util')
const EventEmitter = require('events').EventEmitter
const Crypto = require('crypto')
const Events = {}

// https://www.myevolutionconnex.bryant.com/MyLocations/ConfigSystem?serialNumber=0414W000736

// Captured from decompiling MyEvolutionWeb.swf
const OAUTH_CONSUMER_KEY = 'dpf43f3p2l4k3l03'
const OAUTH_CONSUMER_SECRET = '0t8e47389j37f56u'

class BryantController extends EventEmitter {
  constructor (username, password) {
    super()

    let jar = request.jar()
    this._r = request.defaults({
      'jar': jar,
      'followAllRedirects': true,
      'headers': {'Origin': 'https://www.myevolutionconnex.bryant.com'}
      // 'transform': (body) => {
      //   return cheerio.load(body)
      // }
    })

    this._systemSerialNumber
    this._oauthSecret
    this._apiUrl
    this._locationId
    this._systemId
    this._locale
    this._lastTimestamp
    this._session

    this._locations = []
  }

  login (username, password) {
    this._username = username
    this._password = password
    return new Promise((resolve, reject) => {
      let xml = '<credentials><username><![CDATA[' + this._username + ']]></username><password><![CDATA[' + this._password + ']]></password></credentials>'
      let url = 'https://www.app-api.eng.bryant.com/users/authenticated'
      this._post(url, xml)
        .then((xml) => {
          parseString(xml, (err, res) => {
            if (!err) {
              if (res.result.accessToken) {
                this._oauthSecret = res.result.accessToken
                return resolve(res.result.accessToken)
              } else {
                return reject('Invalid credentials during login.')
              }
            } else {
              return reject(err)
            }
          })
        })
    })
  }

  getLocations () {
    return this._get('https://www.app-api.eng.bryant.com/users/' + this._username + '/locations')
  }
  getStatus () {
    // https://www.app-api.eng.bryant.com/systems/0414W000736/status
    this._get('https://www.app-api.eng.bryant.com/systems/0414W000736/status')
  }
  _get (url, data) {
    let oObj = this._getOAuthObj(url, 'GET')
    console.log(oObj)
    process.exit()
    let rOpts = {
      url: url,
      method: 'GET',
      headers: {
        'Content-type': 'application/x-www-form-urlencoded',
        'Authorization': 'OAuth realm="' + oObj.realm + '",oauth_consumer_key="' + OAUTH_CONSUMER_KEY + '",oauth_nonce="' + oObj.oauth_nonce + '",oauth_signature="' + this._urlEncode(oObj.oauth_signature) + '",oauth_signature_method="HMAC-SHA1",oauth_timestamp="' + oObj.oauth_timestamp + '",oauth_token="' + oObj.oauth_token + '",oauth_version="' + oObj.oauth_version + '"'
      }
    }
    return this._r(rOpts)
  }
  _post (url, data) {
    let oObj = this._getOAuthObj(url, 'POST')

    let rOpts = {
      url: url,
      method: 'POST',
      headers: {
        'Content-type': 'application/x-www-form-urlencoded',
        'Authorization': 'OAuth realm="' + oObj.realm + '",oauth_consumer_key="' + OAUTH_CONSUMER_KEY + '",oauth_nonce="' + oObj.oauth_nonce + '",oauth_signature="' + this._urlEncode(oObj.oauth_signature) + '",oauth_signature_method="HMAC-SHA1",oauth_timestamp="' + oObj.oauth_timestamp + '",oauth_token="' + oObj.oauth_token + '",oauth_version="' + oObj.oauth_version + '"'
      },
      body: 'data=' + data
    }

    return this._r(rOpts)
  }

  // Gets the login verification token.
  _fetchLoginToken () {
    console.log('Fetching login token.')
    var url = 'https://www.myevolutionconnex.bryant.com/Account/Login'
    return this._r(url)
  }

  _onFetchLoginToken ($) {
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



  _urlEncode (str) {
    str = encodeURIComponent(str)
    str = str.replace(/\!/g, '%21')
    str = str.replace(/\*/g, '%2A')
    str = str.replace(/'/g, '%27')
    str = str.replace(/\(/g, '%28')
    str = str.replace(/\)/g, '%29')
    return str
  }

  // MyInfinitySession:145
  _getOAuthObj (url, method = 'GET') {
    let timestamp = Math.round(new Date() / 1000)
    if (timestamp <= this._lastTimestamp) {
      timestamp = this._lastTimestamp + 1
    }

    this._lastTimestamp = timestamp

    let oauthObj = {
      'oauth_timestamp': timestamp.toString(),
      'oauth_nonce': timestamp + Math.round(Math.random() * 1000),
      'realm': url,
      'oauth_consumer_key': OAUTH_CONSUMER_KEY,
      'oauth_token': this.oauthToken,
      'oauth_version': '1.0',
      'oauth_signature_method': 'HMAC-SHA1'
    }

    oauthObj['oauth_signature'] = this._generateSignature(url, oauthObj, method)
    return oauthObj
  }

  _generateSignature (url, oauthObj, method) {
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

    let baseString = method.toUpperCase() + '&' + this._urlEncode(url) + '&' + this._urlEncode(joined)
    let signingKey = this._urlEncode(OAUTH_CONSUMER_SECRET) + '&' + this._urlEncode(this._oauthSecret)
    let signature = Crypto.createHmac('sha1', signingKey).update(baseString).digest('base64')

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

}

BryantController.Events = Events
module.exports = BryantController
