#! /usr/bin/env coffee

###
Simulates a kegerator client, for development without the physical hardware.

Usage: kegerator_client.coffee [access_key] [secret_key]

Options:
  [access_key] : the 'public key' for the desired kegerator (defaults to '1111')
  [secret_key] : the 'secret key' for the desired kegerator (defaults to 's3cr3t')

  remember to quote any access/secret keys that contain special characters:

  Ex. node kegerator_client.coffee 2222 'p@$$w3rd'
###

# this allows us to require coffeescript files as if they were .js files
require 'coffee-script'

fermata       = require 'fermata'       # used to make easy REST HTTP requests
signedRequest = require 'string-signer' # used to sign each HTTP request
payload       = require '../lib/payload'

HOST = 'localhost'
KEGERATOR_ID = if (process.argv.length > 2) then process.argv[2] else '1111'
PORT = '8081'
# password with which to sign requests. should *never* be transferred over the wire.
SECRET = if (process.argv.length > 3) then process.argv[3] else 's3cr3t'

console.log "Using kegerator id: #{KEGERATOR_ID} w/ secret key: #{SECRET}"

# create and register a kegio fermata plugin that takes care of the request signing
fermata.registerPlugin 'kegio', (transport, host, port, kegeratorId, secret) ->
  port = if port == '80' then '' else ':' + port
  this.base = "http://#{host}#{port}/api/kegerator/#{kegeratorId}"
  transport = transport.using('statusCheck').using('autoConvert', "text/plain")

  # req = {base, method, path, query, headers, data}
  return (req, callback) ->
    requestToSign = payload.getPayload req.method, host + port, "/api/kegerator/#{kegeratorId}#{if req.path then req.path.join('/') else ''}", req.data
    sig = signedRequest.getSignature(requestToSign, secret)
    req.query = { signature: sig }
    req.headers['Content-Type'] = "application/x-www-form-urlencoded"
    transport req, callback

# define API endpoint using above-defined kegio fermata plugin
kegioAPI = fermata.kegio HOST, PORT, KEGERATOR_ID, SECRET

# handy fn for easily writing coffeescript setTimeout code (w/ callback last)
# Ex. delay 1000, -> something param
delay = (ms, func) -> setTimeout func, ms

# create FakeKegerator object
class FakeKegerator

  constructor: () ->

  go: () ->
    @fakePour()
    @fakeTemp()

  # Produces a fake "flow" event on a given interval, used in development mode
  fakeFlow: (flowsLeft) =>
    if (flowsLeft > 0)
      randomFlow = (Math.floor(Math.random() * 61)) + 30  # between 30-90

      # send API request
      kegioAPI.flow(randomFlow).put (err, result) ->
        if !err
          console.log "flow sent: #{randomFlow}, server responded with: #{result}"
        else
          console.log "ERROR: error sending flow request: #{result}"

      # repeat every second, until the pour is done
      delay 1000, () =>
        @fakeFlow flowsLeft - 1

    else
      # (In Fred Armisen from Portandia voice): "This flow is **OVER**!!!"
      # send API request
      kegioAPI.flow.end.put (err, result) ->
        if !err
          console.log "flow ended, server responded with: #{result}"
        else
          console.log "ERROR: error sending flow end request: #{result}"

  # Produces a fake "pour" event on a given interval, used in development mode
  fakePour: () =>
    # Select a random user, using values that we "know" are in the DB,
    # (based on the fact that they're hardcoded into the DB rebuild script)
    randomUser = Math.floor Math.random() * 5  # between 0-4
    userRFID = ''
    switch randomUser
      when 0 then userRFID = "5100FFED286B"  # Dylan
      when 1 then userRFID = "44004C3A1A"  # Chris
      when 2 then userRFID = "4400561A0A"  # Carl
      when 3 then userRFID = "440055F873"  # Garrett
      when 4 then userRFID = "DENYTAG544"  # deny user

    console.log 'fake pour!!!!!!'
    # send API request
    kegioAPI.scan(userRFID).get (err, result) =>
      if !err
        console.log "scan user: #{userRFID}, server responded with: #{result}"
        @fakeFlow 7   # flow for 7 seconds
      else
        console.log "ERROR: error sending scan request for user: #{userRFID} #{result}"

    delay 10000, @fakePour # repeat every 10 seconds

  # Produces a fake "temp" event on a given interval, used in development mode
  fakeTemp: () =>
    randomTemp = 40 + (Math.floor(Math.random() * 10) - 5) # yields a temp between 35 and 45

    # send API request
    kegioAPI.temp(randomTemp).put (err, result) ->
      if !err
        console.log "temp send: #{randomTemp}, server responded with: #{result}"
      else
        console.log "ERROR: error sending temp request: #{randomTemp}"

    delay 10000, @fakeTemp # repeat every 10 seconds

fakeKegerator = new FakeKegerator()
fakeKegerator.go()
