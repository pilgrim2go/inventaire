module.exports = (groups_, _)->
  pendingGroupInvitationsCount: (userId)->
    groups_.byInvitedUser userId
    .get 'length'

  pendingGroupRequestsCount: (userId)->
    groups_.byAdmin userId
    .then (groups)-> _.sum groups.map(_.property('requested.length'))
