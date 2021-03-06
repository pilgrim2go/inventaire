# The 'user' endpoint is dedicated to opeartions on the user
# by the user herself once authentified.

# Other controllers involving operations on users:
# - auth: authentification operations (signup, login, etc)
# - relations: handling friends relations
# - invitatitons: inviting people out of Inventaire
# - users: finding users by their usernames, positions, etc

module.exports =
  get: require './get'
  put: require './update'
  delete: require './delete'
