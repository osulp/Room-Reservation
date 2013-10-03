# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
RoomReservation::Application.config.secret_token = '63a07dc03e2fd1da9b85761584f9c84138f05b48a703d89850d75a88e6fd8d5a5f768a45d2b3b32e2d0bfda65abe6adc1ec671d5c689110ee9395992733f3d2f'
RoomReservation::Application.config.secret_key_base = ENV['ROOMRES_SECRET_KEY'] || '3154e3ec5931b56574038b90d6fcba7eb832a899ffdee9d31c2f61ad452207a69f03b3fda9a4594aa4d04dbeab8bb636f3db7a24cf9b63774d969eacc12275e3'